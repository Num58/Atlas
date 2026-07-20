/// 调性系统类型定义（T2-1）。
///
/// 字段名与序列化键一律采用 snake_case（ADR-6，逐字对齐 handoff TS 契约）。
/// 本文件不依赖 `package:flutter`，仅用 `dart:`，可被纯 Dart 单测。
library;

/// 调性枚举。
///
/// 中文展示名（M0 冻结，架构 §5.1）：专业 / 陪伴 / 热血 / 严厉。
/// 代码键：professional | warm | encouraging | strict（默认主调 = professional）。
enum Tone {
  professional,
  warm,
  encouraging,
  strict;

  /// 序列化 code（已为小写单词，与展示语义一致）。
  String get code => name;

  static Tone fromCode(String code) => switch (code) {
        'professional' => Tone.professional,
        'warm' => Tone.warm,
        'encouraging' => Tone.encouraging,
        'strict' => Tone.strict,
        _ => throw ArgumentError('Unknown Tone code: $code'),
      };
}

/// 身份阶段枚举。
///
/// 命名（M0 冻结）：启程者 → 践行者 → 进阶者 → 掌控者。
enum IdentityStage {
  initiate,
  practitioner,
  advanced,
  master;

  String get code => name;

  static IdentityStage fromCode(String code) => switch (code) {
        'initiate' => IdentityStage.initiate,
        'practitioner' => IdentityStage.practitioner,
        'advanced' => IdentityStage.advanced,
        'master' => IdentityStage.master,
        _ => throw ArgumentError('Unknown IdentityStage code: $code'),
      };
}

/// 调性切换触发源。
enum ToneSwitchTrigger {
  userExplicit,
  systemSuggested,
  contextAdaptive;

  String get code => switch (this) {
        ToneSwitchTrigger.userExplicit => 'user_explicit',
        ToneSwitchTrigger.systemSuggested => 'system_suggested',
        ToneSwitchTrigger.contextAdaptive => 'context_adaptive',
      };

  static ToneSwitchTrigger fromCode(String code) => switch (code) {
        'user_explicit' => ToneSwitchTrigger.userExplicit,
        'system_suggested' => ToneSwitchTrigger.systemSuggested,
        'context_adaptive' => ToneSwitchTrigger.contextAdaptive,
        _ => throw ArgumentError('Unknown ToneSwitchTrigger code: $code'),
      };
}

/// 健康带宽干预级别。
enum Intervention {
  none,
  gentleNudge,
  cooldown;

  String get code => switch (this) {
        Intervention.none => 'none',
        Intervention.gentleNudge => 'gentle_nudge',
        Intervention.cooldown => 'cooldown',
      };

  static Intervention fromCode(String code) => switch (code) {
        'none' => Intervention.none,
        'gentle_nudge' => Intervention.gentleNudge,
        'cooldown' => Intervention.cooldown,
        _ => throw ArgumentError('Unknown Intervention code: $code'),
      };
}

/// 当前调性状态快照。
class ToneState {
  final Tone currentTone;
  final Tone sessionAnchorTone;
  final int switchCount;
  final int lastSwitchAt;

  const ToneState({
    required this.currentTone,
    required this.sessionAnchorTone,
    required this.switchCount,
    required this.lastSwitchAt,
  });

  Map<String, Object?> toJson() => {
        'current_tone': currentTone.code,
        'session_anchor_tone': sessionAnchorTone.code,
        'switch_count': switchCount,
        'last_switch_at': lastSwitchAt,
      };

  static ToneState fromJson(Map<String, Object?> json) => ToneState(
        currentTone: Tone.fromCode(json['current_tone'] as String),
        sessionAnchorTone:
            Tone.fromCode(json['session_anchor_tone'] as String),
        switchCount: json['switch_count'] as int,
        lastSwitchAt: json['last_switch_at'] as int,
      );
}

/// 调性切换请求。
class ToneSwitchRequest {
  final Tone targetTone;
  final ToneSwitchTrigger trigger;
  final Map<String, Object>? context;

  const ToneSwitchRequest({
    required this.targetTone,
    required this.trigger,
    this.context,
  });

  Map<String, Object?> toJson() => {
        'target_tone': targetTone.code,
        'trigger': trigger.code,
        'context': context,
      };

  static ToneSwitchRequest fromJson(Map<String, Object?> json) =>
      ToneSwitchRequest(
        targetTone: Tone.fromCode(json['target_tone'] as String),
        trigger: ToneSwitchTrigger.fromCode(json['trigger'] as String),
        context: (json['context'] as Map?)?.cast<String, Object>(),
      );
}

/// 剩余健康带宽。
class HealthBandwidth {
  final int remaining;
  final int threshold;

  const HealthBandwidth({required this.remaining, required this.threshold});

  Map<String, Object?> toJson() => {
        'remaining': remaining,
        'threshold': threshold,
      };

  static HealthBandwidth fromJson(Map<String, Object?> json) => HealthBandwidth(
        remaining: json['remaining'] as int,
        threshold: json['threshold'] as int,
      );
}

/// 调性切换响应。
class ToneSwitchResponse {
  final bool accepted;
  final Tone newTone;
  final HealthBandwidth healthBandwidth;
  final Intervention intervention;

  const ToneSwitchResponse({
    required this.accepted,
    required this.newTone,
    required this.healthBandwidth,
    required this.intervention,
  });

  Map<String, Object?> toJson() => {
        'accepted': accepted,
        'new_tone': newTone.code,
        'health_bandwidth': healthBandwidth.toJson(),
        'intervention': intervention.code,
      };

  static ToneSwitchResponse fromJson(Map<String, Object?> json) =>
      ToneSwitchResponse(
        accepted: json['accepted'] as bool,
        newTone: Tone.fromCode(json['new_tone'] as String),
        healthBandwidth: HealthBandwidth.fromJson(
            json['health_bandwidth'] as Map<String, Object?>),
        intervention: Intervention.fromCode(json['intervention'] as String),
      );
}

/// 健康带宽配置。
class HealthBandwidthConfig {
  final int maxSwitchesPerSession;
  final int cooldownDurationMs;
  final double warningThresholdPct;

  const HealthBandwidthConfig({
    required this.maxSwitchesPerSession,
    required this.cooldownDurationMs,
    required this.warningThresholdPct,
  });

  Map<String, Object?> toJson() => {
        'max_switches_per_session': maxSwitchesPerSession,
        'cooldown_duration_ms': cooldownDurationMs,
        'warning_threshold_pct': warningThresholdPct,
      };

  static HealthBandwidthConfig fromJson(Map<String, Object?> json) =>
      HealthBandwidthConfig(
        maxSwitchesPerSession: json['max_switches_per_session'] as int,
        cooldownDurationMs: json['cooldown_duration_ms'] as int,
        warningThresholdPct: json['warning_threshold_pct'] as double,
      );
}
