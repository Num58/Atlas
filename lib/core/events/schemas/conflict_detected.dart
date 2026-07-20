import 'package:primeatlas/core/conflict/conflict_types.dart';
import 'package:primeatlas/core/events/event_payload.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/validator.dart';

/// `conflict_detected` — emitted when a goal conflict is detected (C-RL1/RL3).
class ConflictDetected implements EventPayload {
  static const String eventType = 'conflict_detected';

  final String conflict_id;
  final ConflictType conflict_type;
  final bool is_body_related;
  final String? body_reason;
  final String? body_reason_traceable_id; // C-RL3 traceability
  final Disposition disposition; // only blocked_user (always false)
  final Orchestration recommended_orchestration;

  const ConflictDetected({
    required this.conflict_id,
    required this.conflict_type,
    required this.is_body_related,
    this.body_reason,
    this.body_reason_traceable_id,
    required this.disposition,
    required this.recommended_orchestration,
  });

  @override
  Map<String, Object?> toJson() => {
        'conflict_id': conflict_id,
        'conflict_type': conflict_type.code,
        'is_body_related': is_body_related,
        'body_reason': body_reason,
        'body_reason_traceable_id': body_reason_traceable_id,
        'disposition': {
          'blocked_user': disposition.blockedUser,
        },
        'recommended_orchestration': {
          'type': recommended_orchestration.type.code,
          'rationale': recommended_orchestration.rationale,
          'safety_channel_required':
              recommended_orchestration.safetyChannelRequired,
        },
      };

  factory ConflictDetected.fromJson(Map<String, Object?> json) {
    final disp = json['disposition'] as Map<String, Object?>;
    final orch = json['recommended_orchestration'] as Map<String, Object?>;
    return ConflictDetected(
      conflict_id: json['conflict_id'] as String,
      conflict_type: ConflictType.fromCode(json['conflict_type'] as String),
      is_body_related: json['is_body_related'] as bool,
      body_reason: json['body_reason'] as String?,
      body_reason_traceable_id:
          json['body_reason_traceable_id'] as String?,
      disposition: Disposition(blockedUser: disp['blocked_user'] as bool),
      recommended_orchestration: Orchestration(
        type: OrchestrationType.fromCode(orch['type'] as String),
        rationale: orch['rationale'] as String,
        safetyChannelRequired: orch['safety_channel_required'] as bool,
      ),
    );
  }
}

class ConflictDetectedValidator implements Validator {
  @override
  ValidationResult validate(EventPayload payload) {
    if (payload is! ConflictDetected) {
      return ValidationResult.failed(
          ['payload is not a ConflictDetected (got ${payload.runtimeType})']);
    }
    return validateMap(payload.toJson());
  }

  ValidationResult validateMap(Map<String, Object?> json) {
    final errors = <String>[];
    checkString(json, errors, 'conflict_id');
    checkString(json, errors, 'conflict_type');
    checkBool(json, errors, 'is_body_related');
    checkNullableString(json, errors, 'body_reason');
    checkNullableString(json, errors, 'body_reason_traceable_id');
    checkMap(json, errors, 'disposition');
    checkMap(json, errors, 'recommended_orchestration');
    checkEnumValue(json, errors, 'conflict_type',
        const ['goal_goal', 'goal_body', 'goal_resource', 'goal_identity']);

    final disp = json['disposition'];
    if (disp is Map<String, Object?>) {
      if (disp['blocked_user'] == true) {
        // C-RL1: conflicts must never hard-block the user.
        errors.add('C-RL1: disposition.blocked_user must be false');
      }
    }
    final orch = json['recommended_orchestration'];
    if (orch is Map<String, Object?>) {
      checkEnumValue(orch, errors, 'type',
          const ['one_click_adopt', 'i_will_do_it', 'defer']);
      checkString(orch, errors, 'rationale');
      checkBool(orch, errors, 'safety_channel_required');
    }
    if (errors.isNotEmpty) return ValidationResult.failed(errors);
    return const ValidationResult.ok();
  }
}
