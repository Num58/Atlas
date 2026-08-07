import 'package:test/test.dart';
import 'package:primeatlas/core/tone/tone_engine.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// T2-1 调性引擎单测。
///
/// 全部用例使用确定性输入（固定 [DateTime] / 显式构造 [ToneState]），
/// 不依赖时钟或随机源，可在纯 Dart 下稳定复跑。
void main() {
  late ToneEngine engine;

  setUp(() => engine = ToneEngine());

  group('unlock', () {
    test('未给出同意时返回 tone_consent_required 失败', () {
      const s = ToneState.initial;
      final res = engine.unlock(s, ToneId.warm, consent: false);
      expect(res.isFailure, isTrue);
      expect(res.failureOrNull?.code, 'tone_consent_required');
      // 状态不被改动
      expect(s.unlockedTones, {ToneId.professional});
    });

    test('给出同意后成功解锁 warm', () {
      const s = ToneState.initial;
      final res = engine.unlock(s, ToneId.warm, consent: true);
      expect(res.isSuccess, isTrue);
      expect(res.valueOrNull?.unlockedTones.contains(ToneId.warm), isTrue);
    });

    test('已解锁的调性再次解锁返回 tone_already_unlocked', () {
      const s = ToneState.initial; // professional 已解锁
      final res = engine.unlock(s, ToneId.professional, consent: true);
      expect(res.isFailure, isTrue);
      expect(res.failureOrNull?.code, 'tone_already_unlocked');
    });
  });

  group('canUnlock 规则', () {
    test('professional 永远可解锁', () {
      const s = ToneState.initial;
      expect(engine.canUnlock(s, ToneId.professional), isTrue);
    });

    test('参与不足（switchesInWindow < 3）时非 professional 不可解锁', () {
      const s = ToneState.initial; // switchesInWindow = 0
      expect(engine.canUnlock(s, ToneId.warm), isFalse);
    });

    test('达到参与门槛（switchesInWindow >= 3）后可解锁', () {
      const s = ToneState(
        activeTone: ToneId.professional,
        unlockedTones: {ToneId.professional},
        lastSwitchAt: null,
        switchesInWindow: ToneEngine.unlockSwitchThreshold,
      );
      expect(engine.canUnlock(s, ToneId.warm), isTrue);
    });

    test('已解锁集合内的调性视为可解锁', () {
      const s = ToneState(
        activeTone: ToneId.professional,
        unlockedTones: {ToneId.professional, ToneId.warm},
        lastSwitchAt: null,
        switchesInWindow: 0,
      );
      expect(engine.canUnlock(s, ToneId.warm), isTrue);
    });
  });

  group('proposeSwitch', () {
    ToneState unlockedWarm() => ToneState(
          activeTone: ToneId.professional,
          unlockedTones: const {ToneId.professional, ToneId.warm},
          lastSwitchAt: null,
          switchesInWindow: 0,
        );

    test('成功切换：更新 activeTone 且 switchesInWindow + 1', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final res = engine.proposeSwitch(
        unlockedWarm(),
        ToneId.warm,
        energyBandwidth: 80,
        now: now,
      );
      expect(res.isSuccess, isTrue);
      final next = res.valueOrNull!;
      expect(next.activeTone, ToneId.warm);
      expect(next.switchesInWindow, 1);
      expect(next.lastSwitchAt, now);
    });

    test('目标未解锁时返回 tone_locked 失败', () {
      const s = ToneState.initial; // 仅 professional 解锁
      final res = engine.proposeSwitch(
        s,
        ToneId.warm,
        energyBandwidth: 80,
        now: DateTime(2026, 1, 1),
      );
      expect(res.isFailure, isTrue);
      expect(res.failureOrNull?.code, 'tone_locked');
    });

    test('冷却期内（< 1 小时）返回 bandwidth 失败', () {
      final recent = DateTime(2026, 1, 1, 12, 0);
      final now = recent.add(const Duration(minutes: 30));
      final s = unlockedWarm().copyWith(lastSwitchAt: recent);
      final res = engine.proposeSwitch(
        s,
        ToneId.warm,
        energyBandwidth: 80,
        now: now,
      );
      expect(res.isFailure, isTrue);
      expect(res.failureOrNull?.code, 'bandwidth');
    });

    test('健康带宽过低（< 20）返回 low_energy 失败', () {
      final s = unlockedWarm();
      final res = engine.proposeSwitch(
        s,
        ToneId.warm,
        energyBandwidth: 10,
        now: DateTime(2026, 1, 1),
      );
      expect(res.isFailure, isTrue);
      expect(res.failureOrNull?.code, 'low_energy');
    });
  });

  group('apply', () {
    test('仅设置 activeTone，其余字段不变', () {
      const s = ToneState.initial;
      final next = engine.apply(s, ToneId.warm);
      expect(next.activeTone, ToneId.warm);
      expect(next.unlockedTones, s.unlockedTones);
      expect(next.switchesInWindow, s.switchesInWindow);
      expect(next.lastSwitchAt, s.lastSwitchAt);
    });
  });
}
