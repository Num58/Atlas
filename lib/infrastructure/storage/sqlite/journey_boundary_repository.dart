import 'dart:convert';

import 'package:primeatlas/core/journey/journey_boundary.dart';
import 'package:primeatlas/core/journey/journey_boundary_repository.dart';
import 'package:sqlite3/sqlite3.dart';

import 'journey_boundary_history.dart';
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
      'SELECT id, snapshot_json, confirmed_draft_id, activated_at_us, kind '
      'FROM portrait_versions '
      "WHERE owner_id = ? AND lifecycle = 'active' "
      "AND kind IN ('confirmed','restored') "
      'ORDER BY activated_at_us DESC, id DESC LIMIT 1',
      [ownerId],
    );
    if (portraitRows.isEmpty) return null;
    return confirmedFromPortraitRow(database, ownerId, portraitRows.single);
  }

  @override
  List<BoundaryVersionSummary> listBoundaryVersions(String ownerId) {
    if (ownerId.trim().isEmpty) {
      throw const OwnerScopeViolation();
    }
    return queryBoundaryVersions(database, ownerId);
  }

  @override
  ConfirmedJourneyBoundary restoreVersion(
    RestoreBoundaryVersionCommand command,
  ) {
    final payloadJson = journeyCanonicalJson({
      'version_id': command.versionId,
      'action': 'restore',
    });
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

    return _unitOfWork.run(
      (tx) => restoreBoundaryVersionInTransaction(
        tx,
        command,
        payloadJson: payloadJson,
        payloadHash: payloadHash,
      ),
    );
  }
}

/// Public alias for tests asserting hash length/format.
String sha256Hex(String input) => journeySha256Hex(input);
