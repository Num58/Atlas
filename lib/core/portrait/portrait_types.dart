/// 画像类型定义（P3-1）。
///
/// 本文件同时承载两套符号：
/// - 既有契约符号（[ProfileSnapshot] / [FieldChange] / [VersionDiff]），
///   被 `core.dart` 桶文件、`fusion` 与 `storage` 模块引用，保留以不破坏既有调用；
/// - P3-1 目标符号（[PortraitAxis] / [PortraitSnapshot] / [PortraitVersion]），
///   按画像动态更新（动态轴雷达 + 版本化 + 过渡态叙事）规格实现。
///
/// 字段名与序列化键一律 snake_case（ADR-6）。不依赖 `package:flutter`。
library;

import 'package:meta/meta.dart';

// ---------------------------------------------------------------------------
// 既有契约符号（保留，供 fusion / storage 使用）
// ---------------------------------------------------------------------------

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

/// 画像快照（既有契约）。
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

/// 两版本之间的差异（既有契约）。
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

// ---------------------------------------------------------------------------
// P3-1 目标符号（画像动态更新）
// ---------------------------------------------------------------------------

/// 单个画像维度（轴）。
///
/// [active] 为 false 时该维度既不渲染也不进入存储（P-RL1）。
@immutable
class PortraitAxis {
  final String id;
  final String label;
  final bool active;

  const PortraitAxis({
    required this.id,
    required this.label,
    required this.active,
  });
}

/// 画像快照（P3-1 版本化）。
///
/// **不变量（P-RL1）**：[values] 的键必须恰好等于 [activeAxes] 各轴的 [id]，
/// 即未激活维度绝不出现在 [activeAxes] 中，也绝不进入 [values]。
@immutable
class PortraitSnapshot {
  final int version;
  final List<PortraitAxis> activeAxes;
  final Map<String, double> values;
  final String transitionNarrative;
  final DateTime consentedAt;

  PortraitSnapshot({
    required this.version,
    required this.activeAxes,
    required this.values,
    required this.transitionNarrative,
    required this.consentedAt,
  });
}

/// 画像版本元信息（用于版本历史列表）。
///
/// 注意：仓库既有 `lib/core/storage/*` 已使用同名 `PortraitVersion`
/// （目标边界版本模型，含 `versionId` / `snapshot` / `consentRecordId`），
/// 为避免破坏存储层与既有 fixture / 测试，本 P3-1 画像版本元信息改用
/// [PortraitVersionInfo] 命名。两者语义不同：此处仅描述画像自身的版本、
/// 授权时间与过渡叙事。
class PortraitVersionInfo {
  final int version;
  final DateTime consentedAt;
  final String transitionNarrative;

  PortraitVersionInfo({
    required this.version,
    required this.consentedAt,
    required this.transitionNarrative,
  });
}

/// 画像版本边界模型（目标边界版本，供 storage 层持久化）。
///
/// 与 [PortraitVersionInfo] 语义不同：此处描述一次版本化的完整边界数据
/// （含 `versionId` / `snapshot` / `consentRecordId`），供内存与 SQLite
/// 存储层使用；[PortraitVersionInfo] 仅描述画像自身版本元信息（版本号 /
/// 授权时间 / 过渡叙事）。
///
/// 以 [versionId] 作为实体主键，[==] / [hashCode] 据此判定同一版本。
class PortraitVersion {
  final String versionId;
  final int createdAt; // microsecondsSinceEpoch
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortraitVersion && other.versionId == versionId;

  @override
  int get hashCode => versionId.hashCode;
}
