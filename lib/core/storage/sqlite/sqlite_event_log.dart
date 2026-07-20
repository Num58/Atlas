import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import '../event_log_repository.dart';

/// DDL mirrored from `schema.sql` so the repository is usable without a Flutter
/// asset bundle (the .sql file remains the canonical source).
const String _schemaSql = '''
CREATE TABLE IF NOT EXISTS events (
  id          TEXT PRIMARY KEY,
  event_type  TEXT NOT NULL,
  payload     TEXT NOT NULL,
  session_id  TEXT,
  created_at  INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_events_type_time ON events(event_type, created_at);
''';

/// SQLite-backed [EventLogRepository]. Uses the pure-Dart `sqlite3` binding.
/// This is the ONLY file in `lib/core` that imports `package:sqlite3`, keeping
/// the native dependency isolated from the rest of the core layer.
class SqliteEventLogRepository implements EventLogRepository {
  final Database _db;

  SqliteEventLogRepository._(this._db) {
    _db.execute(_schemaSql);
  }

  factory SqliteEventLogRepository.inMemory() =>
      SqliteEventLogRepository._(sqlite3.openInMemory());

  factory SqliteEventLogRepository.file(String path) =>
      SqliteEventLogRepository._(sqlite3.open(path));

  @override
  void append(EventRecord record) {
    _db.execute(
      'INSERT INTO events (id, event_type, payload, session_id, created_at) '
      'VALUES (?, ?, ?, ?, ?)',
      [
        record.id,
        record.eventType,
        jsonEncode(record.payload),
        record.sessionId,
        record.createdAt,
      ],
    );
  }

  @override
  List<EventRecord> query(QuerySpec spec) {
    final where = <String>[];
    final args = <Object?>[];

    if (spec.eventTypes.isNotEmpty) {
      where.add(
          'event_type IN (${List.filled(spec.eventTypes.length, '?').join(',')})');
      args.addAll(spec.eventTypes);
    }
    if (spec.from != null) {
      where.add('created_at >= ?');
      args.add(spec.from);
    }
    if (spec.to != null) {
      where.add('created_at <= ?');
      args.add(spec.to);
    }
    if (spec.sessionId != null) {
      where.add('session_id = ?');
      args.add(spec.sessionId);
    }

    final sql = 'SELECT id, event_type, payload, session_id, created_at '
        'FROM events'
        '${where.isNotEmpty ? ' WHERE ${where.join(' AND ')}' : ''} '
        'ORDER BY created_at ASC, id ASC';

    final rows = _db.select(sql, args);
    var result = rows.map((row) {
      final raw = row['payload'];
      final Map<String, Object?> payload =
          (raw is String ? jsonDecode(raw) : raw) as Map<String, Object?>;
      return EventRecord(
        id: row['id'] as String,
        eventType: row['event_type'] as String,
        payload: payload,
        createdAt: row['created_at'] as int,
        sessionId: row['session_id'] as String?,
      );
    }).toList();

    if (spec.limit != null && spec.limit! < result.length) {
      result = result.sublist(0, spec.limit!);
    }
    return result;
  }

  void close() => _db.dispose();
}
