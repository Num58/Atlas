/// 冲突检测类型定义（C1-1）。
///
/// 字段名与序列化键一律 snake_case（ADR-6）。不依赖 `package:flutter`。

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
