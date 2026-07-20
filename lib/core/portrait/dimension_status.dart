/// 维度状态（P3-1 辅助类型）。
///
/// 不变量（P-RL1）：
/// - `rendered == isActive`（未激活维度绝不渲染）；
/// - `!isActive ⇒ !occupiedStorage`（未激活维度绝不占存储）。
class DimensionStatus {
  final String dimension;
  final bool isActive;
  final bool rendered;
  final bool occupiedStorage;

  const DimensionStatus({
    required this.dimension,
    required this.isActive,
    required this.rendered,
    required this.occupiedStorage,
  });

  Map<String, Object?> toJson() => {
        'dimension': dimension,
        'is_active': isActive,
        'rendered': rendered,
        'occupied_storage': occupiedStorage,
      };

  static DimensionStatus fromJson(Map<String, Object?> json) => DimensionStatus(
        dimension: json['dimension'] as String,
        isActive: json['is_active'] as bool,
        rendered: json['rendered'] as bool,
        occupiedStorage: json['occupied_storage'] as bool,
      );
}
