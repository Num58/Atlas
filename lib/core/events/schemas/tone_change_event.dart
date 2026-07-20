import 'package:primeatlas/core/events/event_payload.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/validator.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// `tone_change_event` — emitted whenever the active tone switches.
class ToneChangeEvent implements EventPayload {
  static const String eventType = 'tone_change_event';

  final Tone from_tone;
  final Tone to_tone;
  final ToneSwitchTrigger trigger;
  final bool blocked_by_system;
  final String? unlock_path; // progressive-unlock path, nullable

  const ToneChangeEvent({
    required this.from_tone,
    required this.to_tone,
    required this.trigger,
    required this.blocked_by_system,
    this.unlock_path,
  });

  @override
  Map<String, Object?> toJson() => {
        'from_tone': from_tone.name,
        'to_tone': to_tone.name,
        'trigger': trigger.code,
        'blocked_by_system': blocked_by_system,
        'unlock_path': unlock_path,
      };

  factory ToneChangeEvent.fromJson(Map<String, Object?> json) {
    return ToneChangeEvent(
      from_tone: Tone.values.byName(json['from_tone'] as String),
      to_tone: Tone.values.byName(json['to_tone'] as String),
      trigger: ToneSwitchTrigger.fromCode(json['trigger'] as String),
      blocked_by_system: json['blocked_by_system'] as bool,
      unlock_path: json['unlock_path'] as String?,
    );
  }
}

class ToneChangeEventValidator implements Validator {
  @override
  ValidationResult validate(EventPayload payload) {
    if (payload is! ToneChangeEvent) {
      return ValidationResult.failed(
          ['payload is not a ToneChangeEvent (got ${payload.runtimeType})']);
    }
    return validateMap(payload.toJson());
  }

  ValidationResult validateMap(Map<String, Object?> json) {
    final errors = <String>[];
    checkString(json, errors, 'from_tone');
    checkString(json, errors, 'to_tone');
    checkString(json, errors, 'trigger');
    checkBool(json, errors, 'blocked_by_system');
    checkNullableString(json, errors, 'unlock_path');
    checkEnumValue(json, errors, 'from_tone', Tone.values.map((e) => e.name));
    checkEnumValue(json, errors, 'to_tone', Tone.values.map((e) => e.name));
    checkEnumValue(json, errors, 'trigger',
        const ['user_explicit', 'system_suggested', 'context_adaptive']);
    if (errors.isNotEmpty) return ValidationResult.failed(errors);
    return const ValidationResult.ok();
  }
}
