/// Prime Pulse type definitions.
///
/// Pulse is the adaptive rhythm engine that tracks energy cycles across
/// domains. It is advisory only -- it does NOT unlock or block training.
///
/// All JSON keys are snake_case (ADR-6). No Flutter dependency.
library;

import 'package:meta/meta.dart';

/// Pulse phase enum.
///
/// Represents the current stage of the energy cycle:
/// dormant -> awakening -> active -> peaking -> recovering -> dormant.
enum PulsePhase {
  dormant,
  awakening,
  active,
  peaking,
  recovering;

  String get code => name;

  static PulsePhase fromCode(String code) => switch (code) {
        'dormant' => PulsePhase.dormant,
        'awakening' => PulsePhase.awakening,
        'active' => PulsePhase.active,
        'peaking' => PulsePhase.peaking,
        'recovering' => PulsePhase.recovering,
        _ => throw ArgumentError('Unknown PulsePhase code: $code'),
      };
}

/// Pulse intensity enum.
///
/// Represents the suggested engagement level for the current phase.
enum PulseIntensity {
  minimal,
  low,
  moderate,
  high,
  maximum;

  String get code => name;

  static PulseIntensity fromCode(String code) => switch (code) {
        'minimal' => PulseIntensity.minimal,
        'low' => PulseIntensity.low,
        'moderate' => PulseIntensity.moderate,
        'high' => PulseIntensity.high,
        'maximum' => PulseIntensity.maximum,
        _ => throw ArgumentError('Unknown PulseIntensity code: $code'),
      };
}

/// A single point on the energy curve.
@immutable
class EnergyCurvePoint {
  final int timestampUs;
  final int energyLevel;

  const EnergyCurvePoint({
    required this.timestampUs,
    required this.energyLevel,
  }) : assert(energyLevel >= 0 && energyLevel <= 100);

  Map<String, Object?> toJson() => {
        'timestamp_us': timestampUs,
        'energy_level': energyLevel,
      };

  static EnergyCurvePoint fromJson(Map<String, Object?> json) =>
      EnergyCurvePoint(
        timestampUs: json['timestamp_us'] as int,
        energyLevel: json['energy_level'] as int,
      );
}

/// A pulse signal -- a single advisory output from the engine.
///
/// Pulse signals are advisory. They suggest but never enforce.
@immutable
class PulseSignal {
  final PulsePhase phase;
  final PulseIntensity intensity;
  final int energyLevel;
  final String? domainFocus;
  final String messageKey;
  final int occurredAtUs;

  const PulseSignal({
    required this.phase,
    required this.intensity,
    required this.energyLevel,
    this.domainFocus,
    required this.messageKey,
    required this.occurredAtUs,
  }) : assert(energyLevel >= 0 && energyLevel <= 100);

  Map<String, Object?> toJson() => {
        'phase': phase.code,
        'intensity': intensity.code,
        'energy_level': energyLevel,
        'domain_focus': domainFocus,
        'message_key': messageKey,
        'occurred_at_us': occurredAtUs,
      };

  static PulseSignal fromJson(Map<String, Object?> json) => PulseSignal(
        phase: PulsePhase.fromCode(json['phase'] as String),
        intensity: PulseIntensity.fromCode(json['intensity'] as String),
        energyLevel: json['energy_level'] as int,
        domainFocus: json['domain_focus'] as String?,
        messageKey: json['message_key'] as String,
        occurredAtUs: json['occurred_at_us'] as int,
      );
}

/// Current pulse state -- the persistent rhythm state.
@immutable
class PulseState {
  final PulsePhase currentPhase;
  final int phaseStartedAtUs;
  final List<PulseSignal> signalsToday;
  final List<EnergyCurvePoint> energyCurve;

  const PulseState({
    required this.currentPhase,
    required this.phaseStartedAtUs,
    this.signalsToday = const [],
    this.energyCurve = const [],
  });

