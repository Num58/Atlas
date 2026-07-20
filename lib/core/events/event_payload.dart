/// Base class for all event payloads carried by the [IdentityEventBus].
///
/// Implementations must be serializable to a snake_case JSON map via [toJson].
/// Field names and JSON keys follow the handoff TS contracts (ADR-6): snake_case.
abstract class EventPayload {
  /// Serialize to a snake_case JSON map.
  Map<String, Object?> toJson();
}

/// Subscriber callback invoked synchronously after an event is persisted.
///
/// (EventRecord lives in [event_receipt.dart]; this typedef is declared here so
/// that [EventPayload] and [EventHandler] share a single import surface.)
typedef EventHandler = void Function(EventRecord record);
