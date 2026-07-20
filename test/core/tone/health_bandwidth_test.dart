import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/tone/tone_state_machine.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

void main() {
  group('HealthBandwidth', () {
    test('remaining 随每次切换递减', () {
      final sm = ToneStateMachine(
        config: const HealthBandwidthConfig(
          maxSwitchesPerSession: 5,
          cooldownDurationMs: 1000,
          warningThresholdPct: 80,
        ),
      );
      expect(sm.getHealthBandwidth().remaining, 5);
      sm.switchTone(const ToneSwitchRequest(
        targetTone: Tone.warm,
        trigger: ToneSwitchTrigger.userExplicit,
      ));
      expect(sm.getHealthBandwidth().remaining, 4);
      sm.switchTone(const ToneSwitchRequest(
        targetTone: Tone.encouraging,
        trigger: ToneSwitchTrigger.userExplicit,
      ));
      expect(sm.getHealthBandwidth().remaining, 3);
    });

    test('超过告警阈值时返回 gentleNudge', () {
      final sm = ToneStateMachine(
        config: const HealthBandwidthConfig(
          maxSwitchesPerSession: 10,
          cooldownDurationMs: 1000,
          warningThresholdPct: 50,
        ),
      );
      // 阈值 = ceil(0.5*10) = 5；switchCount > 5 触发 gentleNudge
      Intervention last = Intervention.none;
      for (var i = 0; i < 6; i++) {
        final r = sm.switchTone(const ToneSwitchRequest(
          targetTone: Tone.warm,
          trigger: ToneSwitchTrigger.userExplicit,
        ));
        last = r.intervention;
      }
      expect(last, Intervention.gentleNudge);
    });
  });
}
