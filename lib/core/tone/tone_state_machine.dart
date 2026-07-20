import 'package:primeatlas/core/tone/tone_engine.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// 调性状态机（S0 功能实现，T2-1）。
///
/// 覆盖 4 身份阶段 × 4 调性 = 16 合法状态空间；强制两条红线：
/// - **T-RL2 同会话守恒**：`sessionAnchorTone` 在构造时固定，会话内不漂移。
/// - **T-RL1 健康带宽**：切换计数超阈值触发温和提示 / 冷却，但**非阻断**
///   （冷却时软回退到会话锚点，不存在 `blocked_by_system` 概念）。
class ToneStateMachine implements ToneEngine {
  final HealthBandwidthConfig _config;
  final IdentityStage _identityStage;

  Tone _currentTone;
  final Tone _sessionAnchorTone;
  int _switchCount = 0;
  int _lastSwitchAt = 0;

  ToneStateMachine({
    required HealthBandwidthConfig config,
    Tone initialTone = Tone.professional,
    IdentityStage initialStage = IdentityStage.initiate,
  })  : _config = config,
        _identityStage = initialStage,
        _currentTone = initialTone,
        _sessionAnchorTone = initialTone;

  /// 当前身份阶段（渐进解锁的占位，供 S1 算法卡扩展）。
  IdentityStage get identityStage => _identityStage;

  /// 达到该计数后进入温和提示（gentleNudge）。
  int _warningThresholdCount() =>
      (_config.warningThresholdPct / 100.0 * _config.maxSwitchesPerSession)
          .ceil();

  @override
  ToneSwitchResponse switchTone(ToneSwitchRequest req) {
    _switchCount += 1;
    _lastSwitchAt = DateTime.now().millisecondsSinceEpoch;

    final threshold = _warningThresholdCount();
    final Intervention intervention;
    final bool accepted;
    final Tone newTone;

    if (_switchCount >= _config.maxSwitchesPerSession) {
      // T-RL1 冷却：非阻断，软回退到会话锚点。
      intervention = Intervention.cooldown;
      accepted = false;
      newTone = _sessionAnchorTone;
    } else if (_switchCount > threshold) {
      // 超出健康占比但未触顶：温和提示，仍允许切换。
      intervention = Intervention.gentleNudge;
      accepted = true;
      newTone = req.targetTone;
    } else {
      intervention = Intervention.none;
      accepted = true;
      newTone = req.targetTone;
    }

    _currentTone = newTone;

    final remaining = (_config.maxSwitchesPerSession - _switchCount)
        .clamp(0, _config.maxSwitchesPerSession);
    final bandwidth =
        HealthBandwidth(remaining: remaining, threshold: threshold);

    return ToneSwitchResponse(
      accepted: accepted,
      newTone: _currentTone,
      healthBandwidth: bandwidth,
      intervention: intervention,
    );
  }

  @override
  ToneState getState() => ToneState(
        currentTone: _currentTone,
        sessionAnchorTone: _sessionAnchorTone,
        switchCount: _switchCount,
        lastSwitchAt: _lastSwitchAt,
      );

  @override
  HealthBandwidth getHealthBandwidth() {
    final remaining = (_config.maxSwitchesPerSession - _switchCount)
        .clamp(0, _config.maxSwitchesPerSession);
    return HealthBandwidth(
        remaining: remaining, threshold: _warningThresholdCount());
  }
}
