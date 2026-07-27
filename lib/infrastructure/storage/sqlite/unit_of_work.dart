import 'package:sqlite3/sqlite3.dart';

abstract interface class UnitOfWork {
  T run<T>(T Function(Database transaction) action);
}

class SqliteUnitOfWork implements UnitOfWork {
  const SqliteUnitOfWork(this.database);
  final Database database;

  @override
  T run<T>(T Function(Database transaction) action) {
    database.execute('BEGIN IMMEDIATE');
    try {
      final value = action(database);
      database.execute('COMMIT');
      return value;
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }
  }
}
