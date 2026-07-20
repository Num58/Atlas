import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';
import '../portrait_repository.dart';

/// DDL mirrored from `schema.sql` (portrait_versions table only).
const String _schemaSql = '''
CREATE TABLE IF NOT EXISTS portrait_versions (
  version_id        TEXT PRIMARY KEY,
  created_at        INTEGER NOT NULL,
  snapshot          TEXT NOT NULL,
  change_summary    TEXT NOT NULL,
  consent_record_id TEXT NOT NULL
);
''';

Map<String, Object?> _snapshotToJson(ProfileSnapshot s) => {
      'fields': s.fields,
      'active_dimensions': s.activeDimensions,
      'inactive_dimensions': s.inactiveDimensions,
    };

ProfileSnapshot _snapshotFromJson(Map<String, Object?> json) {
  final fields = json['fields'];
  final active = json['active_dimensions'];
  final inactive = json['inactive_dimensions'];
  return ProfileSnapshot(
    fields: fields is Map
        ? (fields).cast<String, Object?>()
        : <String, Object?>{},
    activeDimensions:
        active is List ? List<String>.from(active) : <String>[],
    inactiveDimensions:
        inactive is List ? List<String>.from(inactive) : <String>[],
  );
}

/// SQLite-backed [PortraitRepository]. Pure-Dart `sqlite3` binding only.
class SqlitePortraitRepository implements PortraitRepository {
  final Database _db;

  SqlitePortraitRepository._(this._db) {
    _db.execute(_schemaSql);
  }

  factory SqlitePortraitRepository.inMemory() =>
      SqlitePortraitRepository._(sqlite3.openInMemory());

  factory SqlitePortraitRepository.file(String path) =>
      SqlitePortraitRepository._(sqlite3.open(path));

  @override
  void save(PortraitVersion version) {
    _db.execute(
      'INSERT OR REPLACE INTO portrait_versions '
      '(version_id, created_at, snapshot, change_summary, consent_record_id) '
      'VALUES (?, ?, ?, ?, ?)',
      [
        version.versionId,
        version.createdAt,
        jsonEncode(_snapshotToJson(version.snapshot)),
        version.changeSummary,
        version.consentRecordId,
      ],
    );
  }

  @override
  PortraitVersion? get(String versionId) {
    final rows = _db.select(
        'SELECT version_id, created_at, snapshot, change_summary, consent_record_id '
        'FROM portrait_versions WHERE version_id = ?',
        [versionId]);
    if (rows.isEmpty) return null;
    return _rowToVersion(rows.first);
  }

  @override
  List<PortraitVersion> list({int? limit}) {
    final rows = _db.select(
        'SELECT version_id, created_at, snapshot, change_summary, consent_record_id '
        'FROM portrait_versions ORDER BY created_at DESC, version_id DESC');
    // _db.select() returns a `ResultSet`; `.sublist()` yields a plain List
    // that is not assignable back to a ResultSet-typed variable. Take the
    // prefix as a fresh List to keep both branches the same static type.
    final effective =
        (limit != null) ? rows.take(limit).toList() : rows;
    return effective.map(_rowToVersion).toList();
  }

  PortraitVersion _rowToVersion(Map<String, Object?> row) {
    final raw = row['snapshot'];
    final Map<String, Object?> snapshotJson =
        (raw is String ? jsonDecode(raw) : raw) as Map<String, Object?>;
    return PortraitVersion(
      versionId: row['version_id'] as String,
      createdAt: row['created_at'] as int,
      snapshot: _snapshotFromJson(snapshotJson),
      changeSummary: row['change_summary'] as String,
      consentRecordId: row['consent_record_id'] as String,
    );
  }

  void close() => _db.dispose();
}
