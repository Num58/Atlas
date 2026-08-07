import 'package:primeatlas/core/common/domain_failure.dart';
import 'package:primeatlas/core/common/result.dart';
import 'package:primeatlas/core/portrait/dimension_status.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';

// ---------------------------------------------------------------------------
// 既有契约符号（保留，供 fusion / storage 使用）
// ---------------------------------------------------------------------------

/// 画像版本化引擎抽象契约（P3-1 既有契约）。
abstract class PortraitVersioner {
  /// 基于快照创建一个新画像版本（须经用户 consent）。
  PortraitVersion createVersion(
      ProfileSnapshot snapshot, String consentRecordId);

  /// 计算两个版本之间的差异。
  VersionDiff diff(String fromVersion, String toVersion);

  /// 回滚到指定历史版本。
  void rollback(String versionId);

  /// 查询某维度的渲染 / 存储状态（P-RL1）。
  DimensionStatus getDimensionStatus(String dimension);
}

/// S0 内存版画像版本化器。
///
/// 契约保证：
/// - **P-RL2**：`createVersion` 要求非空 `consentRecordId`（S0 不允许 system_auto）。
/// - **P-RL1**：未激活维度 `rendered == false && occupiedStorage == false`。
class InMemoryPortraitVersioner implements PortraitVersioner {
  final List<PortraitVersion> _versions = [];
  String _currentVersionId = '';
  int _counter = 0;

  PortraitVersion _get(String versionId) {
    for (final v in _versions) {
      if (v.versionId == versionId) return v;
    }
    throw ArgumentError('unknown portrait version: $versionId');
  }

  @override
  PortraitVersion createVersion(
      ProfileSnapshot snapshot, String consentRecordId) {
    if (consentRecordId.isEmpty) {
      throw ArgumentError(
          'P-RL2 violation: consent_record_id 不能为空（S0 无 system_auto 路径）');
    }
    _counter += 1;
    final versionId = 'v${_counter}_${DateTime.now().microsecondsSinceEpoch}';
    final version = PortraitVersion(
      versionId: versionId,
      createdAt: DateTime.now().microsecondsSinceEpoch,
      snapshot: snapshot,
      changeSummary: '',
      consentRecordId: consentRecordId,
    );
    _versions.add(version);
    _currentVersionId = versionId;
    return version;
  }

  @override
  VersionDiff diff(String fromVersion, String toVersion) {
    final from = _get(fromVersion);
    final to = _get(toVersion);

    final changes = <FieldChange>[];
    final keys = <String>{
      ...from.snapshot.fields.keys,
      ...to.snapshot.fields.keys,
    };
    for (final key in keys) {
      final oldValue = from.snapshot.fields[key];
      final newValue = to.snapshot.fields[key];
      if (oldValue != newValue) {
        changes.add(FieldChange(
          fieldName: key,
          oldValue: oldValue,
          newValue: newValue,
        ));
      }
    }

    return VersionDiff(
      fromVersion: fromVersion,
      toVersion: toVersion,
      changes: changes,
      hasNarratableChange: changes.isNotEmpty,
    );
  }

  @override
  void rollback(String versionId) {
    _get(versionId);
    _currentVersionId = versionId;
  }

  @override
  DimensionStatus getDimensionStatus(String dimension) {
    final current =
        _currentVersionId.isEmpty ? null : _get(_currentVersionId);
    final isActive =
        current?.snapshot.activeDimensions.contains(dimension) ?? false;
    return DimensionStatus(
      dimension: dimension,
      isActive: isActive,
      rendered: isActive,
      occupiedStorage: isActive,
    );
  }
}

// ---------------------------------------------------------------------------
// P3-1 目标引擎：画像动态更新（动态轴雷达 + 版本化 + 过渡态叙事）
// ---------------------------------------------------------------------------

/// 画像动态更新引擎（纯 Dart，无 `package:flutter` 依赖）。
///
/// 核心契约：
/// - **P-RL1**：未激活维度既不进入 [PortraitSnapshot.activeAxes]，也不进入
///   [PortraitSnapshot.values]；若 [rawValues] 携带未激活维度的键，直接拒绝。
/// - **版本化需 consent**：`consent == false` 时绝不创建快照（返回
///   `consent_required` 失败）；S0（无历史 / system_auto）亦不会自动建版本。
class PortraitEngine {
  const PortraitEngine();

