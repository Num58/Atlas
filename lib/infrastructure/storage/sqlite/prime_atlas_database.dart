import 'package:sqlite3/sqlite3.dart';

import 'migration_runner.dart';

class PrimeAtlasDatabase {
  PrimeAtlasDatabase._(this.connection);
  final Database connection;

  static PrimeAtlasDatabase open(
    String path,
    List<Migration> migrations, {
    required String appVersion,
    required int appliedAtUs,
  }) {
    if (path.trim().isEmpty) {
      throw ArgumentError.value(
          path, 'path', 'Database path must not be empty');
    }
    final database = sqlite3.open(path);
    return _initialize(
      database,
      migrations,
      appVersion: appVersion,
      appliedAtUs: appliedAtUs,
    );
  }

  static PrimeAtlasDatabase openInMemory(
    List<Migration> migrations, {
    required String appVersion,
    required int appliedAtUs,
  }) {
    return _initialize(
      sqlite3.openInMemory(),
      migrations,
      appVersion: appVersion,
      appliedAtUs: appliedAtUs,
    );
  }

  static PrimeAtlasDatabase _initialize(
    Database database,
    List<Migration> migrations, {
    required String appVersion,
    required int appliedAtUs,
  }) {
    try {
      database.execute('PRAGMA foreign_keys = ON');
      database.execute('PRAGMA journal_mode = WAL');
      database.execute('PRAGMA synchronous = FULL');
      database.execute('PRAGMA busy_timeout = 1000');
      MigrationRunner.apply(
        database,
        migrations,
        appVersion: appVersion,
        appliedAtUs: appliedAtUs,
      );
      return PrimeAtlasDatabase._(database);
    } catch (_) {
      database.dispose();
      rethrow;
    }
  }

  void close() => connection.dispose();
}