  PulseState copyWith({
    PulsePhase? currentPhase,
    int? phaseStartedAtUs,
    List<PulseSignal>? signalsToday,
    List<EnergyCurvePoint>? energyCurve,
  }) =>
      PulseState(
        currentPhase: currentPhase ?? this.currentPhase,
        phaseStartedAtUs: phaseStartedAtUs ?? this.phaseStartedAtUs,
        signalsToday: signalsToday ?? this.signalsToday,
        energyCurve: energyCurve ?? this.energyCurve,
      );

  Map<String, Object?> toJson() => {
        'current_phase': currentPhase.code,
        'phase_started_at_us': phaseStartedAtUs,
        'signals_today': signalsToday.map((s) => s.toJson()).toList(),
        'energy_curve': energyCurve.map((p) => p.toJson()).toList(),
      };

  static PulseState fromJson(Map<String, Object?> json) => PulseState(
        currentPhase: PulsePhase.fromCode(json['current_phase'] as String),
        phaseStartedAtUs: json['phase_started_at_us'] as int,
        signalsToday: (json['signals_today'] as List)
            .map((e) => PulseSignal.fromJson(e as Map<String, Object?>))
            .toList(),
        energyCurve: (json['energy_curve'] as List)
            .map((e) => EnergyCurvePoint.fromJson(e as Map<String, Object?>))
            .toList(),
      );
}

/// A pulse rule -- condition-to-action mapping.
@immutable
class PulseRule {
  final String condition;
  final String action;
  final String description;

  const PulseRule({
    required this.condition,
    required this.action,
    required this.description,
  });

  Map<String, Object?> toJson() => {
        'condition': condition,
        'action': action,
        'description': description,
      };

  static PulseRule fromJson(Map<String, Object?> json) => PulseRule(
        condition: json['condition'] as String,
        action: json['action'] as String,
        description: json['description'] as String,
      );
}

/// Pulse configuration -- thresholds and durations.
@immutable
class PulseConfig {
  final Map<PulsePhase, int> phaseDurationsMs;
  final Map<PulseIntensity, int> intensityThresholds;
  final List<PulseRule> recoveryRules;

  const PulseConfig({
    this.phaseDurationsMs = const {},
    this.intensityThresholds = const {},
    this.recoveryRules = const [],
  });

  Map<String, Object?> toJson() => {
        'phase_durations_ms': phaseDurationsMs
            .map((k, v) => MapEntry(k.code, v)),
        'intensity_thresholds': intensityThresholds
            .map((k, v) => MapEntry(k.code, v)),
        'recovery_rules': recoveryRules.map((r) => r.toJson()).toList(),
      };

  static PulseConfig fromJson(Map<String, Object?> json) {
    final durationsRaw = json['phase_durations_ms'] as Map?;
    final thresholdsRaw = json['intensity_thresholds'] as Map?;
    final rulesRaw = json['recovery_rules'] as List? ?? const [];
    return PulseConfig(
      phaseDurationsMs: {
        for (final entry in (durationsRaw?.entries ?? <MapEntry>[]))
          PulsePhase.fromCode(entry.key as String): entry.value as int,
      },
      intensityThresholds: {
        for (final entry in (thresholdsRaw?.entries ?? <MapEntry>[]))
          PulseIntensity.fromCode(entry.key as String): entry.value as int,
      },
      recoveryRules: rulesRaw
          .map((e) => PulseRule.fromJson(e as Map<String, Object?>))
          .toList(),
    );
  }

  /// Default configuration with sensible baseline values.
  static const defaultConfig = PulseConfig();
}

/// Pulse context -- input to the evaluation engine.
@immutable
class PulseContext {
  final int energyLevel;
  final List<String> recentActivity;
  final Map<String, double> domainProgress;
  final int timeOfDayHour;
  final Map<String, Object?> userPreferences;

