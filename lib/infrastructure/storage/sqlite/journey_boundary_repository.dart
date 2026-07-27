import 'dart:convert';

import 'package:primeatlas/core/journey/journey_boundary.dart';
import 'package:primeatlas/core/journey/journey_boundary_repository.dart';
import 'package:sqlite3/sqlite3.dart';

import 'journey_boundary_ids.dart';
import 'journey_boundary_writer.dart';
import 'operation_ledger_repository.dart';
import 'unit_of_work.dart';

/// SQLite implementation of [JourneyBoundaryRepository].
/// All writes go through a single [SqliteUnitOfWork] (BEGIN IMMEDIATE).
class SqliteJourneyBoundaryRepository implements JourneyBoundaryRepository {
  SqliteJourneyBoundaryRepository(
    this.database, {
    UnitOfWork? unitOfWork,
  }) : _unitOfWork = unitOfWork ?? SqliteUnitOfWork(database);

  final Database database;
  final UnitOfWork _unitOfWork;

  @override
  ConfirmedJourneyBoundary confirm(ConfirmJourneyBoundaryCommand command) {
    final payloadJson = journeyCanonicalJson(command.toPayload());
    final payloadHash = journeySha256Hex(payloadJson);
    final ledger = OperationLedgerRepository(database);
    final existing = ledger.ensureReplayable(
      command.ownerId,
      command.operationId,
      payloadHash,
    );
    if (existing != null) {
      return ConfirmedJourneyBoundary.fromResultJson(
        Map<String, Object?>.from(jsonDecode(existing.resultJson!) as Map),
      );
    }

    return _unitOfWork.run((tx) {
      ensureGuestSubjectAndDevice(tx, command);
      final draftId =
          journeyStableId(command.ownerId, 'draft', command.operationId);
      final portraitId =
          journeyStableId(command.ownerId, 'portrait', command.operationId);
      final domainId =
          journeyStableId(command.ownerId, 'domain', command.operationId);
      final goalId =
          journeyStableId(command.ownerId, 'goal', command.operationId);
      final milestoneId =
          journeyStableId(command.ownerId, 'milestone', command.operationId);
      final now = command.occurredAtUs;
      insertConfirmedJourneyBoundaryGraph(
        tx,
        command: command,
        draftId: draftId,
        portraitId: portraitId,
        domainId: domainId,
        goalId: goalId,
        milestoneId: milestoneId,
        now: now,
      );

      final result = ConfirmedJourneyBoundary(
        ownerId: command.ownerId,
        operationId: command.operationId,
        draftId: draftId,
        portraitVersionId: portraitId,
        domainId: domainId,
        goalId: goalId,
        milestoneId: milestoneId,
        direction: command.direction,
        constraint: command.constraint,
        domainCode: command.domainCode,
        goalTitle: command.goalTitle,
        milestone: command.milestone,
        confirmedAtUs: now,
      );
      final deviceSeq =
          nextDeviceSeq(tx, command.ownerId, command.deviceId, now);
      OperationLedgerRepository(tx).record(
        OperationLedgerEntry.committed(
          id: journeyStableId(command.ownerId, 'ledger', command.operationId),
          ownerId: command.ownerId,
          operationId: command.operationId,
          deviceId: command.deviceId,
          deviceSeq: deviceSeq,
          operationType: 'create',
          entityType: 'journey_boundary',
          entityId: portraitId,
          payloadJson: payloadJson,
          payloadHash: payloadHash,
          resultJson: journeyCanonicalJson(result.toResultJson()),
          nowUs: now,
        ),
      );
      return result;
    });
  }

  @override
  ConfirmedJourneyBoundary? loadLatestConfirmed(String ownerId) {
    if (ownerId.trim().isEmpty) {
      throw const OwnerScopeViolation();
    }
    final portraitRows = database.select(
      'SELECT id, snapshot_json, confirmed_draft_id, activated_at_us '
      'FROM portrait_versions '
      "WHERE owner_id = ? AND lifecycle = 'active' AND kind = 'confirmed' "
      'ORDER BY activated_at_us DESC, id DESC LIMIT 1',
      [ownerId],
    );
    if (portraitRows.isEmpty) return null;
    final portrait = portraitRows.single;
    final snapshot = Map<String, Object?>.from(
      jsonDecode(portrait['snapshot_json'] as String) as Map,
    );
    final domainRows = database.select(
      'SELECT id, domain_code FROM active_domains '
      "WHERE owner_id = ? AND status = 'active' "
      'ORDER BY priority ASC LIMIT 1',
      [ownerId],
    );
    if (domainRows.isEmpty) return null;
    final domain = domainRows.single;
    final goalRows = database.select(
      'SELECT id, title FROM goals '
      "WHERE owner_id = ? AND domain_id = ? AND status = 'active' "
      'ORDER BY updated_at_us DESC, id DESC LIMIT 1',
      [ownerId, domain['id']],
    );
    if (goalRows.isEmpty) return null;
    final goal = goalRows.single;
    final milestoneRows = database.select(
      'SELECT id, title, rule_json FROM milestones '
      'WHERE owner_id = ? AND goal_id = ? '
      'ORDER BY sequence_no ASC LIMIT 1',
      [ownerId, goal['id']],
    );
    if (milestoneRows.isEmpty) return null;
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
      draftId: portrait['confirmed_draft_id'] as String,
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
}

/// Public alias for tests asserting hash length/format.
String sha256Hex(String input) => journeySha256Hex(input);
