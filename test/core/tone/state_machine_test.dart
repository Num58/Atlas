import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/tone/tone_engine.dart';
import 'package:primeatlas/core/tone/tone_state_machine.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

void main() {
  group('ToneStateMachine', () {
    test('默认主调为 professional，会话锚点固定 (T-RL2)', () {
      final sm = ToneStateMachine(
        config: const HealthBandwidthConfig(
          maxSwitchesPerSession: 5,
          cooldownDurationMs: 1000,
          warningThresholdPct: 60,
        ),
      );
      expect(sm.getState().currentTone, Tone.professional);
      expect(sm.getState().sessionAnchorTone, Tone.professional);
    });

    test('switchTone 接受并切换状态，会话锚点保持不变 (T-RL2)', () {
      final sm = ToneStateMachine(
        config: const HealthBandwidthConfig(
          maxSwitchesPerSession: 5,
          cooldownDurationMs: 1000,
          warningThresholdPct: 80,
        ),
      );
      final resp = sm.switchTone(ToneSwitchRequest(
        targetTone: Tone.warm,
        trigger: ToneSwitchTrigger.userExplicit,
      ));
      expect(resp.accepted, isTrue);
      expect(resp.newTone, Tone.warm);
      expect(sm.getState().currentTone, Tone.warm);
      expect(sm.getState().switchCount, 1);
      // 会话锚点必须恒定
      expect(sm.getState().sessionAnchorTone, Tone.professional);
    });

    test('超 maxSwitchesPerSession 触发 cooldown 且 accepted=false (T-RL1)', () {
      const max = 3;
      final sm = ToneStateMachine(
        config: HealthBandwidthConfig(
          maxSwitchesPerSession: max,
          cooldownDurationMs: 1000,
          warningThresholdPct: 80,
        ),
      );
      for (var i = 0; i < max; i++) {
        sm.switchTone(ToneSwitchRequest(
          targetTone: Tone.warm,
          trigger: ToneSwitchTrigger.userExplicit,
        ));
      }
      final resp = sm.switchTone(ToneSwitchRequest(
        targetTone: Tone.strict,
        trigger: ToneSwitchTrigger.userExplicit,
      ));
      expect(resp.intervention, Intervention.cooldown);
      expect(resp.accepted, isFalse);
      expect(resp.healthBandwidth.remaining, 0);
      // 非阻断：调性软回退到会话锚点，无 blocked_by_system 概念
      expect(sm.getState().currentTone, Tone.professional);
    });
  });
}
