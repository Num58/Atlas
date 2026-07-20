import 'package:primeatlas/core/events/event_payload.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/validator.dart';

/// `dimension_data_presence` — emitted for each profile dimension (P-RL1).
class DimensionDataPresence implements EventPayload {
  static const String eventType = 'dimension_data_presence';

  final String dimension;
  final bool is_active;
  final bool rendered; // must == is_active (P-RL1)
  final bool occupied_storage; // must be false when !is_active (P-RL1)

  const DimensionDataPresence({
    required this.dimension,
    required this.is_active,
    required this.rendered,
    required this.occupied_storage,
  });

  @override
  Map<String, Object?> toJson() => {
        'dimension': dimension,
        'is_active': is_active,
        'rendered': rendered,
        'occupied_storage': occupied_storage,
      };

  factory DimensionDataPresence.fromJson(Map<String, Object?> json) {
    return DimensionDataPresence(
      dimension: json['dimension'] as String,
      is_active: json['is_active'] as bool,
      rendered: json['rendered'] as bool,
      occupied_storage: json['occupied_storage'] as bool,
    );
  }
}

class DimensionDataPresenceValidator implements Validator {
  @override
  ValidationResult validate(EventPayload payload) {
    if (payload is! DimensionDataPresence) {
      return ValidationResult.failed([
        'payload is not a DimensionDataPresence (got ${payload.runtimeType})'
      ]);
    }
    return validateMap(payload.toJson());
  }

  ValidationResult validateMap(Map<String, Object?> json) {
    final errors = <String>[];
    final warnings = <String>[];

    checkString(json, errors, 'dimension');
    checkBool(json, errors, 'is_active');
    checkBool(json, errors, 'rendered');
    checkBool(json, errors, 'occupied_storage');

    // P-RL1: business-invariant warnings, NOT rejections.
    if (json['rendered'] != json['is_active']) {
      warnings.add('P-RL1: rendered (${json['rendered']}) != is_active (${json['is_active']})');
    }
    if (json['is_active'] == false && json['occupied_storage'] == true) {
      warnings.add('P-RL1: inactive dimension must not occupy storage');
    }

    if (errors.isNotEmpty) return ValidationResult.failed(errors, warnings);
    return ValidationResult(true, const [], warnings);
  }
}
