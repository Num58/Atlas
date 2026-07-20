import 'package:primeatlas/core/portrait/dimension_status.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';

/// 画像版本化引擎抽象契约（P3-1）。
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
    // P-RL2：S0 不存在 system_auto 路径，consent 必填。
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
    _get(versionId); // 校验存在性
    _currentVersionId = versionId;
  }

  @override
  DimensionStatus getDimensionStatus(String dimension) {
    final current =
        _currentVersionId.isEmpty ? null : _get(_currentVersionId);
    final isActive =
        current?.snapshot.activeDimensions.contains(dimension) ?? false;
    // P-RL1：未激活维度既不渲染也不占存储。
    return DimensionStatus(
      dimension: dimension,
      isActive: isActive,
      rendered: isActive,
      occupiedStorage: isActive,
    );
  }
}
