import 'package:meta/meta.dart';

/// 调性系统类型定义（T2-1）。
///
/// 纯 Dart（不依赖 `package:flutter`），可被纯 Dart 单测覆盖。
/// 调性以**语义 token** 表达（label / description / accentToken /
/// microcopyStyle），UI 层据此取色与文案，绝不直接持有原始颜色。
@immutable
enum ToneId {
  professional,
  warm,
  encouraging,
  strict;

  /// 序列化 code（与展示语义保持一致的小写单词）。
  String get code => name;

  static ToneId fromCode(String code) => switch (code) {
        'professional' => ToneId.professional,
        'warm' => ToneId.warm,
        'encouraging' => ToneId.encouraging,
        'strict' => ToneId.strict,
        _ => throw ArgumentError('Unknown ToneId code: $code'),
      };
}

/// 便捷别名：[Tone] 与 [ToneId] 同义，保留以兼容事件子系统命名
/// （如 [ToneChangeEvent] / [ContentToneTag] 直接以 `Tone` 表达调性）。
typedef Tone = ToneId;

/// 调性切换触发来源（T2-1）。
///
/// 三种来源语义不同：
/// - [userExplicit]：用户主动切换；
/// - [systemSuggested]：系统建议在用户确认后切换；
/// - [contextAdaptive]：上下文（如能量 / 带宽）自适应切换。
enum ToneSwitchTrigger {
  userExplicit,
  systemSuggested,
  contextAdaptive;

  /// 序列化 code（与事件校验枚举值保持一致的下划线命名）。
  String get code => switch (this) {
        userExplicit => 'user_explicit',
        systemSuggested => 'system_suggested',
        contextAdaptive => 'context_adaptive',
      };

  static ToneSwitchTrigger fromCode(String code) => switch (code) {
        'user_explicit' => userExplicit,
        'system_suggested' => systemSuggested,
        'context_adaptive' => contextAdaptive,
        _ => throw ArgumentError('Unknown ToneSwitchTrigger code: $code'),
      };
}

/// 单一调性的语义画像。
///
/// 不含任何颜色字面量；[accentToken] 是设计系统里的语义强调色键，
/// [microcopyStyle] 是微文案语气键，二者均由 UI 层解析。
@immutable
class ToneProfile {
  const ToneProfile({
    required this.id,
    required this.label,
    required this.description,
    required this.accentToken,
    required this.microcopyStyle,
  });

  final ToneId id;
  final String label;
  final String description;
  final String accentToken;
  final String microcopyStyle;

  /// 产品纪实中的四种调性画像（默认主调 = professional）。
  static const List<ToneProfile> all = [
    ToneProfile(
      id: ToneId.professional,
      label: '专业',
      description: '克制、清晰、以事实与结构为先。',
      accentToken: 'accentProfessional',
      microcopyStyle: 'calm',
    ),
    ToneProfile(
      id: ToneId.warm,
      label: '陪伴',
      description: '温和、贴近、像同行者一样说话。',
      accentToken: 'accentWarm',
      microcopyStyle: 'gentle',
    ),
    ToneProfile(
      id: ToneId.encouraging,
      label: '热血',
      description: '有力、鼓劲、推动你向前一步。',
      accentToken: 'accentEncouraging',
      microcopyStyle: 'energizing',
    ),
    ToneProfile(
      id: ToneId.strict,
      label: '严厉',
      description: '直接、较真、对借口零容忍。',
      accentToken: 'accentStrict',
      microcopyStyle: 'firm',
    ),
  ];

  static ToneProfile byId(ToneId id) =>
      all.firstWhere((p) => p.id == id);
}

/// 调性状态快照。
///
/// 单一主调 + 渐进解锁集合 + 健康带宽计数。所有字段均可被纯 Dart 构造，
/// 便于测试用确定性输入驱动引擎。
@immutable
class ToneState {
  const ToneState({
    required this.activeTone,
    required this.unlockedTones,
    required this.lastSwitchAt,
    required this.switchesInWindow,
  });

  /// 当前生效的主调。
  final ToneId activeTone;

  /// 已解锁、可切换的调性集合。
  final Set<ToneId> unlockedTones;

  /// 上次切换时间；从未切换时为 null。
  final DateTime? lastSwitchAt;

  /// 当前健康带宽窗口内的切换次数（用于解锁判定与调试）。
  final int switchesInWindow;

  /// 初始状态：仅 professional 解锁，无切换记录。
  static const ToneState initial = ToneState(
        activeTone: ToneId.professional,
        unlockedTones: {ToneId.professional},
        lastSwitchAt: null,
        switchesInWindow: 0,
      );

  ToneState copyWith({
    ToneId? activeTone,
    Set<ToneId>? unlockedTones,
    DateTime? lastSwitchAt,
    bool clearLastSwitchAt = false,
    int? switchesInWindow,
  }) =>
      ToneState(
        activeTone: activeTone ?? this.activeTone,
        unlockedTones: unlockedTones ?? this.unlockedTones,
        lastSwitchAt:
            clearLastSwitchAt ? null : (lastSwitchAt ?? this.lastSwitchAt),
        switchesInWindow: switchesInWindow ?? this.switchesInWindow,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToneState &&
          other.activeTone == activeTone &&
          _setEquals(other.unlockedTones, unlockedTones) &&
          other.lastSwitchAt == lastSwitchAt &&
          other.switchesInWindow == switchesInWindow;

  @override
  int get hashCode =>
      activeTone.hashCode ^
      _setHash(unlockedTones) ^
      lastSwitchAt.hashCode ^
      switchesInWindow.hashCode;

  static bool _setEquals(Set<ToneId> a, Set<ToneId> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  static int _setHash(Set<ToneId> s) =>
      s.fold(0, (h, e) => h ^ e.hashCode);
}
