/// 冲突检测类型定义（C1-1）。
///
/// 字段名与序列化键一律 snake_case（ADR-6）。不依赖 `package:flutter`。
library;

/// 冲突类型枚举。
enum ConflictType {
  goalGoal,
  goalBody,
  goalResource,
  goalIdentity;

  String get code => switch (this) {
        ConflictType.goalGoal => 'goal_goal',
        ConflictType.goalBody => 'goal_body',
        ConflictType.goalResource => 'goal_resource',
        ConflictType.goalIdentity => 'goal_identity',
      };

  static ConflictType fromCode(String code) => switch (code) {
        'goal_goal' => ConflictType.goalGoal,
        'goal_body' => ConflictType.goalBody,
        'goal_resource' => ConflictType.goalResource,
        'goal_identity' => ConflictType.goalIdentity,
        _ => throw ArgumentError('Unknown ConflictType code: $code'),
      };
}

/// 仲裁编排类型。
enum OrchestrationType {
  oneClickAdopt,
  iWillDoIt,
  defer;

  String get code => switch (this) {
        OrchestrationType.oneClickAdopt => 'one_click_adopt',
        OrchestrationType.iWillDoIt => 'i_will_do_it',
        OrchestrationType.defer => 'defer',
      };

  static OrchestrationType fromCode(String code) => switch (code) {
        'one_click_adopt' => OrchestrationType.oneClickAdopt,
        'i_will_do_it' => OrchestrationType.iWillDoIt,
        'defer' => OrchestrationType.defer,
        _ => throw ArgumentError('Unknown OrchestrationType code: $code'),
      };
}

/// 推荐的仲裁编排（C-RL2 透明依据）。
class Orchestration {
  final OrchestrationType type;
  final String rationale;
  final bool safetyChannelRequired;

  const Orchestration({
    required this.type,
    required this.rationale,
    required this.safetyChannelRequired,
  });

  Map<String, Object?> toJson() => {
        'type': type.code,
        'rationale': rationale,
        'safety_channel_required': safetyChannelRequired,
      };

  static Orchestration fromJson(Map<String, Object?> json) => Orchestration(
        type: OrchestrationType.fromCode(json['type'] as String),
        rationale: json['rationale'] as String,
        safetyChannelRequired: json['safety_channel_required'] as bool,
      );
}

/// 处置结果。
///
/// **C-RL1 不硬阻断**：`blockedUser` 在类型层（assert）强制恒为 `false`，
/// 确保「冲突绝不硬阻断用户」无法被误实现。引擎返回的结果统一为非阻断。
class Disposition {
  final bool blockedUser;

  const Disposition({required this.blockedUser})
      : assert(blockedUser == false,
            'disposition.blocked_user 必须恒为 false (C-RL1)');

  Map<String, Object?> toJson() => {'blocked_user': blockedUser};

  static Disposition fromJson(Map<String, Object?> json) =>
      Disposition(blockedUser: json['blocked_user'] as bool);
}

/// 冲突检测结果。
class ConflictDetectionResult {
  final String conflictId;
  final ConflictType conflictType;
  final bool isBodyRelated;
  final String? bodyReason;
  final String? bodyReasonTraceableId;
  final Disposition disposition;
  final Orchestration recommendedOrchestration;

  const ConflictDetectionResult({
    required this.conflictId,
    required this.conflictType,
    required this.isBodyRelated,
    this.bodyReason,
    this.bodyReasonTraceableId,
    required this.disposition,
    required this.recommendedOrchestration,
  });

  Map<String, Object?> toJson() => {
        'conflict_id': conflictId,
        'conflict_type': conflictType.code,
        'is_body_related': isBodyRelated,
        'body_reason': bodyReason,
        'body_reason_traceable_id': bodyReasonTraceableId,
        'disposition': disposition.toJson(),
        'recommended_orchestration': recommendedOrchestration.toJson(),
      };

