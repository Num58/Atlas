import 'package:primeatlas/core/common/domain_failure.dart';
import 'package:primeatlas/core/common/result.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// 调性引擎（T2-1 核心实现，纯 Dart）。
///
/// 职责：
/// - 暴露四种语义调性画像；
/// - 渐进解锁（professional 默认解锁，其余按参与规则或显式同意解锁）；
/// - 健康带宽受限的切换（冷却 + 能量下限），返回 [Result]，绝不直接抛异常。
///
/// 所有错误以 [DomainFailure] 表达：`code` 供 UI 分支，`messageKey` 供 i18n，
/// `details` 仅用于诊断。
class ToneEngine {
  /// 切换冷却：两次切换须间隔至少 1 小时。
  static const Duration switchCooldown = Duration(hours: 1);

  /// 解锁所需的参与门槛：窗口内切换次数达到此值即视为“活跃用户”。
  static const int unlockSwitchThreshold = 3;

  /// 切换所需的最低健康带宽（能量低于此值禁止切换）。
  static const int minEnergyBandwidth = 20;

  /// 全部可用调性画像（顺序即产品纪实中的四种）。
  List<ToneProfile> availableProfiles() => ToneProfile.all;

  /// 某调性在当前状态下是否可解锁（不含显式同意这一动作闸门）。
  ///
  /// professional 永远可解锁；其余在“已解锁”或“达到参与门槛”时为 true。
  bool canUnlock(ToneState s, ToneId t) {
    if (t == ToneId.professional) return true;
    if (s.unlockedTones.contains(t)) return true;
    return s.switchesInWindow >= unlockSwitchThreshold;
  }

  /// 解锁一个调性。
  ///
  /// 失败码：
  /// - `tone_already_unlocked`：目标已解锁；
  /// - `tone_consent_required`：未给出显式同意。
  /// 成功时把目标加入已解锁集合，其余字段不变。
  Result<ToneState> unlock(ToneState s, ToneId t, {required bool consent}) {
    if (s.unlockedTones.contains(t)) {
      return Failure(
        DomainFailure(
          code: 'tone_already_unlocked',
          retryable: false,
          messageKey: 'tone.already_unlocked',
          details: {'tone': t.code},
        ),
      );
    }
    if (!consent) {
      return Failure(
        DomainFailure(
          code: 'tone_consent_required',
          retryable: false,
          messageKey: 'tone.consent_required',
          details: {'tone': t.code},
        ),
      );
    }
    final next = s.copyWith(
      unlockedTones: {...s.unlockedTones, t},
    );
    return Success(next);
  }

  /// 提议切换到 [target]。
  ///
  /// 失败码（按检查顺序）：
  /// - `tone_locked`：目标尚未解锁；
  /// - `bandwidth`：处于冷却期内（距上次切换 < 1 小时）；
  /// - `low_energy`：健康带宽低于 [minEnergyBandwidth]。
  ///
  /// 成功时更新 activeTone / lastSwitchAt / switchesInWindow+1，保持已解锁集合。
  Result<ToneState> proposeSwitch(
    ToneState s,
    ToneId target, {
    required int energyBandwidth,
    required DateTime now,
  }) {
    if (!s.unlockedTones.contains(target)) {
      return Failure(
        DomainFailure(
          code: 'tone_locked',
          retryable: false,
          messageKey: 'tone.locked',
          details: {'tone': target.code},
        ),
      );
    }
    if (s.lastSwitchAt != null &&
        now.difference(s.lastSwitchAt!) < switchCooldown) {
      return Failure(
        DomainFailure(
          code: 'bandwidth',
          retryable: true,
          messageKey: 'tone.switch_cooldown',
          details: {
            'lastSwitchAt': s.lastSwitchAt!.toIso8601String(),
            'now': now.toIso8601String(),
          },
        ),
      );
    }
    if (energyBandwidth < minEnergyBandwidth) {
      return Failure(
        DomainFailure(
          code: 'low_energy',
          retryable: true,
          messageKey: 'tone.low_energy',
          details: {'energyBandwidth': energyBandwidth},
        ),
      );
    }
    final next = s.copyWith(
      activeTone: target,
      lastSwitchAt: now,
      switchesInWindow: s.switchesInWindow + 1,
    );
    return Success(next);
  }

  /// 直接套用主调（不校验解锁 / 带宽），仅设置 activeTone。
  ///
  /// 用于确定性回放或测试；运行时切换应走 [proposeSwitch]。
  ToneState apply(ToneState s, ToneId target) =>
      s.copyWith(activeTone: target);
}
