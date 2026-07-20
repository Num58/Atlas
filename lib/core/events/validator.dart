import 'event_payload.dart';
import 'event_receipt.dart';

/// Contract for per-event-type payload validation.
abstract class Validator {
  /// Validate a typed [EventPayload]. Implementations typically re-check the
  /// JSON form via [validateMap] to keep type-level and JSON-level checks
  /// consistent.
  ValidationResult validate(EventPayload payload);
}

/// Registry mapping `eventType` -> [Validator].
class ValidatorRegistry {
  final Map<String, Validator> _validators = {};

  void register(String eventType, Validator v) => _validators[eventType] = v;

  Validator? lookup(String eventType) => _validators[eventType];

  void clear() => _validators.clear();
}

// ---------------------------------------------------------------------------
// Shared JSON-level checks used by every schema validator's `validateMap`.
// Kept intentionally simple (presence + runtime-type) so the validator layer
// can reject malformed payloads with 100% coverage.
// ---------------------------------------------------------------------------

String? requirePresent(Map<String, Object?> json, String key) {
  if (!json.containsKey(key) || json[key] == null) {
    return 'missing required field: $key';
  }
  return null;
}

String? isString(Object? v) => v is String ? null : 'must be String';
String? isBool(Object? v) => v is bool ? null : 'must be bool';
String? isMap(Object? v) => v is Map ? null : 'must be Map';

void checkString(Map<String, Object?> json, List<String> errors, String key) {
  final p = requirePresent(json, key);
  if (p != null) {
    errors.add(p);
    return;
  }
  final t = isString(json[key]);
  if (t != null) errors.add('field "$key" $t');
}

void checkBool(Map<String, Object?> json, List<String> errors, String key) {
  final p = requirePresent(json, key);
  if (p != null) {
    errors.add(p);
    return;
  }
  final t = isBool(json[key]);
  if (t != null) errors.add('field "$key" $t');
}

void checkMap(Map<String, Object?> json, List<String> errors, String key) {
  final p = requirePresent(json, key);
  if (p != null) {
    errors.add(p);
    return;
  }
  final t = isMap(json[key]);
  if (t != null) errors.add('field "$key" $t');
}

void checkNullableString(
    Map<String, Object?> json, List<String> errors, String key) {
  final v = json[key];
  if (v != null && v is! String) {
    errors.add('field "$key" must be String or null');
  }
}

void checkEnumValue(Map<String, Object?> json, List<String> errors, String key,
    Iterable<String> validCodes) {
  final v = json[key];
  if (v is! String) return; // presence/type handled by callers
  if (!validCodes.contains(v)) {
    errors.add('field "$key" has invalid enum value: $v');
  }
}
