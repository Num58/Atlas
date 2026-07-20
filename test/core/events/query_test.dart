import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/identity_event_bus.dart';
import 'package:primeatlas/core/events/schemas/conflict_detected.dart';
import 'package:primeatlas/core/events/schemas/tone_change_event.dart';
import 'package:primeatlas/core/conflict/conflict_types.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

ToneChangeEvent _tone(Tone from, Tone to) => ToneChangeEvent(
      from_tone: from,
      to_tone: to,
      trigger: ToneSwitchTrigger.userExplicit,
      blocked_by_system: false,
    );

void main() {
  group('Event log query', () {
    late DefaultIdentityEventBus bus;

    setUp(() async {
      bus = DefaultIdentityEventBus();
      bus.publish(ToneChangeEvent.eventType, _tone(Tone.professional, Tone.warm));
      // Ensure strictly increasing createdAt so the time-window lower-bound
      // assertion has a distinct earliest record to exclude.
      await Future.delayed(const Duration(milliseconds: 5));
      bus.publish(ToneChangeEvent.eventType, _tone(Tone.warm, Tone.strict));
      await Future.delayed(const Duration(milliseconds: 5));
      bus.publish(
          ConflictDetected.eventType,
          const ConflictDetected(
            conflict_id: 'c1',
            conflict_type: ConflictType.goalGoal,
            is_body_related: false,
            disposition: Disposition(blockedUser: false),
            recommended_orchestration: Orchestration(
              type: OrchestrationType.defer,
              rationale: 'r',
              safetyChannelRequired: false,
            ),
          ));
    });

    test('query all returns every published event', () {
      final all = bus.query(const QuerySpec());
      expect(all, hasLength(3));
    });

    test('query filters by eventTypes', () {
      final tones =
          bus.query(const QuerySpec(eventTypes: [ToneChangeEvent.eventType]));
      expect(tones, hasLength(2));
      expect(tones.every((r) => r.eventType == ToneChangeEvent.eventType),
          isTrue);
    });

    test('query filters by time window', () {
      final all = bus.query(const QuerySpec());
      final min = all.map((r) => r.createdAt).reduce((a, b) => a < b ? a : b);
      final max = all.map((r) => r.createdAt).reduce((a, b) => a > b ? a : b);

      // Window covering everything returns all.
      expect(
          bus.query(QuerySpec(from: min, to: max)), hasLength(3));

      // Window strictly after the latest returns nothing.
      expect(bus.query(QuerySpec(from: max + 1000)), isEmpty);

      // Lower bound that excludes the earliest returns the rest.
      final earliest = all.firstWhere((r) => r.createdAt == min);
      final rest = bus.query(QuerySpec(from: min + 1));
      expect(rest.any((r) => r.id == earliest.id), isFalse);
      expect(rest.length, all.length - 1);
    });

    test('query limit caps results', () {
      final limited = bus.query(const QuerySpec(limit: 1));
      expect(limited, hasLength(1));
    });
  });
}
