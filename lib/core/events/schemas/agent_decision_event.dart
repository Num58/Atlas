/// `agent_decision_event` —— 多 Agent 决策面板结果事件（append-only）。
///
/// 在决策组合层运行完成后发出，记录 Agent 评估与裁决结论、面板级安全状态。
/// 写入现有 `events` 表（append-only），不新增 SQLite 表。
library;

import 'package:primeatlas/core/agents/agent_types.dart';
import 'package:primeatlas/core/events/event_payload.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/validator.dart';

/// 多 Agent 决策面板结果事件载体。
class AgentDecisionEvent implements EventPayload {
  static const String eventType = 'agent_decision_event';

  final String ownerId;
  final String actionType;
  final List<AgentDecision> decisions;
  final AgentDecision? resolution;
  final SafetyStatus safetyStatus;
  final int decidedAtUs;

  const AgentDecisionEvent({
    required this.ownerId,
    required this.actionType,
    required this.decisions,
    this.resolution,
    required this.safetyStatus,
    required this.decidedAtUs,
  });

  @override
  Map<String, Object?> toJson() => {
        'owner_id': ownerId,
        'action_type': actionType,
        'decisions': decisions.map((d) => d.toJson()).toList(),
        'resolution': resolution?.toJson(),
        'safety_status': safetyStatus.code,
        'decided_at_us': decidedAtUs,
      };

  factory AgentDecisionEvent.fromJson(Map<String, Object?> json) {
    final decisions = (json['decisions'] as List? ?? const [])
        .map((e) => AgentDecision.fromJson(e as Map<String, Object?>))
        .toList();
    final resolution = json['resolution'] == null
        ? null
        : AgentDecision.fromJson(json['resolution'] as Map<String, Object?>);
    return AgentDecisionEvent(
      ownerId: json['owner_id'] as String,
      actionType: json['action_type'] as String,
      decisions: decisions,
      resolution: resolution,
      safetyStatus: SafetyStatus.fromCode(
          json['safety_status'] as String? ?? 'clear'),
      decidedAtUs: json['decided_at_us'] as int,
    );
  }
}

/// 校验器：保证 `agent_decision_event` 结构合法且安全状态枚举受控。
class AgentDecisionEventValidator implements Validator {
  @override
  ValidationResult validate(EventPayload payload) {
    if (payload is! AgentDecisionEvent) {
      return ValidationResult.failed(
          ['payload is not an AgentDecisionEvent (got ${payload.runtimeType})']);
    }
    return validateMap(payload.toJson());
  }

  ValidationResult validateMap(Map<String, Object?> json) {
    final errors = <String>[];
    checkString(json, errors, 'owner_id');
    checkString(json, errors, 'action_type');
    checkEnumValue(json, errors, 'safety_status',
        const ['clear', 'advisory', 'blocked_non_user']);
    if (json['decided_at_us'] is! int) {
      errors.add('field "decided_at_us" must be int');
    }
    if (json['decisions'] is! List) {
      errors.add('field "decisions" must be List');
    }
    if (errors.isNotEmpty) return ValidationResult.failed(errors);
    return const ValidationResult.ok();
  }
}
