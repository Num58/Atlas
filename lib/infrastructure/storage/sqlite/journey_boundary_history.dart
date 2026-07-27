import 'dart:convert';

import 'package:primeatlas/core/journey/journey_boundary.dart';
import 'package:sqlite3/sqlite3.dart';

import 'journey_boundary_ids.dart';
import 'journey_boundary_writer.dart';
import 'operation_ledger_repository.dart';

List<BoundaryVersionSummary> queryBoundaryVersions(
  Database database,
  String ownerId,
) {
  final rows = database.select(
    'SELECT id, ordinal, lifecycle, kind, snapshot_json, activated_at_us, '
    'restored_from_version_id '
    'FROM portrait_versions '
    'WHERE owner_id = ? '
    'ORDER BY ordinal DESC, activated_at_us DESC, id DESC',
    [ownerId],
  );
  return rows.map((row) {
    final snapshot = Map<String, Object?>.from(
      jsonDecode(row['snapshot_json'] as String) as Map,
    );
    final milestoneMap = Map<String, Object?>.from(
      snapshot['milestone'] as Map? ?? const {},
    );
    return BoundaryVersionSummary(
      versionId: row['id'] as String,
      ordinal: row['ordinal'] as int,
      lifecycle: row['lifecycle'] as String,
      kind: row['kind'] as String,
      direction: snapshot['direction'] as String? ?? '',
      constraint: snapshot['constraint'] as String? ?? '',
      domainCode: snapshot['domain_code'] as String? ?? '',
      goalTitle: snapshot['goal_title'] as String? ?? '',
      milestone: JourneyMilestoneInput(
        title: milestoneMap['title'] as String? ?? '',
        evidenceRule: milestoneMap['evidence_rule'] as String? ?? '',
        window: milestoneMap['window'] as String? ?? '',
      ),
      activatedAtUs: row['activated_at_us'] as int,
      restoredFromVersionId: row['restored_from_version_id'] as String?,
    );
  }).toList(growable: false);
}

ConfirmedJourneyBoundary confirmedFromPortraitRow(
  Database database,
  String ownerId,
  Row portrait,
) {
  final snapshot = Map<String, Object?>.from(
    jsonDecode(portrait['snapshot_json'] as String) as Map,
  );
  final domainRows = database.select(
    'SELECT id, domain_code FROM active_domains '
    "WHERE owner_id = ? AND status = 'active' "
    'ORDER BY priority ASC LIMIT 1',
    [ownerId],
  );
  if (domainRows.isEmpty) {
    throw const JourneyBoundaryIncomplete('缺少活跃成长域，无法恢复边界。');
  }
  final domain = domainRows.single;
  final goalRows = database.select(
    'SELECT id, title FROM goals '
    "WHERE owner_id = ? AND domain_id = ? AND status = 'active' "
    'ORDER BY updated_at_us DESC, id DESC LIMIT 1',
    [ownerId, domain['id']],
  );
  if (goalRows.isEmpty) {
    throw const JourneyBoundaryIncomplete('缺少活跃目标，无法恢复边界。');
  }
  final goal = goalRows.single;
  final milestoneRows = database.select(
    'SELECT id, title, rule_json FROM milestones '
    'WHERE owner_id = ? AND goal_id = ? '
    'ORDER BY sequence_no ASC LIMIT 1',
    [ownerId, goal['id']],
  );
  if (milestoneRows.isEmpty) {
    throw const JourneyBoundaryIncomplete('缺少里程碑，无法恢复边界。');
  }
  final milestoneRow = milestoneRows.single;
  final rule = Map<String, Object?>.from(
    jsonDecode(milestoneRow['rule_json'] as String) as Map,
  );
  final ledgerRows = database.select(
    'SELECT operation_id FROM operation_ledger '
    "WHERE owner_id = ? AND entity_type = 'journey_boundary' "
    "AND entity_id = ? AND state = 'committed' "
    'ORDER BY created_at_us DESC LIMIT 1',
    [ownerId, portrait['id']],
  );
  return ConfirmedJourneyBoundary(
    ownerId: ownerId,
    operationId: ledgerRows.isEmpty
        ? ''
        : ledgerRows.single['operation_id'] as String,
    draftId: (portrait['confirmed_draft_id'] as String?) ?? '',
    portraitVersionId: portrait['id'] as String,
    domainId: domain['id'] as String,
    goalId: goal['id'] as String,
    milestoneId: milestoneRow['id'] as String,
    direction: snapshot['direction'] as String,
    constraint: snapshot['constraint'] as String,
    domainCode: domain['domain_code'] as String,
    goalTitle: goal['title'] as String,
    milestone: JourneyMilestoneInput(
      title: milestoneRow['title'] as String,
      evidenceRule: rule['evidence_rule'] as String,
      window: rule['window'] as String,
    ),
    confirmedAtUs: portrait['activated_at_us'] as int,
  );
}

