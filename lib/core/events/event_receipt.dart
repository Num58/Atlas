/// Receipt returned by [IdentityEventBus.publish].
///
/// `ok == false` means the payload was rejected by validation and was NOT
/// stored or dispatched.
class EventReceipt {
  final String receiptId;
  final String eventType;
  final int storedAt; // epoch ms
  final bool ok; // false = rejected by validation
  final List<String>? errors; // rejection reasons

  const EventReceipt({
    required this.receiptId,
    required this.eventType,
    required this.storedAt,
    required this.ok,
    this.errors,
  });
}

/// Result of validating an [EventPayload].
///
/// `errors` => hard failures (payload rejected, not stored).
/// `warnings` => business-invariant violations that are recorded for dashboard
/// alerting but do NOT reject the payload (P-RL1 / P-RL3 consistency signals).
class ValidationResult {
  final bool valid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult(this.valid,
      [this.errors = const [], this.warnings = const []]);

  const ValidationResult.ok()
      : valid = true,
        errors = const [],
        warnings = const [];

  const ValidationResult.failed(List<String> errors,
      [List<String> warnings = const []])
      : valid = false,
        errors = errors,
        warnings = warnings;

  bool get hasWarnings => warnings.isNotEmpty;
}

/// Query specification for the local dashboard query layer.
class QuerySpec {
  final List<String> eventTypes; // empty = all event types
  final int? from; // epoch ms lower bound (inclusive)
  final int? to; // epoch ms upper bound (inclusive)
  final int? limit;
  final String? sessionId;

  const QuerySpec({
    this.eventTypes = const [],
    this.from,
    this.to,
    this.limit,
    this.sessionId,
  });
}

/// A persisted event record as stored in the [EventLogRepository].
class EventRecord {
  final String id;
  final String eventType;
  final Map<String, Object?> payload; // deserialized payload map
  final int createdAt; // epoch ms
  final String? sessionId;

  const EventRecord({
    required this.id,
    required this.eventType,
    required this.payload,
    required this.createdAt,
    this.sessionId,
  });
}