  /// 仅保留激活维度（P-RL1 在读时再次强制）。
  List<PortraitAxis> activeOnly(List<PortraitAxis> all) =>
      all.where((a) => a.active).toList();

  /// 基于当前维度与原始取值创建一个新画像版本。
  ///
  /// 参数：
  /// - [axes] 全部候选维度（含激活 / 未激活）。
  /// - [rawValues] 原始取值，键为维度 id。
  /// - [consent] 用户是否明确授权本次版本化。
  /// - [now] 授权时间；由调用方注入以便测试可确定性。
  /// - [prevVersion] 上一版本号；为 null 表示首个版本（叙事留空）。
  /// - [prev] 上一快照；用于生成过渡态叙事，缺失时叙事留空。
  ///
  /// 失败码：
  /// - `consent_required`：未授权。
  /// - `inactive_axis_value`：[rawValues] 含未激活维度的键（违反 P-RL1）。
  Result<PortraitSnapshot> createSnapshot({
    required List<PortraitAxis> axes,
    required Map<String, double> rawValues,
    required bool consent,
    required DateTime now,
    int? prevVersion,
    PortraitSnapshot? prev,
  }) {
    if (!consent) {
      return Failure(const DomainFailure(
        code: 'consent_required',
        retryable: false,
        messageKey: 'error.consent_required',
      ));
    }

    // P-RL1：任何未激活维度的取值键都视为非法，直接拒绝。
    for (final axis in axes) {
      if (!axis.active && rawValues.containsKey(axis.id)) {
        return Failure(DomainFailure(
          code: 'inactive_axis_value',
          retryable: false,
          messageKey: 'error.invalid_argument',
          details: {'axis_id': axis.id},
        ));
      }
    }

    final included =
        activeOnly(axes).where((a) => rawValues.containsKey(a.id)).toList();
    final values = <String, double>{
      for (final a in included) a.id: rawValues[a.id] as double,
    };

    final version = (prevVersion ?? 0) + 1;
    final next = PortraitSnapshot(
      version: version,
      activeAxes: included,
      values: values,
      transitionNarrative: '',
      consentedAt: now,
    );

    final narrative =
        (prevVersion == null || prev == null) ? '' : deriveTransition(prev, next);

    return Success(PortraitSnapshot(
      version: version,
      activeAxes: included,
      values: values,
      transitionNarrative: narrative,
      consentedAt: now,
    ));
  }

  /// 由前后两快照的激活维度差异，确定性地生成过渡态叙事。
  ///
  /// 规则（确定性，按固定迭代顺序）：
  /// - 新增激活维度 → “更关注{label}”；
  /// - 退出的激活维度 → “减少对{label}的投入”；
  /// - 共有维度取值上升 → “提升{label}”，下降 → “降低{label}”。
  /// [prev] 为 null（首个版本）时返回空串。
  String deriveTransition(PortraitSnapshot? prev, PortraitSnapshot next) {
    if (prev == null) return '';

    final prevLabels = {for (final a in prev.activeAxes) a.id: a.label};
    final nextIds = {for (final a in next.activeAxes) a.id};
    final parts = <String>[];

    for (final a in next.activeAxes) {
      if (!prevLabels.containsKey(a.id)) {
        parts.add('更关注${a.label}');
      }
    }
    for (final a in prev.activeAxes) {
      if (!nextIds.contains(a.id)) {
        parts.add('减少对${a.label}的投入');
      }
    }
    for (final a in next.activeAxes) {
      if (prevLabels.containsKey(a.id)) {
        final before = prev.values[a.id];
        final after = next.values[a.id];
        if (before != null && after != null && after > before) {
          parts.add('提升${a.label}');
        } else if (before != null && after != null && after < before) {
          parts.add('降低${a.label}');
        }
      }
    }
    return parts.join('，');
  }
}
