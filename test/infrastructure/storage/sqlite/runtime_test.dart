import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/baseline_migration.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/migration_runner.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/operation_ledger_repository.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/prime_atlas_database.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/unit_of_work.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  const migration = Migration(
    version: 1,
    name: 'test',
    sql: '''
      CREATE TABLE subjects(id TEXT PRIMARY KEY);
      CREATE TABLE devices(id TEXT PRIMARY KEY, owner_id TEXT NOT NULL,
        next_device_seq INTEGER NOT NULL, UNIQUE(owner_id,id),
        FOREIGN KEY(owner_id) REFERENCES subjects(id));
      CREATE TABLE operation_ledger(
        id TEXT PRIMARY KEY, owner_id TEXT NOT NULL, operation_id TEXT NOT NULL,
        device_id TEXT NOT NULL, device_seq INTEGER NOT NULL,
        operation_type TEXT NOT NULL, entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL, base_version INTEGER, payload_json TEXT NOT NULL,
        payload_hash TEXT NOT NULL, result_json TEXT, state TEXT NOT NULL,
        error_code TEXT, created_at_us INTEGER NOT NULL, updated_at_us INTEGER NOT NULL,
        UNIQUE(owner_id, operation_id), UNIQUE(owner_id, device_id, device_seq),
        FOREIGN KEY(owner_id) REFERENCES subjects(id),
        FOREIGN KEY(owner_id, device_id) REFERENCES devices(owner_id,id));
    ''',
  );

  test('frozen baseline is embedded and bootstraps its migration ledger', () {
    final baseline = loadBaselineMigration();
    expect(identical(baseline, baselineMigration), isTrue);
    expect(baseline.sql, contains('CREATE TABLE operation_ledger'));
    final db = PrimeAtlasDatabase.openInMemory(
      [baseline],
      appVersion: '0.2.0+2',
      appliedAtUs: 1,
    );
    expect(
      db.connection
          .select('SELECT count(*) AS n FROM schema_migrations')
          .single['n'],
      1,
    );
    expect(
      db.connection.select(
        "SELECT name FROM sqlite_master WHERE name = 'operation_ledger'",
      ),
      isNotEmpty,
    );
    db.close();
  });

  test('migration checksum drift is rejected without side effects', () {
    final db = PrimeAtlasDatabase.openInMemory(
      [migration],
      appVersion: 'test',
      appliedAtUs: 1,
    );
    const drifted = Migration(
      version: 1,
      name: 'test',
      sql: 'CREATE TABLE changed(id INTEGER);',
    );
    expect(
      () => MigrationRunner.apply(
        db.connection,
        [drifted],
        appVersion: 'test',
        appliedAtUs: 2,
      ),
      throwsStateError,
    );
    expect(
      db.connection.select(
        "SELECT name FROM sqlite_master WHERE name = 'changed'",
      ),
      isEmpty,
    );
    db.close();
  });

  test('connection applies SQLite safety pragmas and migrations idempotently',
      () {
    final db = PrimeAtlasDatabase.openInMemory(
      [migration],
      appVersion: 'test',
      appliedAtUs: 1,
    );
    expect(
        db.connection.select('PRAGMA foreign_keys').single['foreign_keys'], 1);
    expect(db.connection.select('PRAGMA synchronous').single['synchronous'], 2);
    expect(
        db.connection
            .select('SELECT count(*) AS n FROM schema_migrations')
            .single['n'],
        1);
    MigrationRunner.apply(
      db.connection,
      [migration],
      appVersion: 'test',
      appliedAtUs: 1,
    );
    expect(
        db.connection
            .select('SELECT count(*) AS n FROM schema_migrations')
            .single['n'],
        1);
    db.close();
  });

  test('file runtime persists migrated data across reopen', () {
    final directory = Directory.systemTemp.createTempSync('primeatlas-sqlite-');
    try {
      final path = '${directory.path}${Platform.pathSeparator}primeatlas.db';
      final first = PrimeAtlasDatabase.open(
        path,
        [migration],
        appVersion: 'test',
        appliedAtUs: 1,
      );
      first.connection.execute("INSERT INTO subjects VALUES ('owner-a')");
      first.close();
      final reopened = PrimeAtlasDatabase.open(
        path,
        [migration],
        appVersion: 'test',
        appliedAtUs: 2,
      );
      expect(
        reopened.connection
            .select('SELECT count(*) AS n FROM subjects')
            .single['n'],
        1,
      );
      reopened.close();
    } finally {
      directory.deleteSync(recursive: true);
    }
  });

  test('migration plan rejects duplicate versions before changing schema', () {
    final database = sqlite3.openInMemory();
    expect(
      () => MigrationRunner.apply(
        database,
        const [
          Migration(version: 1, name: 'first', sql: 'CREATE TABLE a(id);'),
          Migration(version: 1, name: 'second', sql: 'CREATE TABLE b(id);'),
        ],
        appVersion: 'test',
        appliedAtUs: 1,
      ),
      throwsStateError,
    );
    expect(
      database.select("SELECT name FROM sqlite_master WHERE name IN ('a','b')"),
      isEmpty,
    );
    database.dispose();
  });

  test('migration failure rolls back schema and ledger row', () {
    final database = sqlite3.openInMemory();
    database.execute(
      'CREATE TABLE schema_migrations ('
      'version INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, '
      'checksum TEXT NOT NULL, applied_at_us INTEGER NOT NULL, '
      'app_version TEXT NOT NULL)',
    );
    const broken = Migration(
      version: 2,
      name: 'broken',
      sql: 'CREATE TABLE partial(id INTEGER); INVALID SQL;',
    );
    expect(
      () => MigrationRunner.apply(
        database,
        [broken],
        appVersion: 'test',
        appliedAtUs: 1,
      ),
      throwsA(isA<SqliteException>()),
    );
    expect(
      database.select(
        "SELECT name FROM sqlite_master WHERE name = 'partial'",
      ),
      isEmpty,
    );
    expect(
      database
          .select('SELECT count(*) AS n FROM schema_migrations')
          .single['n'],
      0,
    );
    database.dispose();
  });

  test('unit of work rolls back all writes when callback fails', () {
    final db = PrimeAtlasDatabase.openInMemory(
      [migration],
      appVersion: 'test',
      appliedAtUs: 1,
    );
    final uow = SqliteUnitOfWork(db.connection);
    expect(
        () => uow.run((tx) {
              tx.execute("INSERT INTO subjects VALUES ('owner-a')");
              throw StateError('injected');
            }),
        throwsStateError);
    expect(
        db.connection.select('SELECT count(*) AS n FROM subjects').single['n'],
        0);
    db.close();
  });

  test('ledger replays exact payload and rejects hash reuse across owners', () {
    final db = PrimeAtlasDatabase.openInMemory(
      [migration],
      appVersion: 'test',
      appliedAtUs: 1,
    );
    db.connection
        .execute("INSERT INTO subjects VALUES ('owner-a'), ('owner-b')");
    db.connection.execute(
        "INSERT INTO devices VALUES ('device-a','owner-a',1), ('device-b','owner-b',1)");
    final ledger = OperationLedgerRepository(db.connection);
    final first = OperationLedgerEntry.committed(
        id: 'entry-a',
        ownerId: 'owner-a',
        operationId: 'op-1',
        deviceId: 'device-a',
        deviceSeq: 1,
        operationType: 'create',
        entityType: 'goal',
        entityId: 'goal-a',
        payloadJson: '{}',
        payloadHash: 'a' * 64,
        resultJson: '{"ok":true}',
        nowUs: 1);
    ledger.record(first);
    final replay = ledger.ensureReplayable('owner-a', 'op-1', 'a' * 64);
    expect(replay?.resultJson, '{"ok":true}');
    expect(
      db.connection
          .select('SELECT count(*) AS n FROM operation_ledger')
          .single['n'],
      1,
    );
    expect(() => ledger.ensureReplayable('owner-a', 'op-1', 'b' * 64),
        throwsA(isA<IdempotencyKeyReused>()));
    expect(ledger.find('owner-b', 'op-1'), isNull);
    expect(
      () => ledger.find('', 'op-1'),
      throwsA(isA<OwnerScopeViolation>()),
    );
    expect(
      () => ledger.record(
        OperationLedgerEntry.committed(
          id: 'cross-owner',
          ownerId: 'owner-b',
          operationId: 'op-2',
          deviceId: 'device-a',
          deviceSeq: 2,
          operationType: 'create',
          entityType: 'goal',
          entityId: 'goal-b',
          payloadJson: '{}',
          payloadHash: 'c' * 64,
          resultJson: '{}',
          nowUs: 2,
        ),
      ),
      throwsA(isA<SqliteException>()),
    );
    db.close();
  });
}
