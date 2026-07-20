import 'package:primeatlas/core/tone/tone_types.dart';

/// 调性引擎抽象契约（T2-1）。
///
/// S0 落地为纯类型契约；具体状态机见 [ToneStateMachine]。
/// 引擎层不承载文案（T-RL3 由 `lib/app` 消费焦虑词表实现）。
abstract class ToneEngine {
  /// 执行一次调性切换，返回是否接受及最新健康带宽。
  ToneSwitchResponse switchTone(ToneSwitchRequest req);

  /// 当前调性状态（含会话锚点、切换计数）。
  ToneState getState();

  /// 当前剩余健康带宽。
  HealthBandwidth getHealthBandwidth();
}
