import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/application/journey/confirm_journey_boundary.dart'
    show ConfirmJourneyBoundaryExecutor;
import 'package:primeatlas/core/journey/journey_boundary.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/baseline_migration.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/journey_boundary_ids.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/journey_boundary_repository.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/operation_ledger_repository.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/prime_atlas_database.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/unit_of_work.dart';
import 'package:sqlite3/sqlite3.dart';

ConfirmJourneyBoundaryCommand _command({
  required String ownerId,
  required String operationId,
  required String deviceId,
  String direction = 'Improve deep-work focus for product planning',
  String constraint = 'Max 4 focused sessions per week after 20:00',
  String domainCode = 'cognition',
  String goalTitle = 'Ship a reliable weekly planning loop',
  String subjectKind = 'guest',
}) {
  return ConfirmJourneyBoundaryCommand(
    ownerId: ownerId,
    operationId: operationId,
    deviceId: deviceId,
    installationId: 'install-$ownerId',
    direction: direction,
    constraint: constraint,
    domainCode: domainCode,
    goalTitle: goalTitle,
    milestone: const JourneyMilestoneInput(
      title: 'Complete four consecutive weekly reviews',
      evidenceRule: 'local notes with dated checklists',
      window: '28d',
    ),
    occurredAtUs: 1700000000000000,
    platform: 'test',
    subjectKind: subjectKind,
  );
}