  static ConflictDetectionResult fromJson(Map<String, Object?> json) =>
      ConflictDetectionResult(
        conflictId: json['conflict_id'] as String,
        conflictType: ConflictType.fromCode(json['conflict_type'] as String),
        isBodyRelated: json['is_body_related'] as bool,
        bodyReason: json['body_reason'] as String?,
        bodyReasonTraceableId: json['body_reason_traceable_id'] as String?,
        disposition:
            Disposition.fromJson(json['disposition'] as Map<String, Object?>),
        recommendedOrchestration: Orchestration.fromJson(
            json['recommended_orchestration'] as Map<String, Object?>),
      );
}

/// 冲突检测请求（由调用方提供原始信号）。
class ConflictDetectionRequest {
  final String conflictId;
  final ConflictType conflictType;
  final bool isBodyRelated;
  final String? bodyReason;
  final String? bodyReasonTraceableId;
  final Orchestration recommendedOrchestration;

  const ConflictDetectionRequest({
    required this.conflictId,
    required this.conflictType,
    required this.isBodyRelated,
    this.bodyReason,
    this.bodyReasonTraceableId,
    required this.recommendedOrchestration,
  });

  Map<String, Object?> toJson() => {
        'conflict_id': conflictId,
        'conflict_type': conflictType.code,
        'is_body_related': isBodyRelated,
        'body_reason': bodyReason,
        'body_reason_traceable_id': bodyReasonTraceableId,
        'recommended_orchestration': recommendedOrchestration.toJson(),
      };

  static ConflictDetectionRequest fromJson(Map<String, Object?> json) =>
      ConflictDetectionRequest(
        conflictId: json['conflict_id'] as String,
        conflictType: ConflictType.fromCode(json['conflict_type'] as String),
        isBodyRelated: json['is_body_related'] as bool,
        bodyReason: json['body_reason'] as String?,
        bodyReasonTraceableId: json['body_reason_traceable_id'] as String?,
        recommendedOrchestration: Orchestration.fromJson(
            json['recommended_orchestration'] as Map<String, Object?>),
      );
}

/// ===========================================================================
/// C1-1 冲突检测（权衡非禁止 / 双轨裁决 / 身体安全通道）。
///
/// 以下为新版检测引擎使用的类型。与上方事件 schema 的 `ConflictType` /
/// `Disposition` / `Orchestration` 并存，供 `conflict_detected.dart` 兼容使用。
/// ===========================================================================

/// 冲突种类（检测引擎实际产出）。
enum ConflictKind {
  scheduleOverlap,
  energyBudget,
  goalDivergence,
  trainingLoadVsRecovery;
}

/// 冲突严重级别。
enum ConflictSeverity { info, caution, warning; }

/// 用于冲突检测的极简本地日程项模型（不含持久化字段）。
class ScheduledItem {
  final String id;
  final DateTime start;
  final DateTime end;
  final int plannedEnergy;
  final bool isTraining;
  final int recoveryLevel;

  const ScheduledItem({
    required this.id,
    required this.start,
    required this.end,
    required this.plannedEnergy,
    required this.isTraining,
    required this.recoveryLevel,
  });

  /// 半开区间 [start, end) 重叠判定。
  bool overlaps(ScheduledItem other) =>
      start.isBefore(other.end) && other.start.isBefore(end);
}

/// 一条已检测到的冲突。
class Conflict {
  final String id;
  final ConflictKind kind;
  final List<String> involvedItemIds;
  final String description;
  final String tradeoffSummary;
  final bool bodySafety;
  final ConflictSeverity severity;

  const Conflict({
    required this.id,
    required this.kind,
    required this.involvedItemIds,
    required this.description,
    required this.tradeoffSummary,
    required this.bodySafety,
    required this.severity,
  });
}

/// 双轨裁决结论。
enum ConflictVerdict { adopt, selfManaged; }

/// 冲突裁决结果。
///
/// **C-RL1 不硬阻断**：类型层（assert）强制 `blockedUser` 恒为 `false`，
/// 任何裁决都不得阻断用户。
class ConflictResolution {
  final String conflictId;
  final ConflictVerdict verdict;
  final String note;
  final bool blockedUser;

  const ConflictResolution({
    required this.conflictId,
    required this.verdict,
    required this.note,
    required this.blockedUser,
  }) : assert(blockedUser == false, 'blockedUser 必须恒为 false (C-RL1)');
}
