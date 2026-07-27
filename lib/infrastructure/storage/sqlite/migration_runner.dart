import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqlite3/sqlite3.dart';

class Migration {
  const Migration({
    required this.version,
    required this.name,
    required this.sql,
  });

  final int version;
  final String name;
  final String sql;

  String get checksum =>
      sha256.convert(utf8.encode(_normalizeSql(sql))).toString();
}

String _normalizeSql(String sql) => sql
    .replaceFirst('\uFEFF', '')
    .replaceAll('\r\n', '\n')
    .replaceAll('\r', '\n');

class MigrationRunner {
  static void apply(
    Database db,
    List<Migration> migrations, {
    required String appVersion,
    required int appliedAtUs,
  }) {
    final sorted = [...migrations]
      ..sort((a, b) => a.version.compareTo(b.version));
    _validatePlan(sorted);
    _validateDatabaseIntegrity(db);
    if (!_hasMigrationLedger(db)) {
      if (sorted.isNotEmpty && _createsMigrationLedger(sorted.first.sql)) {
        _applyBootstrap(
          db,
          sorted.removeAt(0),
          appVersion: appVersion,
          appliedAtUs: appliedAtUs,
        );
      } else {
        _createMigrationLedger(db);
      }
    }
    for (final migration in sorted) {
      final rows = db.select(
        'SELECT checksum, name FROM schema_migrations WHERE version = ?',
        [migration.version],
      );
      if (rows.isNotEmpty) {
        if (rows.single['checksum'] != migration.checksum ||
            rows.single['name'] != migration.name) {
          throw StateError('local_migration_failed');
        }
        continue;
      }
      db.execute('BEGIN IMMEDIATE');
      try {
        db.execute(_transactionalSql(migration.sql));
        if (db.select('PRAGMA foreign_key_check').isNotEmpty) {
          throw StateError('local_migration_failed');
        }
        db.execute(
          'INSERT INTO schema_migrations VALUES (?, ?, ?, ?, ?)',
          [
            migration.version,
            migration.name,
            migration.checksum,
            appliedAtUs,
            appVersion,
          ],
        );
        db.execute('COMMIT');
      } catch (_) {
        db.execute('ROLLBACK');
        rethrow;
      }
    }
  }

  static void _validateDatabaseIntegrity(Database db) {
    final integrity = db.select('PRAGMA integrity_check');
    if (integrity.isEmpty || integrity.single.values.first != 'ok') {
      throw StateError('local_migration_failed');
    }
    if (db.select('PRAGMA foreign_key_check').isNotEmpty) {
      throw StateError('local_migration_failed');
    }
  }

  static bool _hasMigrationLedger(Database db) => db
      .select(
        "SELECT 1 FROM sqlite_master WHERE type='table' "
        "AND name='schema_migrations'",
      )
      .isNotEmpty;

  static bool _createsMigrationLedger(String sql) => RegExp(
        r'create\s+table(?:\s+if\s+not\s+exists)?\s+schema_migrations\b',
        caseSensitive: false,
      ).hasMatch(sql);

  static void _createMigrationLedger(Database db) {
    db.execute(
      'CREATE TABLE schema_migrations ('
      'version INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, '
      'checksum TEXT NOT NULL, applied_at_us INTEGER NOT NULL, '
      'app_version TEXT NOT NULL)',
    );
  }

  static void _applyBootstrap(
    Database db,
    Migration migration, {
    required String appVersion,
    required int appliedAtUs,
  }) {
    db.execute('BEGIN IMMEDIATE');
    try {
      db.execute(_transactionalSql(migration.sql));
      if (db.select('PRAGMA foreign_key_check').isNotEmpty) {
        throw StateError('local_migration_failed');
      }
      db.execute(
        'INSERT INTO schema_migrations VALUES (?, ?, ?, ?, ?)',
        [
          migration.version,
          migration.name,
          migration.checksum,
          appliedAtUs,
          appVersion,
        ],
      );
      db.execute('COMMIT');
    } catch (_) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  static String _transactionalSql(String sql) => sql
      .split('\n')
      .where((line) => !RegExp(
            r'^\s*pragma\s+(foreign_keys|journal_mode|synchronous|busy_timeout)\s*=',
            caseSensitive: false,
          ).hasMatch(line))
      .join('\n');

  static void _validatePlan(List<Migration> migrations) {
    final versions = <int>{};
    final names = <String>{};
    for (final migration in migrations) {
      if (migration.version < 1 ||
          migration.name.trim().isEmpty ||
          !versions.add(migration.version) ||
          !names.add(migration.name)) {
        throw StateError('local_migration_failed');
      }
    }
  }
}
