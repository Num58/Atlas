import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/identity_event_bus.dart';
import 'package:primeatlas/core/events/schemas/arbitration_event.dart';
import 'package:primeatlas/core/events/schemas/tone_change_event.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

void main() {
  group('DefaultIdentityEventBus publish/subscribe/validate', () {
    late DefaultIdentityEventBus bus;

    setUp(() => bus = DefaultIdentityEventBus());

    test('publish valid ToneChangeEvent -> ok true, subscriber fired, query returns it',
        () {
      var fired = false;
      late EventRecord received;
      bus.subscribe(ToneChangeEvent.eventType, (EventRecord rec) {
        fired = true;
        received = rec;
      });

      const evt = ToneChangeEvent(
        from_tone: Tone.professional,
        to_tone: Tone.warm,
        trigger: ToneSwitchTrigger.userExplicit,
        blocked_by_system: false,
      );
      final receipt = bus.publish(ToneChangeEvent.eventType, evt);

      expect(receipt.ok, isTrue);
      expect(receipt.errors, isNull);
      expect(fired, isTrue);
      expect(received.eventType, ToneChangeEvent.eventType);
      expect(received.payload['to_tone'], 'warm');

      final results = bus.query(const QuerySpec(eventTypes: [ToneChangeEvent.eventType]));
      expect(results, hasLength(1));
      expect(results.first.id, received.id);
    });

    test('publish invalid payload -> ok false and NOT stored', () {
      // C-RL2 violation: i_will_do_it without user_initiated_edit.
      const bad = ArbitrationEvent(
        conflict_id: 'c1',
        chosen_track: ChosenTrack.iWillDoIt,
        rationale_display_complete: true,
        retained_override_entry: true,
        user_initiated_edit: null,
      );
      final receipt = bus.publish(ArbitrationEvent.eventType, bad);

      expect(receipt.ok, isFalse);
      expect(receipt.errors, isNotNull);
      final stored =
          bus.query(const QuerySpec(eventTypes: [ArbitrationEvent.eventType]));
      expect(stored, isEmpty);
    });

    test('validate() returns valid:false for an invalid payload', () {
      const bad = ArbitrationEvent(
        conflict_id: 'c1',
        chosen_track: ChosenTrack.iWillDoIt,
        rationale_display_complete: true,
        retained_override_entry: true,
        user_initiated_edit: null,
      );
      final result = bus.validate(ArbitrationEvent.eventType, bad);
      expect(result.valid, isFalse);
    });

    test('unsubscribe stops further dispatch', () {
      var count = 0;
      final unsub = bus.subscribe(ToneChangeEvent.eventType,
          (rec) => count++);
      bus.publish(
          ToneChangeEvent.eventType,
          const ToneChangeEvent(
            from_tone: Tone.professional,
            to_tone: Tone.strict,
            trigger: ToneSwitchTrigger.systemSuggested,
            blocked_by_system: false,
          ));
      unsub();
      bus.publish(
          ToneChangeEvent.eventType,
          const ToneChangeEvent(
            from_tone: Tone.strict,
            to_tone: Tone.warm,
            trigger: ToneSwitchTrigger.contextAdaptive,
            blocked_by_system: false,
          ));
      expect(count, 1);
    });
  });
}
