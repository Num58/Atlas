import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/events/dashboard.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/identity_event_bus.dart';
import 'package:primeatlas/core/events/schemas/conflict_detected.dart';
import 'package:primeatlas/core/events/schemas/tone_change_event.dart';
import 'package:primeatlas/core/conflict/conflict_types.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

void main() {
  group('Dashboard aggregations', () {
    late DefaultIdentityEventBus bus;

    setUp(() {
      bus = DefaultIdentityEventBus();
      for (var i = 0; i < 3; i++) {
        bus.publish(
            ToneChangeEvent.eventType,
            ToneChangeEvent(
              from_tone: Tone.professional,
              to_tone: Tone.warm,
              trigger: ToneSwitchTrigger.userExplicit,
              blocked_by_system: false,
            ));
      }
      for (var i = 0; i < 2; i++) {
        bus.publish(
            ConflictDetected.eventType,
            ConflictDetected(
              conflict_id: 'c$i',
              conflict_type: ConflictType.goalGoal,
              is_body_related: false,
              disposition: Disposition(blockedUser: false),
              recommended_orchestration: Orchestration(
                type: OrchestrationType.defer,
                rationale: 'r',
                safetyChannelRequired: false,
              ),
            ));
      }
    });

    test('redlineCoverage counts per event type', () {
      final dash = Dashboard(bus.query(QuerySpec()));
      final cov = dash.redlineCoverage();
      expect(cov[ToneChangeEvent.eventType], 3);
      expect(cov[ConflictDetected.eventType], 2);
      expect(cov.length, 2);
    });

    test('timeSeries buckets a single event type', () {
      final dash = Dashboard(bus.query(QuerySpec()));
      // All events land within the same 1-hour bucket.
      final series =
          dash.timeSeries(ToneChangeEvent.eventType, const Duration(hours: 1));
      expect(series.length, 1);
      expect(series.values.first, 3);
    });

    test('timeSeries returns empty for an absent event type', () {
      final dash = Dashboard(bus.query(QuerySpec()));
      expect(
          dash.timeSeries('unknown_event', const Duration(hours: 1)), isEmpty);
    });
  });
}
