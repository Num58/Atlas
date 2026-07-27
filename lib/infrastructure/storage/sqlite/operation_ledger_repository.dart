import 'package:sqlite3/sqlite3.dart';

class IdempotencyKeyReused implements Exception {
  const IdempotencyKeyReused();
}

class OwnerScopeViolation implements Exception {
  const OwnerScopeViolation();
}

class OperationLedgerEntry {
  const OperationLedgerEntry({
    required this.id,
    required this.ownerId,
    required this.operationId,
    required this.deviceId,
    required this.deviceSeq,
    required this.operationType,
    required this.entityType,
    required this.entityId,
    required this.payloadJson,
    required this.payloadHash,
    required this.resultJson,
    required this.state,
    required this.errorCode,
    required this.createdAtUs,
    this.baseVersion,
  });

  factory OperationLedgerEntry.committed({
    required String id,
    required String ownerId,
    required String operationId,
    required String deviceId,
    required int deviceSeq,
    required String operationType,
    required String entityType,
    required String entityId,
    required String payloadJson,
    required String payloadHash,
    required String resultJson,
    required int nowUs,
    int? baseVersion,
  }) =>
      OperationLedgerEntry(
        id: id,
        ownerId: ownerId,
        operationId: operationId,
        deviceId: deviceId,
        deviceSeq: deviceSeq,
        operationType: operationType,
        entityType: entityType,
        entityId: entityId,
        baseVersion: baseVersion,
        payloadJson: payloadJson,
        payloadHash: payloadHash,
        resultJson: resultJson,
        state: 'committed',
        errorCode: null,
        createdAtUs: nowUs,
      );

  final String id;
  final String ownerId;
  final String operationId;
  final String deviceId;
  final int deviceSeq;
  final String operationType;
  final String entityType;
  final String entityId;
  final int? baseVersion;
  final String payloadJson;
  final String payloadHash;
  final String? resultJson;
  final String state;
  final String? errorCode;
  final int createdAtUs;

  static OperationLedgerEntry fromRow(Row row) => OperationLedgerEntry(
        id: row['id'] as String,
        ownerId: row['owner_id'] as String,
        operationId: row['operation_id'] as String,
        deviceId: row['device_id'] as String,
        deviceSeq: row['device_seq'] as int,
        operationType: row['operation_type'] as String,
        entityType: row['entity_type'] as String,
        entityId: row['entity_id'] as String,
        baseVersion: row['base_version'] as int?,
        payloadJson: row['payload_json'] as String,
        payloadHash: row['payload_hash'] as String,
        resultJson: row['result_json'] as String?,
        state: row['state'] as String,
        errorCode: row['error_code'] as String?,
        createdAtUs: row['created_at_us'] as int,
      );
}

class OperationLedgerRepository {
  const OperationLedgerRepository(this.database);
  final Database database;

  OperationLedgerEntry? find(String ownerId, String operationId) {
    _requireScope(ownerId, operationId);
    final rows = database.select(
      'SELECT * FROM operation_ledger '
      'WHERE owner_id = ? AND operation_id = ?',
      [ownerId, operationId],
    );
    return rows.isEmpty ? null : OperationLedgerEntry.fromRow(rows.single);
  }

  OperationLedgerEntry? ensureReplayable(
    String ownerId,
    String operationId,
    String payloadHash,
  ) {
    final stored = find(ownerId, operationId);
    if (stored != null && stored.payloadHash != payloadHash) {
      throw const IdempotencyKeyReused();
    }
    return stored;
  }

  void record(OperationLedgerEntry entry) {
    _requireScope(entry.ownerId, entry.operationId);
    if (entry.deviceId.trim().isEmpty || entry.entityId.trim().isEmpty) {
      throw const OwnerScopeViolation();
    }
    database.execute(
      'INSERT INTO operation_ledger '
      '(id,owner_id,operation_id,device_id,device_seq,operation_type,'
      'entity_type,entity_id,base_version,payload_json,payload_hash,'
      'result_json,state,error_code,created_at_us,updated_at_us) '
      'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
      [
        entry.id,
        entry.ownerId,
        entry.operationId,
        entry.deviceId,
        entry.deviceSeq,
        entry.operationType,
        entry.entityType,
        entry.entityId,
        entry.baseVersion,
        entry.payloadJson,
        entry.payloadHash,
        entry.resultJson,
        entry.state,
        entry.errorCode,
        entry.createdAtUs,
        entry.createdAtUs,
      ],
    );
  }

  static void _requireScope(String ownerId, String operationId) {
    if (ownerId.trim().isEmpty || operationId.trim().isEmpty) {
      throw const OwnerScopeViolation();
    }
  }
}
