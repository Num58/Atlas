import 'package:primeatlas/core/journey/journey_boundary.dart';
import 'package:sqlite3/sqlite3.dart';

import 'journey_boundary_ids.dart';
import 'operation_ledger_repository.dart';

/// Inserts the confirmed journey boundary graph for one owner.
void insertConfirmedJourneyBoundaryGraph(
  Database tx, {
  required ConfirmJourneyBoundaryCommand command,
  required String draftId,
  required String portraitId,
  required String domainId,
  required String goalId,
  required String milestoneId,
  required int now,
}) {
  final answersJson = journeyCanonicalJson({
    'direction': command.direction,
    'constraint': command.constraint,
  });
  final snapshotJson = journeyCanonicalJson({
    'direction': command.direction,
    'constraint': command.constraint,
    'domain_code': command.domainCode,
    'goal_title': command.goalTitle,
    'milestone': command.milestone.toJson(),
  });
  // Keep at most one active confirmed boundary / domain / goal for V0.2.
  tx.execute(
    "UPDATE portrait_versions SET lifecycle = 'superseded', "
    'updated_at_us = ? '
    "WHERE owner_id = ? AND lifecycle = 'active'",
    [now, command.ownerId],
  );
  tx.execute(
    "UPDATE active_domains SET status = 'archived', archived_at_us = ?, "
    'updated_at_us = ? WHERE owner_id = ? AND status = ?',
    [now, now, command.ownerId, 'active'],
  );
  tx.execute(
    "UPDATE goals SET status = 'archived', archived_at_us = ?, "
    'updated_at_us = ? WHERE owner_id = ? AND status = ?',
    [now, now, command.ownerId, 'active'],
  );
  final ordinalRows = tx.select(
    'SELECT COALESCE(MAX(ordinal), 0) AS max_ordinal '
    'FROM portrait_versions WHERE owner_id = ?',
    [command.ownerId],
  );
  final nextOrdinal = (ordinalRows.single['max_ordinal'] as int) + 1;
  tx.execute(
    'INSERT INTO identity_drafts '
    '(id,owner_id,status,version,current_identity_text,target_identity_text,'
    'answers_json,data_sufficiency,source_type,based_on_portrait_version_id,'
    'submitted_at_us,confirmed_at_us,superseded_by_draft_id,'
    'created_at_us,updated_at_us) '
    "VALUES (?,?, 'confirmed',1,NULL,NULL,?, 'sufficient','user_declared',"
    'NULL,?,?,NULL,?,?)',
    [draftId, command.ownerId, answersJson, now, now, now, now],
  );
  tx.execute(
    'INSERT INTO portrait_versions '
    '(id,owner_id,ordinal,lifecycle,kind,snapshot_json,change_summary,'
    'confirmation_source,confirmed_draft_id,accepted_candidate_id,'
    'based_on_version_id,restored_from_version_id,activated_at_us,'
    'created_at_us,updated_at_us) '
    "VALUES (?,?,?,'active','confirmed',?,"
    "'user_confirmed_journey_boundary','user_explicit',?,NULL,NULL,NULL,"
    '?,?,?)',
    [
      portraitId,
      command.ownerId,
      nextOrdinal,
      snapshotJson,
      draftId,
      now,
      now,
      now,
    ],
  );
  tx.execute(
    'INSERT INTO active_domains '
    '(id,owner_id,domain_code,status,priority,version,'
    'source_portrait_version_id,paused_at_us,archived_at_us,'
    'created_at_us,updated_at_us) '
    "VALUES (?,?,?,'active',1,1,?,NULL,NULL,?,?)",
    [domainId, command.ownerId, command.domainCode, portraitId, now, now],
  );
  tx.execute(
    'INSERT INTO goals '
    '(id,owner_id,domain_id,status,version,title,description,'
    'identity_gap_json,data_sufficiency,source_type,'
    'source_portrait_version_id,target_at_us,paused_at_us,completed_at_us,'
    'archived_at_us,created_at_us,updated_at_us) '
    "VALUES (?,?,?,'active',1,?,NULL,?,'sufficient','user_declared',"
    '?,NULL,NULL,NULL,NULL,?,?)',
    [
      goalId,
      command.ownerId,
      domainId,
      command.goalTitle,
      answersJson,
      portraitId,
      now,
      now,
    ],
  );
  tx.execute(
    'INSERT INTO milestones '
    '(id,owner_id,goal_id,status,version,title,sequence_no,rule_type,'
    'rule_json,starts_at_us,target_at_us,achieved_at_us,superseded_by_id,'
    'created_at_us,updated_at_us) '
    "VALUES (?,?,?,'not_started',1,?,1,'evidence',?,NULL,NULL,NULL,NULL,?,?)",
    [
      milestoneId,
      command.ownerId,
      goalId,
      command.milestone.title,
      journeyCanonicalJson({
        'evidence_rule': command.milestone.evidenceRule,
        'window': command.milestone.window,
      }),
      now,
      now,
    ],
  );
}

void ensureGuestSubjectAndDevice(
  Database tx,
  ConfirmJourneyBoundaryCommand command,
) {
  final subjects = tx.select(
    'SELECT id FROM subjects WHERE id = ?',
    [command.ownerId],
  );
  if (subjects.isEmpty) {
    tx.execute(
      'INSERT INTO subjects VALUES (?, ?, ?, ?, ?)',
      [
        command.ownerId,
        command.subjectKind,
        'active',
        command.occurredAtUs,
        command.occurredAtUs,
      ],
    );
  }
  final devices = tx.select(
    'SELECT id FROM devices WHERE owner_id = ? AND id = ?',
    [command.ownerId, command.deviceId],
  );
  if (devices.isEmpty) {
    tx.execute(
      'INSERT INTO devices VALUES (?, ?, ?, ?, ?, 1, ?, ?, ?)',
      [
        command.deviceId,
        command.ownerId,
        command.platform,
        command.appVersion,
        command.installationId,
        command.occurredAtUs,
        command.occurredAtUs,
        command.occurredAtUs,
      ],
    );
  }
}

int nextDeviceSeq(
  Database tx,
  String ownerId,
  String deviceId,
  int nowUs,
) {
  final rows = tx.select(
    'SELECT next_device_seq FROM devices WHERE owner_id = ? AND id = ?',
    [ownerId, deviceId],
  );
  if (rows.isEmpty) {
    throw const OwnerScopeViolation();
  }
  final seq = rows.single['next_device_seq'] as int;
  tx.execute(
    'UPDATE devices SET next_device_seq = ?, updated_at_us = ? '
    'WHERE owner_id = ? AND id = ?',
    [seq + 1, nowUs, ownerId, deviceId],
  );
  return seq;
}
