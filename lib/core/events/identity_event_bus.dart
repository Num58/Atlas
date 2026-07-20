import 'event_payload.dart';
import 'event_receipt.dart';
import 'validator.dart';
import '../storage/event_log_repository.dart';
import '../storage/in_memory_event_log.dart';
import 'schemas/tone_change_event.dart';
import 'schemas/content_tone_tag.dart';
import 'schemas/conflict_detected.dart';
import 'schemas/arbitration_event.dart';
import 'schemas/profile_field_update.dart';
import 'schemas/identity_transition_event.dart';
import 'schemas/dimension_data_presence.dart';

/// Local-first identity event bus: publish / subscribe / validate / query.
///
/// No `package:flutter` dependency — runs in a plain Dart context. Persists to
/// an [EventLogRepository] and dispatches to in-memory subscribers. Invalid
/// payloads are rejected with 100% coverage (never stored, never dispatched).
abstract class IdentityEventBus {
  /// Publish an event: validate first; on failure return `ok:false` and do not
  /// store or dispatch. On success, persist and dispatch, return `ok:true`.
  EventReceipt publish(String eventType, EventPayload payload);

  /// Subscribe to an event type. Returns an unsubscribe function.
  void Function() subscribe(String eventType, EventHandler handler);

  /// Validate only (no store, no dispatch).
  ValidationResult validate(String eventType, EventPayload payload);

  /// Local dashboard query layer over the persisted event log.
  List<EventRecord> query(QuerySpec spec);
}

/// Default in-memory-dispatching implementation used across S0.
class DefaultIdentityEventBus implements IdentityEventBus {
  final ValidatorRegistry _registry;
  final EventLogRepository _repository;
  final Map<String, Set<EventHandler>> _handlers = {};

  /// Optional session id stamped onto every published record.
  String? sessionId;

  int _idCounter = 0;

  DefaultIdentityEventBus({
    EventLogRepository? repository,
    ValidatorRegistry? registry,
    this.sessionId,
  })  : _repository = repository ?? InMemoryEventLogRepository(),
        _registry = registry ?? ValidatorRegistry() {
    _registerDefaultValidators();
  }

  void _registerDefaultValidators() {
    _registry
      ..register(ToneChangeEvent.eventType, ToneChangeEventValidator())
      ..register(ContentToneTag.eventType, ContentToneTagValidator())
      ..register(ConflictDetected.eventType, ConflictDetectedValidator())
      ..register(ArbitrationEvent.eventType, ArbitrationEventValidator())
      ..register(ProfileFieldUpdate.eventType, ProfileFieldUpdateValidator())
      ..register(
          IdentityTransitionEvent.eventType, IdentityTransitionEventValidator())
      ..register(
          DimensionDataPresence.eventType, DimensionDataPresenceValidator());
  }

  @override
  ValidationResult validate(String eventType, EventPayload payload) {
    final v = _registry.lookup(eventType);
    if (v == null) {
      return ValidationResult.failed(
          ['no validator registered for event type: $eventType']);
    }
    return v.validate(payload);
  }

  @override
  EventReceipt publish(String eventType, EventPayload payload) {
    final result = validate(eventType, payload);
    final storedAt = DateTime.now().millisecondsSinceEpoch;
    if (!result.valid) {
      return EventReceipt(
        receiptId: _nextId('rcpt'),
        eventType: eventType,
        storedAt: storedAt,
        ok: false,
        errors: result.errors,
      );
    }
    final record = EventRecord(
      id: _nextId('evt'),
      eventType: eventType,
      payload: payload.toJson(),
      createdAt: storedAt,
      sessionId: sessionId,
    );
    _repository.append(record);
    _dispatch(record);
    return EventReceipt(
      receiptId: _nextId('rcpt'),
      eventType: eventType,
      storedAt: storedAt,
      ok: true,
    );
  }

  @override
  void Function() subscribe(String eventType, EventHandler handler) {
    _handlers.putIfAbsent(eventType, () => <EventHandler>{}).add(handler);
    return () {
      _handlers[eventType]?.remove(handler);
    };
  }

  void _dispatch(EventRecord record) {
    final set = _handlers[record.eventType];
    if (set == null) return;
    // Copy to a list so handlers may (un)subscribe during dispatch safely.
    for (final h in List<EventHandler>.of(set)) {
      h(record);
    }
  }

  @override
  List<EventRecord> query(QuerySpec spec) => _repository.query(spec);

  String _nextId(String prefix) {
    _idCounter++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${_idCounter}';
  }
}
