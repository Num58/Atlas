/// 画像版本化类型定义（P3-1）。
///
/// 字段名与序列化键一律 snake_case（ADR-6）。不依赖 `package:flutter`。
library;

/// 单字段变更。
class FieldChange {
  final String fieldName;
  final Object? oldValue;
  final Object? newValue;

  const FieldChange({
    required this.fieldName,
    this.oldValue,
    this.newValue,
  });

  Map<String, Object?> toJson() => {
        'field_name': fieldName,
        'old_value': oldValue,
        'new_value': newValue,
      };

  static FieldChange fromJson(Map<String, Object?> json) => FieldChange(
        fieldName: json['field_name'] as String,
        oldValue: json['old_value'],
        newValue: json['new_value'],
      );
}

/// 画像快照。
///
/// **P-RL1**：`inactiveDimensions` 中的维度不渲染、不占存储。
class ProfileSnapshot {
  final Map<String, Object?> fields;
  final List<String> activeDimensions;
  final List<String> inactiveDimensions;

  const ProfileSnapshot({
    required this.fields,
    required this.activeDimensions,
    required this.inactiveDimensions,
  });

  Map<String, Object?> toJson() => {
        'fields': fields,
        'active_dimensions': activeDimensions,
        'inactive_dimensions': inactiveDimensions,
      };

  static ProfileSnapshot fromJson(Map<String, Object?> json) => ProfileSnapshot(
        fields: (json['fields'] as Map).cast<String, Object?>(),
        activeDimensions: (json['active_dimensions'] as List).cast<String>(),
        inactiveDimensions:
            (json['inactive_dimensions'] as List).cast<String>(),
      );
}

/// 画像版本。
///
/// **P-RL2**：每次版本化必须经 `consentRecordId`（S0 无 system_auto 路径）。
class PortraitVersion {
  final String versionId;
  final int createdAt;
  final ProfileSnapshot snapshot;
  final String changeSummary;
  final String consentRecordId;

  const PortraitVersion({
    required this.versionId,
    required this.createdAt,
    required this.snapshot,
    required this.changeSummary,
    required this.consentRecordId,
  });

  Map<String, Object?> toJson() => {
        'version_id': versionId,
        'created_at': createdAt,
        'snapshot': snapshot.toJson(),
        'change_summary': changeSummary,
        'consent_record_id': consentRecordId,
      };

  static PortraitVersion fromJson(Map<String, Object?> json) => PortraitVersion(
        versionId: json['version_id'] as String,
        createdAt: json['created_at'] as int,
        snapshot:
            ProfileSnapshot.fromJson(json['snapshot'] as Map<String, Object?>),
        changeSummary: json['change_summary'] as String,
        consentRecordId: json['consent_record_id'] as String,
      );
}

/// 两版本之间的差异。
class VersionDiff {
  final String fromVersion;
  final String toVersion;
  final List<FieldChange> changes;
  final bool hasNarratableChange;

  const VersionDiff({
    required this.fromVersion,
    required this.toVersion,
    required this.changes,
    required this.hasNarratableChange,
  });

  Map<String, Object?> toJson() => {
        'from_version': fromVersion,
        'to_version': toVersion,
        'changes': changes.map((c) => c.toJson()).toList(),
        'has_narratable_change': hasNarratableChange,
      };

  static VersionDiff fromJson(Map<String, Object?> json) => VersionDiff(
        fromVersion: json['from_version'] as String,
        toVersion: json['to_version'] as String,
        changes: (json['changes'] as List)
            .map((e) => FieldChange.fromJson(e as Map<String, Object?>))
            .toList(),
        hasNarratableChange: json['has_narratable_change'] as bool,
      );
}
