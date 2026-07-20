import 'package:primeatlas/core/events/event_payload.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/validator.dart';

/// Source of a profile field confirmation (P-RL2). */
enum ConfirmSource { userExplicit, userOverride, systemAuto }

extension ConfirmSourceX on ConfirmSource {
  String get code => switch (this) {
        ConfirmSource.userExplicit => 'user_explicit',
        ConfirmSource.userOverride => 'user_override',
        ConfirmSource.systemAuto => 'system_auto',
      };
  static ConfirmSource fromCode(String code) => switch (code) {
        'user_explicit' => ConfirmSource.userExplicit,
        'user_override' => ConfirmSource.userOverride,
        'system_auto' => ConfirmSource.systemAuto,
        _ => throw FormatException('unknown ConfirmSource code: $code'),
      };
}

/// `profile_field_update` — emitted when a portrait field changes (P-RL2).
class ProfileFieldUpdate implements EventPayload {
  static const String eventType = 'profile_field_update';

  final String field_name;
  final Object? old_value;
  final Object? new_value;
  final ConfirmSource confirm_source; // P-RL2: system_auto must be 0
  final String consent_record_id;
  final String portrait_version;

  const ProfileFieldUpdate({
    required this.field_name,
    this.old_value,
    this.new_value,
    required this.confirm_source,
    required this.consent_record_id,
    required this.portrait_version,
  });

  @override
  Map<String, Object?> toJson() => {
        'field_name': field_name,
        'old_value': old_value,
        'new_value': new_value,
        'confirm_source': confirm_source.code,
        'consent_record_id': consent_record_id,
        'portrait_version': portrait_version,
      };

  factory ProfileFieldUpdate.fromJson(Map<String, Object?> json) {
    return ProfileFieldUpdate(
      field_name: json['field_name'] as String,
      old_value: json['old_value'],
      new_value: json['new_value'],
      confirm_source:
          ConfirmSourceX.fromCode(json['confirm_source'] as String),
      consent_record_id: json['consent_record_id'] as String,
      portrait_version: json['portrait_version'] as String,
    );
  }
}

class ProfileFieldUpdateValidator implements Validator {
  @override
  ValidationResult validate(EventPayload payload) {
    if (payload is! ProfileFieldUpdate) {
      return ValidationResult.failed(
          ['payload is not a ProfileFieldUpdate (got ${payload.runtimeType})']);
    }
    return validateMap(payload.toJson());
  }

  ValidationResult validateMap(Map<String, Object?> json) {
    final errors = <String>[];
    checkString(json, errors, 'field_name');
    // old_value / new_value are Object? and optional — any type allowed.
    checkString(json, errors, 'confirm_source');
    checkString(json, errors, 'consent_record_id');
    checkString(json, errors, 'portrait_version');
    checkEnumValue(json, errors, 'confirm_source',
        const ['user_explicit', 'user_override', 'system_auto']);
    if (errors.isNotEmpty) return ValidationResult.failed(errors);
    return const ValidationResult.ok();
  }
}
