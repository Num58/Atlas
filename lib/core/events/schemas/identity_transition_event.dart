import 'package:primeatlas/core/events/event_payload.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/validator.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// `identity_transition_event` — emitted on an identity-stage change (P-RL3).
class IdentityTransitionEvent implements EventPayload {
  static const String eventType = 'identity_transition_event';

  final String transition_id;
  final IdentityStage from_role; // initiate | practitioner | advanced | master
  final IdentityStage to_role;
  final bool has_narratable_change; // P-RL3 narrative show/hide source
  final bool narrative_shown; // must == has_narratable_change
  final String change_summary;

  const IdentityTransitionEvent({
    required this.transition_id,
    required this.from_role,
    required this.to_role,
    required this.has_narratable_change,
    required this.narrative_shown,
    required this.change_summary,
  });

  @override
  Map<String, Object?> toJson() => {
        'transition_id': transition_id,
        'from_role': from_role.name,
        'to_role': to_role.name,
        'has_narratable_change': has_narratable_change,
        'narrative_shown': narrative_shown,
        'change_summary': change_summary,
      };

  factory IdentityTransitionEvent.fromJson(Map<String, Object?> json) {
    return IdentityTransitionEvent(
      transition_id: json['transition_id'] as String,
      from_role: IdentityStage.values.byName(json['from_role'] as String),
      to_role: IdentityStage.values.byName(json['to_role'] as String),
      has_narratable_change: json['has_narratable_change'] as bool,
      narrative_shown: json['narrative_shown'] as bool,
      change_summary: json['change_summary'] as String,
    );
  }
}

class IdentityTransitionEventValidator implements Validator {
  @override
  ValidationResult validate(EventPayload payload) {
    if (payload is! IdentityTransitionEvent) {
      return ValidationResult.failed([
        'payload is not an IdentityTransitionEvent (got ${payload.runtimeType})'
      ]);
    }
    return validateMap(payload.toJson());
  }

  ValidationResult validateMap(Map<String, Object?> json) {
    final errors = <String>[];
    final warnings = <String>[];

    checkString(json, errors, 'transition_id');
    checkString(json, errors, 'from_role');
    checkString(json, errors, 'to_role');
    checkBool(json, errors, 'has_narratable_change');
    checkBool(json, errors, 'narrative_shown');
    checkString(json, errors, 'change_summary');
    checkEnumValue(json, errors, 'from_role',
        IdentityStage.values.map((e) => e.name));
    checkEnumValue(
        json, errors, 'to_role', IdentityStage.values.map((e) => e.name));

    // P-RL3: business-invariant warning, NOT a rejection.
    if (json['narrative_shown'] != json['has_narratable_change']) {
      warnings.add(
          'P-RL3: narrative_shown (${json['narrative_shown']}) != has_narratable_change (${json['has_narratable_change']})');
    }

    if (errors.isNotEmpty) return ValidationResult.failed(errors, warnings);
    return ValidationResult(true, const [], warnings);
  }
}