  const PulseContext({
    required this.energyLevel,
    this.recentActivity = const [],
    this.domainProgress = const {},
    required this.timeOfDayHour,
    this.userPreferences = const {},
  }) : assert(energyLevel >= 0 && energyLevel <= 100),
       assert(timeOfDayHour >= 0 && timeOfDayHour <= 23);
}

// ---- Prime Pulse 每日模块：能量 / 每日执行 / 打卡 ----
//
// 以下类型服务于 Prime Pulse 的“每日执行 + 能量 + 打卡”子模块。
// 纯 Dart（不依赖 `package:flutter`），可被纯 Dart 单测覆盖。
// 所有 JSON 键均为 snake_case（ADR-6）。

/// 能量档位（能量状态模型，F1/F2）。
///
/// 阈值与 [PulseEngine] 的相位判定保持一致：
/// <20 恢复中、<40 低、<70 中、其余 高。
enum EnergyBand {
  high,
  medium,
  low,
  recovering;

  /// 序列化 code（与展示语义一致的小写单词）。
  String get code => name;

  static EnergyBand fromCode(String code) => switch (code) {
        'high' => EnergyBand.high,
        'medium' => EnergyBand.medium,
        'low' => EnergyBand.low,
        'recovering' => EnergyBand.recovering,
        _ => throw ArgumentError('Unknown EnergyBand code: $code'),
      };

  /// 由 0-100 能量值推导档位。
  static EnergyBand fromLevel(int level) {
    if (level < 20) return EnergyBand.recovering;
    if (level < 40) return EnergyBand.low;
    if (level < 70) return EnergyBand.medium;
    return EnergyBand.high;
  }

  /// 语义占位标签；UI 层最终应通过 i18n 映射。
  String get label => switch (this) {
        EnergyBand.high => '充沛',
        EnergyBand.medium => '平稳',
        EnergyBand.low => '偏低',
        EnergyBand.recovering => '恢复中',
      };
}

/// 能量读数来源（F1：主观输入 + 客观数据）。
enum EnergySource {
  subjective,
  sleep,
  hrv,
  recovery;

  String get code => name;

  static EnergySource fromCode(String code) => switch (code) {
        'subjective' => EnergySource.subjective,
        'sleep' => EnergySource.sleep,
        'hrv' => EnergySource.hrv,
        'recovery' => EnergySource.recovery,
        _ => throw ArgumentError('Unknown EnergySource code: $code'),
      };
}

/// 单次能量读数（能量状态模型）。
@immutable
class EnergyLog {
  final int level;
  final EnergySource source;
  final DateTime recordedAt;
  final String? note;

  const EnergyLog({
    required this.level,
    this.source = EnergySource.subjective,
    required this.recordedAt,
    this.note,
  }) : assert(level >= 0 && level <= 100);

  Map<String, Object?> toJson() => {
        'level': level,
        'source': source.code,
        'recorded_at': recordedAt.toIso8601String(),
        'note': note,
      };

