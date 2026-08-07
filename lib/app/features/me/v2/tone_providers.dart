import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/core/common/result.dart';
import 'package:primeatlas/core/tone/tone_engine.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// 调性状态管理器（T2-1，纯内存）。
///
/// 不落地任何数据库表 / 迁移——持久化是明确的后续工作。所有切换 / 解锁
/// 委托给 [ToneEngine]，保证业务规则（解锁门槛、冷却、能量下限）只存在于核心层。
class ToneStateNotifier extends StateNotifier<ToneState> {
  ToneStateNotifier({ToneEngine? engine})
      : _engine = engine ?? ToneEngine(),
        super(ToneState.initial);

  final ToneEngine _engine;

  /// 解锁某个调性。仅在 [consent] 为 true 时生效；失败不改变状态。
  void unlockTone(ToneId tone, {bool consent = false}) {
    final res = _engine.unlock(state, tone, consent: consent);
    if (res.isSuccess) state = res.valueOrNull!;
  }

  /// 提议切换到 [tone]。
  ///
  /// 返回底层 [Result]，便于 UI 读取失败原因（冷却 / 能量 / 未解锁）并提示用户。
  /// 成功时更新状态；失败时状态保持不变。
  Result<ToneState> switchTone(ToneId tone, {int energyBandwidth = 80}) {
    final res = _engine.proposeSwitch(
      state,
      tone,
      energyBandwidth: energyBandwidth,
      now: DateTime.now(),
    );
    if (res.isSuccess) state = res.valueOrNull!;
    return res;
  }
}

/// 当前调性状态（activeTone / 解锁集合 / 健康带宽计数）。
final toneStateProvider =
    StateNotifierProvider<ToneStateNotifier, ToneState>(
  (ref) => ToneStateNotifier(),
);
