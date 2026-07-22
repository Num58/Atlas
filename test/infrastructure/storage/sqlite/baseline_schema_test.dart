import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

const _migrationPath =
    'lib/infrastructure/storage/sqlite/migrations/0001_baseline.sql';
const _snapshotPath =
    'test/infrastructure/storage/sqlite/snapshots/0001_baseline_schema.json';

void main() {
  late Database db;

  setUp(() {
    db = sqlite3.openInMemory();
    db.execute(File(_migrationPath).readAsStringSync());
  });

  tearDown(() => db.dispose());

  test('0001 creates the exact schema snapshot and valid foreign keys', () {
    final actual = {
      'tables': _names(db, 'table'),
      'indexes': _names(db, 'index'),
    };
    final expected = jsonDecode(File(_snapshotPath).readAsStringSync());

    expect(actual, expected);
    expect(db.select('PRAGMA foreign_key_check'), isEmpty);
    expect(db.select('PRAGMA foreign_keys').single['foreign_keys'], 1);
  });

  test('partial unique indexes reject duplicate current states', () {
    _seedOwnerGraph(db, owner: 'owner-a', device: 'device-a');
    _insertPortrait(db, owner: 'owner-a', id: 'portrait-a', ordinal: 1);

    expect(
      () => _insertPortrait(db, owner: 'owner-a', id: 'portrait-b', ordinal: 2),
      throwsA(isA<SqliteException>()),
    );

    _insertDomain(db, owner: 'owner-a', id: 'domain-1', priority: 1);
    expect(
      () => _insertDomain(db, owner: 'owner-a', id: 'domain-2', priority: 1),
      throwsA(isA<SqliteException>()),
    );
  });

  test('composite foreign keys reject cross-owner relationships', () {
    _seedOwnerGraph(db, owner: 'owner-a', device: 'device-a');
    _seedOwnerGraph(db, owner: 'owner-b', device: 'device-b');
    _insertPortrait(db, owner: 'owner-a', id: 'portrait-a', ordinal: 1);

    expect(
      () => _insertDomain(
        db,
        owner: 'owner-b',
        id: 'cross-owner-domain',
        priority: 1,
        portraitId: 'portrait-a',
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('event and ledger device sequence constraints are owner scoped', () {
    _seedOwnerGraph(db, owner: 'owner-a', device: 'device-a');
    _insertLedger(db, id: 'ledger-1', operation: 'op-1', sequence: 1);

    expect(
      () => _insertLedger(db, id: 'ledger-2', operation: 'op-2', sequence: 1),
      throwsA(isA<SqliteException>()),
    );
    expect(
      () => _insertLedger(db, id: 'ledger-3', operation: 'op-1', sequence: 2),
      throwsA(isA<SqliteException>()),
    );
  });

  test('ledger terminal state fields are mutually consistent', () {
    _seedOwnerGraph(db, owner: 'owner-a', device: 'device-a');

    expect(
      () => _insertLedger(
        db,
        id: 'bad-committed',
        operation: 'op-bad-1',
        sequence: 1,
        resultJson: null,
      ),
      throwsA(isA<SqliteException>()),
    );
    expect(
      () => _insertLedger(
        db,
        id: 'bad-rejected',
        operation: 'op-bad-2',
        sequence: 2,
        state: 'rejected',
        resultJson: '{}',
        errorCode: 'validation_failed',
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('three active priorities form the physical domain upper bound', () {
    _seedOwnerGraph(db, owner: 'owner-a', device: 'device-a');
    _insertPortrait(db, owner: 'owner-a', id: 'portrait-a', ordinal: 1);
    for (var priority = 1; priority <= 3; priority++) {
      _insertDomain(
        db,
        owner: 'owner-a',
        id: 'domain-$priority',
        priority: priority,
      );
    }

    expect(
      () => _insertDomain(db, owner: 'owner-a', id: 'domain-4', priority: 4),
      throwsA(isA<SqliteException>()),
    );
    expect(
      db
          .select(
              "SELECT count(*) AS count FROM active_domains WHERE status='active'")
          .single['count'],
      3,
    );
  });

  test('baseline excludes remote and destructive persistence objects', () {
    final sql = File(_migrationPath).readAsStringSync().toLowerCase();
    final tables = _names(db, 'table');

    expect(tables, isNot(contains('sync_operations')));
    expect(tables.any((name) => name.contains('tombstone')), isFalse);
    expect(sql, isNot(contains('retain_until')));
    expect(sql, isNot(contains("'delete'")));
    expect(sql, isNot(contains("'syncing'")));
    expect(sql, isNot(contains("'synced'")));
  });
}

List<String> _names(Database db, String type) => db
    .select(
      "SELECT name FROM sqlite_master WHERE type=? AND name NOT LIKE 'sqlite_%' ORDER BY name",
      [type],
    )
    .map((row) => row['name'] as String)
    .toList();

void _seedOwnerGraph(
  Database db, {
  required String owner,
  required String device,
}) {
  db.execute(
    'INSERT INTO subjects VALUES (?, ?, ?, ?, ?)',
    [owner, owner == 'owner-a' ? 'guest' : 'local_account', 'active', 1, 1],
  );
  db.execute(
    'INSERT INTO devices VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [device, owner, 'test', '0.2.0+2', 'install-$owner', 1, 1, 1, 1],
  );
}

void _insertPortrait(
  Database db, {
  required String owner,
  required String id,
  required int ordinal,
}) {
  db.execute(
    'INSERT INTO portrait_versions '
    '(id,owner_id,ordinal,lifecycle,kind,snapshot_json,change_summary,'
    'confirmation_source,confirmed_draft_id,accepted_candidate_id,'
    'based_on_version_id,restored_from_version_id,activated_at_us,'
    'created_at_us,updated_at_us) '
    "VALUES (?,?,?,'active','restored','{}','fixture','user_explicit',"
    'NULL,NULL,NULL,?,1,1,1)',
    [id, owner, ordinal, id],
  );
}

void _insertDomain(
  Database db, {
  required String owner,
  required String id,
  required int priority,
  String portraitId = 'portrait-a',
}) {
  db.execute(
    'INSERT INTO active_domains VALUES '
    "(?,?,?,'active',?,1,?,NULL,NULL,1,1)",
    [id, owner, 'code-$id', priority, portraitId],
  );
}

void _insertLedger(
  Database db, {
  required String id,
  required String operation,
  required int sequence,
  String state = 'committed',
  String? resultJson = '{}',
  String? errorCode,
}) {
  db.execute(
    'INSERT INTO operation_ledger '
    '(id,owner_id,operation_id,device_id,device_seq,operation_type,'
    'entity_type,entity_id,base_version,payload_json,payload_hash,'
    'result_json,state,error_code,created_at_us,updated_at_us) '
    "VALUES (?,'owner-a',?,'device-a',?,'create','identity_draft',"
    "'draft-a',NULL,'{}',?, ?, ?, ?,1,1)",
    [id, operation, sequence, 'a' * 64, resultJson, state, errorCode],
  );
}