  static EnergyLog fromJson(Map<String, Object?> json) => EnergyLog(
        level: json['level'] as int,
        source: EnergySource.fromCode(json['source'] as String? ?? 'subjective'),
        recordedAt: DateTime.parse(json['recorded_at'] as String),
        note: json['note'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnergyLog &&
          other.level == level &&
          other.source == source &&
          other.recordedAt == recordedAt &&
          other.note == note;

  @override
  int get hashCode =>
      level ^ source.hashCode ^ recordedAt.hashCode ^ note.hashCode;
}

/// 执行状态（每日执行追踪，D2）。
enum ExecutionStatus {
  pending,
  inProgress,
  done;

  /// 序列化 code：Dart 标识符 camelCase，对外返回 snake_case（ADR-6）。
  String get code => switch (this) {
        pending => 'pending',
        inProgress => 'in_progress',
        done => 'done',
      };

  static ExecutionStatus fromCode(String code) => switch (code) {
        'pending' => ExecutionStatus.pending,
        'in_progress' => ExecutionStatus.inProgress,
        'done' => ExecutionStatus.done,
        _ => throw ArgumentError('Unknown ExecutionStatus code: $code'),
      };
}

/// 单次执行记录（D2：开始/完成 + 主观评分）。
@immutable
class ExecutionRecord {
  final String id;
  final String taskId;
  final String dimension;
  final int? subjectiveRating;
  final int? energyLevel;
  final ExecutionStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? note;

  const ExecutionRecord({
    required this.id,
    required this.taskId,
    required this.dimension,
    this.subjectiveRating,
    this.energyLevel,
    this.status = ExecutionStatus.done,
    required this.startedAt,
    this.completedAt,
    this.note,
  })  : assert(subjectiveRating == null ||
            (subjectiveRating >= 1 && subjectiveRating <= 5)),
        assert(energyLevel == null ||
            (energyLevel >= 0 && energyLevel <= 100));

  Map<String, Object?> toJson() => {
        'id': id,
        'task_id': taskId,
        'dimension': dimension,
        'subjective_rating': subjectiveRating,
        'energy_level': energyLevel,
        'status': status.code,
        'started_at': startedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'note': note,
      };

  static ExecutionRecord fromJson(Map<String, Object?> json) => ExecutionRecord(
        id: json['id'] as String,
        taskId: json['task_id'] as String,
        dimension: json['dimension'] as String,
        subjectiveRating: json['subjective_rating'] as int?,
        energyLevel: json['energy_level'] as int?,
        status: ExecutionStatus.fromCode(json['status'] as String? ?? 'done'),
        startedAt: DateTime.parse(json['started_at'] as String),
        completedAt: (json['completed_at'] as String?) == null
            ? null
            : DateTime.parse(json['completed_at'] as String),
        note: json['note'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExecutionRecord &&
          other.id == id &&
          other.taskId == taskId &&
          other.dimension == dimension &&
          other.subjectiveRating == subjectiveRating &&
          other.energyLevel == energyLevel &&
          other.status == status &&
          other.startedAt == startedAt &&
          other.completedAt == completedAt &&
          other.note == note;

  @override
  int get hashCode =>
      id.hashCode ^
      taskId.hashCode ^
      dimension.hashCode ^
      subjectiveRating.hashCode ^
      energyLevel.hashCode ^
      status.hashCode ^
      startedAt.hashCode ^
      completedAt.hashCode ^
      note.hashCode;
}

/// Prime Pulse 每日打卡（G：Prime Pulse 仪式）。
///
/// 注意：打卡是“今日承诺 / 能量标记”，**不是连续打卡天数**。
/// 反馈应关联目标进度（“离目标又近了一步”），而非“打卡成功”。
@immutable
class PulseCheckIn {
  final DateTime date;
  final int energyLevel;
  final String? intention;
  final DateTime createdAt;

  const PulseCheckIn({
    required this.date,
    required this.energyLevel,
    this.intention,
    required this.createdAt,
  }) : assert(energyLevel >= 0 && energyLevel <= 100);

  Map<String, Object?> toJson() => {
        'date': date.toIso8601String(),
        'energy_level': energyLevel,
        'intention': intention,
        'created_at': createdAt.toIso8601String(),
      };

  static PulseCheckIn fromJson(Map<String, Object?> json) => PulseCheckIn(
        date: DateTime.parse(json['date'] as String),
        energyLevel: json['energy_level'] as int,
        intention: json['intention'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PulseCheckIn &&
          other.date == date &&
          other.energyLevel == energyLevel &&
          other.intention == intention &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      date.hashCode ^
      energyLevel.hashCode ^
      intention.hashCode ^
      createdAt.hashCode;
}

/// 当日 Pulse 聚合状态（能量 + 执行 + 打卡）。
@immutable
class DailyPulseState {
  final DateTime date;
  final List<EnergyLog> energyLogs;
  final List<ExecutionRecord> executions;
  final PulseCheckIn? checkIn;

  const DailyPulseState({
    required this.date,
    this.energyLogs = const [],
    this.executions = const [],
    this.checkIn,
  });

  /// 以当天 00:00 为锚点的初始空状态。
  DailyPulseState.today([DateTime? now])
      : this(
          date: _midnight(now ?? DateTime.now()),
          energyLogs: const [],
          executions: const [],
          checkIn: null,
        );

  static DateTime _midnight(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  DailyPulseState copyWith({
    DateTime? date,
    List<EnergyLog>? energyLogs,
    List<ExecutionRecord>? executions,
    PulseCheckIn? checkIn,
    bool clearCheckIn = false,
  }) =>
      DailyPulseState(
        date: date ?? this.date,
        energyLogs: energyLogs ?? this.energyLogs,
        executions: executions ?? this.executions,
        checkIn: clearCheckIn ? null : (checkIn ?? this.checkIn),
      );

  Map<String, Object?> toJson() => {
        'date': date.toIso8601String(),
        'energy_logs': energyLogs.map((e) => e.toJson()).toList(),
        'executions': executions.map((e) => e.toJson()).toList(),
        'check_in': checkIn?.toJson(),
      };

  static DailyPulseState fromJson(Map<String, Object?> json) => DailyPulseState(
        date: DateTime.parse(json['date'] as String),
        energyLogs: ((json['energy_logs'] as List?) ?? const [])
            .map((e) => EnergyLog.fromJson(e as Map<String, Object?>))
            .toList(),
        executions: ((json['executions'] as List?) ?? const [])
            .map((e) => ExecutionRecord.fromJson(e as Map<String, Object?>))
            .toList(),
        checkIn: (json['check_in'] as Map<String, Object?>?) == null
            ? null
            : PulseCheckIn.fromJson(json['check_in'] as Map<String, Object?>),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyPulseState &&
          other.date == date &&
          _listEq(other.energyLogs, energyLogs) &&
          _listEq(other.executions, executions) &&
          other.checkIn == checkIn;

  @override
  int get hashCode =>
      date.hashCode ^
      _listHash(energyLogs) ^
      _listHash(executions) ^
      checkIn.hashCode;

  static bool _listEq<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static int _listHash<T>(List<T> list) =>
      list.fold(0, (h, e) => h ^ e.hashCode);
}

/// 当日火焰档位的轻量日代理（**非**目标加权火焰）。
///
/// 蓝图第七部分的目标加权火焰依赖跨维度目标进度，超出本模块范围；
/// 此处仅以“今日执行完成度 + 能量档位”给出当日活力指示，供 UI 占位。
enum PulseFireLevel {
  dim, // 微光
  ember, // 小火苗
  steady, // 稳定
  blaze; // 旺盛

  String get code => name;
}

/// 当日 Pulse 快照（UI 聚合视图模型）。
@immutable
class DailyPulseSnapshot {
  final DateTime date;
  final int? latestEnergyLevel;
  final EnergyBand? energyBand;
  final bool checkInDone;
  final int executionTotal;
  final int executionDone;
  final double completionRatio;
  final PulseFireLevel fire;

  /// 与 tone 引擎联动（observe-only）：当前生效调性的 microcopy 语气键。
  final String? toneHintKey;

  /// 与 portrait 联动（observe-only）：今日建议聚焦的活跃维度 id。
  ///
  /// 依据活跃画像维度推导，无活跃维度时为 null（绝不臆造焦点）。
  final String? focusDimension;

  /// 与 portrait 联动（observe-only）：当前活跃维度数量。
  final int activeDimensionCount;

  const DailyPulseSnapshot({
    required this.date,
    this.latestEnergyLevel,
    this.energyBand,
    required this.checkInDone,
    required this.executionTotal,
    required this.executionDone,
    required this.completionRatio,
    required this.fire,
    this.toneHintKey,
    this.focusDimension,
    this.activeDimensionCount = 0,
  });
}