void main() {
  late PrimeAtlasDatabase db;
  late SqliteJourneyBoundaryRepository repository;
  late ConfirmJourneyBoundaryExecutor useCase;

  setUp(() {
    db = PrimeAtlasDatabase.openInMemory(
      [loadBaselineMigration()],
      appVersion: '0.2.0+2',
      appliedAtUs: 1,
    );
    repository = SqliteJourneyBoundaryRepository(db.connection);
    useCase = ConfirmJourneyBoundaryExecutor(repository);
  });

  tearDown(() => db.close());

  test('confirm succeeds and reopens with the same boundary', () {
    final command = _command(
      ownerId: 'owner-a',
      operationId: 'op-confirm-1',
      deviceId: 'device-a',
    );
    final first = useCase.execute(command);
    expect(first.direction, command.direction);
    expect(first.domainCode, 'cognition');
    expect(
      journeySha256Hex(journeyCanonicalJson(command.toPayload())).length,
      64,
    );

    final ledger = OperationLedgerRepository(db.connection)
        .find('owner-a', 'op-confirm-1');
    expect(ledger?.state, 'committed');
    expect(ledger?.payloadHash.length, 64);
    expect(ledger?.payloadHash, ledger!.payloadHash.toLowerCase());

    final directory = Directory.systemTemp.createTempSync('journey-boundary-');
    try {
      final path = '${directory.path}${Platform.pathSeparator}journey.db';
      final fileDb = PrimeAtlasDatabase.open(
        path,
        [loadBaselineMigration()],
        appVersion: '0.2.0+2',
        appliedAtUs: 2,
      );
      final fileRepo = SqliteJourneyBoundaryRepository(fileDb.connection);
      fileRepo.confirm(command);
      fileDb.close();

      final reopened = PrimeAtlasDatabase.open(
        path,
        [loadBaselineMigration()],
        appVersion: '0.2.0+2',
        appliedAtUs: 3,
      );
      final loaded =
          SqliteJourneyBoundaryRepository(reopened.connection)
              .loadLatestConfirmed('owner-a');
      expect(loaded, isNotNull);
      expect(loaded!.goalTitle, command.goalTitle);
      expect(loaded.milestone.title, command.milestone.title);
      expect(loaded.direction, isNot(contains('我想成为')));
      expect(loaded.direction, isNot(contains('我现在是')));
      reopened.close();
    } finally {
      directory.deleteSync(recursive: true);
    }
  });

  test('injected failure rolls back the entire confirmation write set', () {
    final command = _command(
      ownerId: 'owner-a',
      operationId: 'op-fail-1',
      deviceId: 'device-a',
    );
    final failing = SqliteJourneyBoundaryRepository(
      db.connection,
      unitOfWork: _FailingUnitOfWork(db.connection),
    );

    expect(
      () => ConfirmJourneyBoundaryExecutor(failing).execute(command),
      throwsStateError,
    );

    expect(
      db.connection
          .select('SELECT count(*) AS n FROM identity_drafts')
          .single['n'],
      0,
    );
    expect(
      db.connection
          .select('SELECT count(*) AS n FROM portrait_versions')
          .single['n'],
      0,
    );
    expect(
      db.connection
          .select('SELECT count(*) AS n FROM active_domains')
          .single['n'],
      0,
    );
    expect(
      db.connection.select('SELECT count(*) AS n FROM goals').single['n'],
      0,
    );
    expect(
      db.connection.select('SELECT count(*) AS n FROM milestones').single['n'],
      0,
    );
    expect(
      db.connection
          .select('SELECT count(*) AS n FROM operation_ledger')
          .single['n'],
      0,
    );
  });

  test('owner isolation blocks cross-owner reads of confirmed data', () {
    final ownerA = _command(
      ownerId: 'owner-a',
      operationId: 'op-a',
      deviceId: 'device-a',
    );
    final ownerB = _command(
      ownerId: 'owner-b',
      operationId: 'op-b',
      deviceId: 'device-b',
      domainCode: 'body',
      goalTitle: 'Establish a sleep schedule before mid-week training',
      subjectKind: 'local_account',
    );
    useCase.execute(ownerA);
    useCase.execute(ownerB);

    final loadedA = useCase.loadLatestConfirmed('owner-a');
    final loadedB = useCase.loadLatestConfirmed('owner-b');
    expect(loadedA!.ownerId, 'owner-a');
    expect(loadedB!.ownerId, 'owner-b');
    expect(loadedA.goalTitle, isNot(equals(loadedB.goalTitle)));

    final aRows = db.connection.select(
      'SELECT count(*) AS n FROM goals WHERE owner_id = ?',
      ['owner-a'],
    );
    final bRows = db.connection.select(
      'SELECT count(*) AS n FROM goals WHERE owner_id = ?',
      ['owner-b'],
    );
    expect(aRows.single['n'], 1);
    expect(bRows.single['n'], 1);

    // Same operation_id is isolated per owner.
    final again = useCase.execute(ownerA);
    expect(again.portraitVersionId, loadedA.portraitVersionId);
    expect(
      db.connection
          .select(
            "SELECT count(*) AS n FROM operation_ledger WHERE owner_id='owner-a'",
          )
          .single['n'],
      1,
    );
  });

  test('incomplete and identity-like labels are rejected before any write', () {
    expect(
      () => useCase.execute(
        ConfirmJourneyBoundaryCommand(
          ownerId: 'owner-a',
          operationId: 'op-empty',
          deviceId: 'device-a',
          installationId: 'install-a',
          direction: '',
          constraint: 'x',
          domainCode: 'cognition',
          goalTitle: 'y',
          milestone: const JourneyMilestoneInput(
            title: 'm',
            evidenceRule: 'e',
            window: '7d',
          ),
          occurredAtUs: 1,
        ),
      ),
      throwsA(isA<JourneyBoundaryIncomplete>()),
    );
    expect(
      () => useCase.execute(
        _command(
          ownerId: 'owner-a',
          operationId: 'op-identity',
          deviceId: 'device-a',
          direction: '我想成为一名产品总监',
        ),
      ),
      throwsA(isA<JourneyBoundaryIncomplete>()),
    );
    expect(
      db.connection.select('SELECT count(*) AS n FROM subjects').single['n'],
      0,
    );
  });
}

/// Runs the full write set then aborts so UoW must roll back fully.
class _FailingUnitOfWork implements UnitOfWork {
  _FailingUnitOfWork(this.database);
  final Database database;

  @override
  T run<T>(T Function(Database transaction) action) {
    database.execute('BEGIN IMMEDIATE');
    try {
      action(database);
      throw StateError('injected_persistence_failure');
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }
  }
}