ConfirmedJourneyBoundary restoreBoundaryVersionInTransaction(
  Database tx,
  RestoreBoundaryVersionCommand command, {
  required String payloadJson,
  required String payloadHash,
}) {
  final sourceRows = tx.select(
    'SELECT id, snapshot_json FROM portrait_versions '
    'WHERE owner_id = ? AND id = ?',
    [command.ownerId, command.versionId],
  );
  if (sourceRows.isEmpty) {
    throw const JourneyBoundaryIncomplete('要恢复的目标边界版本不存在。');
  }
  final source = sourceRows.single;
  final snapshot = Map<String, Object?>.from(
    jsonDecode(source['snapshot_json'] as String) as Map,
  );
  final milestoneMap = Map<String, Object?>.from(
    snapshot['milestone'] as Map? ?? const {},
  );
  final confirmCommand = ConfirmJourneyBoundaryCommand(
    ownerId: command.ownerId,
    operationId: command.operationId,
    deviceId: command.deviceId,
    installationId: command.installationId,
    direction: snapshot['direction'] as String? ?? '',
    constraint: snapshot['constraint'] as String? ?? '',
    domainCode: snapshot['domain_code'] as String? ?? '',
    goalTitle: snapshot['goal_title'] as String? ?? '',
    milestone: JourneyMilestoneInput(
      title: milestoneMap['title'] as String? ?? '',
      evidenceRule: milestoneMap['evidence_rule'] as String? ?? '',
      window: milestoneMap['window'] as String? ?? '',
    ),
    occurredAtUs: command.occurredAtUs,
    appVersion: command.appVersion,
    platform: command.platform,
    subjectKind: command.subjectKind,
  );

  ensureGuestSubjectAndDevice(tx, confirmCommand);
  final draftId =
      journeyStableId(command.ownerId, 'draft', command.operationId);
  final portraitId =
      journeyStableId(command.ownerId, 'portrait', command.operationId);
  final domainId =
      journeyStableId(command.ownerId, 'domain', command.operationId);
  final goalId = journeyStableId(command.ownerId, 'goal', command.operationId);
  final milestoneId =
      journeyStableId(command.ownerId, 'milestone', command.operationId);
  final now = command.occurredAtUs;

  insertConfirmedJourneyBoundaryGraph(
    tx,
    command: confirmCommand,
    draftId: draftId,
    portraitId: portraitId,
    domainId: domainId,
    goalId: goalId,
    milestoneId: milestoneId,
    now: now,
  );
  tx.execute(
    "UPDATE portrait_versions SET kind = 'restored', "
    'confirmed_draft_id = NULL, restored_from_version_id = ?, '
    "change_summary = 'user_restored_journey_boundary', "
    'updated_at_us = ? '
    'WHERE owner_id = ? AND id = ?',
    [command.versionId, now, command.ownerId, portraitId],
  );

  final result = ConfirmedJourneyBoundary(
    ownerId: command.ownerId,
    operationId: command.operationId,
    draftId: draftId,
    portraitVersionId: portraitId,
    domainId: domainId,
    goalId: goalId,
    milestoneId: milestoneId,
    direction: confirmCommand.direction,
    constraint: confirmCommand.constraint,
    domainCode: confirmCommand.domainCode,
    goalTitle: confirmCommand.goalTitle,
    milestone: confirmCommand.milestone,
    confirmedAtUs: now,
  );
  final deviceSeq = nextDeviceSeq(tx, command.ownerId, command.deviceId, now);
  OperationLedgerRepository(tx).record(
    OperationLedgerEntry.committed(
      id: journeyStableId(command.ownerId, 'ledger', command.operationId),
      ownerId: command.ownerId,
      operationId: command.operationId,
      deviceId: command.deviceId,
      deviceSeq: deviceSeq,
      operationType: 'restore',
      entityType: 'journey_boundary',
      entityId: portraitId,
      payloadJson: payloadJson,
      payloadHash: payloadHash,
      resultJson: journeyCanonicalJson(result.toResultJson()),
      nowUs: now,
    ),
  );
  return result;
}
