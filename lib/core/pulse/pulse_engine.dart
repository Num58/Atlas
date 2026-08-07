import 'package:meta/meta.dart';
import 'package:primeatlas/core/common/domain_failure.dart';
import 'package:primeatlas/core/common/result.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';
import 'package:primeatlas/core/pulse/pulse_types.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// Prime Pulse Engine.
///
/// Evaluates energy cycles and generates advisory pulse signals.
///
/// **Key principle**: Pulse is advisory only. It does NOT unlock or block
/// training. It suggests engagement levels based on the user's current
/// energy state and recent activity patterns.
@immutable
class PulseEngine {
  final PulseConfig config;

  const PulseEngine({this.config = PulseConfig.defaultConfig});

  /// Evaluates current pulse state from the given context.
  ///
  /// Determines the phase based on energy level, recent activity, and
  /// time of day. The phase transitions follow:
  /// dormant -> awakening -> active -> peaking -> recovering -> dormant.
  PulseState evaluate(PulseContext ctx) {
    final phase = _determinePhase(ctx);
    final now = ctx.timeOfDayHour;

    // Build energy curve point
    final curvePoint = EnergyCurvePoint(
      timestampUs: now,
      energyLevel: ctx.energyLevel,
    );

    return PulseState(
      currentPhase: phase,
      phaseStartedAtUs: now,
      energyCurve: [curvePoint],
    );
  }

  /// Generates the next pulse signal for the given state.
  ///
  /// Returns null if no signal is warranted (e.g., stable active phase
  /// with moderate energy).
  PulseSignal? generateSignal(PulseState state) {
    final phase = state.currentPhase;
    final energy = state.energyCurve.isNotEmpty
        ? state.energyCurve.last.energyLevel
        : 50;

    final intensity = _intensityForPhase(phase, energy);
    final (messageKey, domainFocus) = _signalForPhase(phase, energy);

    if (messageKey == null) return null;

    return PulseSignal(
      phase: phase,
      intensity: intensity,
      energyLevel: energy,
      domainFocus: domainFocus,
      messageKey: messageKey,
      occurredAtUs: state.phaseStartedAtUs,
    );
  }

  /// Transitions the pulse state based on a new signal.
  ///
  /// Implements the state machine: dormant -> awakening -> active ->
  /// peaking -> recovering -> dormant.
  PulseState transition(PulseState current, PulseSignal signal) {
    final nextPhase = _nextPhase(current.currentPhase, signal);
    final updatedSignals = [...current.signalsToday, signal];

    return current.copyWith(
      currentPhase: nextPhase,
      phaseStartedAtUs: signal.occurredAtUs,
      signalsToday: updatedSignals,
      energyCurve: [
        ...current.energyCurve,
        EnergyCurvePoint(
          timestampUs: signal.occurredAtUs,
          energyLevel: signal.energyLevel,
        ),
      ],
    );
  }

  // ---- Prime Pulse 每日模块：能量 / 执行 / 打卡 ----

  /// 记录一次能量读数（能量状态模型）。
  ///
  /// 失败码：
  /// - `energy_out_of_range`：level 不在 0-100。
  ///
  /// 成功时把 [EnergyLog] 追加到当日状态并返回新状态。
  Result<DailyPulseState> logEnergy(
    DailyPulseState s,
    int level, {
    EnergySource source = EnergySource.subjective,
    DateTime? when,
    String? note,
  }) {
    if (level < 0 || level > 100) {
      return Failure(
        DomainFailure(
          code: 'energy_out_of_range',
          retryable: false,
          messageKey: 'pulse.energy_out_of_range',
          details: {'level': level},
        ),
      );
    }
    final log = EnergyLog(
      level: level,
      source: source,
      recordedAt: when ?? DateTime.now(),
      note: note,
    );
    return Success(s.copyWith(energyLogs: [...s.energyLogs, log]));
  }

  /// 记录一条执行完成（每日执行追踪，D2）。
  ///
  /// 失败码：
  /// - `execution_invalid_rating`：subjectiveRating 不在 1-5；
  /// - `execution_invalid_energy`：energyLevel 不在 0-100。
  ///
  /// 成功时把 [ExecutionRecord] 追加到当日状态并返回新状态。
  Result<DailyPulseState> recordExecution(
    DailyPulseState s, {
    required String taskId,
    required String dimension,
    int? subjectiveRating,
    int? energyLevel,
    DateTime? startedAt,
    DateTime? completedAt,
    String? note,
  }) {
    if (subjectiveRating != null &&
        (subjectiveRating < 1 || subjectiveRating > 5)) {
      return Failure(
        DomainFailure(
          code: 'execution_invalid_rating',
          retryable: false,
          messageKey: 'pulse.execution_invalid_rating',
          details: {'subjectiveRating': subjectiveRating},
        ),
      );
    }
    if (energyLevel != null && (energyLevel < 0 || energyLevel > 100)) {
      return Failure(
        DomainFailure(
          code: 'execution_invalid_energy',
          retryable: false,
          messageKey: 'pulse.execution_invalid_energy',
          details: {'energyLevel': energyLevel},
        ),
      );
    }
    final record = ExecutionRecord(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      taskId: taskId,
      dimension: dimension,
      subjectiveRating: subjectiveRating,
      energyLevel: energyLevel,
      status: ExecutionStatus.done,
      startedAt: startedAt ?? DateTime.now(),
      completedAt: completedAt ?? DateTime.now(),
      note: note,
    );
    return Success(s.copyWith(executions: [...s.executions, record]));
  }

  /// Prime Pulse 每日打卡（G 仪式）。
  ///
  /// 失败码：
  /// - `already_checked_in`：当日已打卡（不鼓励重复，也不产生连续天数）；
  /// - `energy_out_of_range`：energyLevel 不在 0-100。
  ///
  /// 成功时把 [PulseCheckIn] 写入当日状态；反馈语义应关联目标进度，
  /// 而非“打卡成功”。
  Result<DailyPulseState> checkIn(
    DailyPulseState s, {
    required int energyLevel,
    String? intention,
    DateTime? when,
  }) {
    if (s.checkIn != null) {
      return Failure(
        DomainFailure(
          code: 'already_checked_in',
          retryable: false,
          messageKey: 'pulse.already_checked_in',
          details: {'date': s.date.toIso8601String()},
        ),
      );
    }
    if (energyLevel < 0 || energyLevel > 100) {
      return Failure(
        DomainFailure(
          code: 'energy_out_of_range',
          retryable: false,
          messageKey: 'pulse.energy_out_of_range',
          details: {'energyLevel': energyLevel},
        ),
      );
    }
    final checkIn = PulseCheckIn(
      date: s.date,
      energyLevel: energyLevel,
      intention: intention,
      createdAt: when ?? DateTime.now(),
    );
    return Success(s.copyWith(checkIn: checkIn));
  }

  PulseFireLevel _dailyFire(double completionRatio, EnergyBand? band) {
    // 轻量日代理：完成度高 + 能量不低 ⇒ 旺盛；停滞 / 低能量 ⇒ 微光。
    final energyOk = band == null ||
        band == EnergyBand.high ||
        band == EnergyBand.medium;
    if (completionRatio >= 0.9 && energyOk) return PulseFireLevel.blaze;
    if (completionRatio >= 0.6 && energyOk) return PulseFireLevel.steady;
    if (completionRatio > 0.0) return PulseFireLevel.ember;
    return PulseFireLevel.dim;
  }

  // ---- 与 tone / portrait 联动（observe-only，绝不触碰身份） ----

  /// 与 tone 引擎联动（observe-only）：依据当前生效调性给出 microcopy 语气键。
  ///
  /// 仅读取 [ToneId]，绝不修改调性状态；返回 i18n 键，由 UI 层映射文案。
  /// 四种调性对应四种语气，体现“同一事实、不同说法”的设计意图。
  String toneHint(ToneId activeTone) => switch (activeTone) {
        ToneId.professional => 'pulse.tone.professional',
        ToneId.warm => 'pulse.tone.warm',
        ToneId.encouraging => 'pulse.tone.encouraging',
        ToneId.strict => 'pulse.tone.strict',
      };

  /// 与 portrait 联动（observe-only）：按 activeAxes 取活跃维度 id 列表。
  ///
  /// 仅读取 [PortraitAxis.active]，用于“今日聚焦”建议；绝不定义或贴身份标签。
  List<String> activeDimensions(List<PortraitAxis> axes) =>
      axes.where((a) => a.active).map((a) => a.id).toList();

  /// 由活跃画像维度推导今日建议聚焦维度（observe-only）。
  ///
  /// 规则（确定性）：
  /// - 无活跃维度 → null（不臆造焦点）；
  /// - 能量恢复中（[EnergyBand.recovering]）→ 取首个活跃维度，并倾向低负荷提示；
  /// - 其余 → 取首个活跃维度。
  ///
  /// 返回维度 id；如需展示文案，UI 层应回查 [PortraitAxis.label]。
  String? suggestFocusDimension(
    List<PortraitAxis> axes, {
    EnergyBand? band,
  }) {
    final active = axes.where((a) => a.active).toList();
    if (active.isEmpty) return null;
    // 恢复中优先提示“先做一件轻量小事”，焦点维度仍是首个活跃维度，
    // 由 UI 结合 band 决定措辞，引擎只负责确定性选取。
    return active.first.id;
  }

  /// 汇总当日快照（UI 视图模型），并叠加 tone / portrait 联动信息。
  ///
  /// [activeTone] 与 [activeAxes] 均为 observe-only 输入：引擎据此给出
  /// 语气提示与聚焦维度，不修改二者任何状态，也不对用户做身份判定。
  DailyPulseSnapshot summarize(
    DailyPulseState s, {
    ToneId? activeTone,
    List<PortraitAxis> activeAxes = const [],
  }) {
    final latest = s.energyLogs.isEmpty ? null : s.energyLogs.last.level;
    final band = latest == null ? null : EnergyBand.fromLevel(latest);
    final done = s.executions
        .where((e) => e.status == ExecutionStatus.done)
        .length;
    final total = s.executions.length;
    final ratio = total == 0 ? 0.0 : done / total;
    final focus = suggestFocusDimension(activeAxes, band: band);
    final toneKey = activeTone == null ? null : toneHint(activeTone);
    final activeDimCount = activeDimensions(activeAxes).length;
    return DailyPulseSnapshot(
      date: s.date,
      latestEnergyLevel: latest,
      energyBand: band,
      checkInDone: s.checkIn != null,
      executionTotal: total,
      executionDone: done,
      completionRatio: ratio,
      fire: _dailyFire(ratio, band),
      toneHintKey: toneKey,
      focusDimension: focus,
      activeDimensionCount: activeDimCount,
    );
  }

  // ---- Private helpers ----

  PulsePhase _determinePhase(PulseContext ctx) {
    final energy = ctx.energyLevel;
    final recentCount = ctx.recentActivity.length;

    // Recovery takes priority when energy is very low
    if (energy < 20) {
      return recentCount > 0 ? PulsePhase.recovering : PulsePhase.dormant;
    }

    if (energy < 40) return PulsePhase.awakening;
    if (energy < 70) return PulsePhase.active;
    if (energy < 85) return PulsePhase.peaking;

    // Very high energy -- peaking, but recovery needed soon
    return PulsePhase.peaking;
  }

  PulseIntensity _intensityForPhase(PulsePhase phase, int energy) {
    return switch (phase) {
      PulsePhase.dormant => PulseIntensity.minimal,
      PulsePhase.recovering => PulseIntensity.low,
      PulsePhase.awakening =>
        energy < 30 ? PulseIntensity.low : PulseIntensity.moderate,
      PulsePhase.active => PulseIntensity.moderate,
      PulsePhase.peaking =>
        energy > 85 ? PulseIntensity.maximum : PulseIntensity.high,
    };
  }

  (String?, String?) _signalForPhase(PulsePhase phase, int energy) {
    return switch (phase) {
      PulsePhase.dormant => (
          'pulse.dormant.gentle_start',
          null,
        ),
      PulsePhase.awakening => (
          'pulse.awakening.build_momentum',
          null,
        ),
      PulsePhase.active when energy > 60 => (
          'pulse.active.sustain',
          null,
        ),
      PulsePhase.active => (null, null), // stable, no signal needed
      PulsePhase.peaking when energy > 85 => (
          'pulse.peaking.push_window',
          null,
        ),
      PulsePhase.peaking => (
          'pulse.peaking.maintain',
          null,
        ),
      PulsePhase.recovering => (
          'pulse.recovering.rest',
          null,
        ),
    };
  }

  PulsePhase _nextPhase(PulsePhase current, PulseSignal signal) {
    // State machine transitions based on energy level in signal
    final energy = signal.energyLevel;

    return switch (current) {
      PulsePhase.dormant when energy >= 20 => PulsePhase.awakening,
      PulsePhase.dormant => PulsePhase.dormant,
      PulsePhase.awakening when energy >= 40 => PulsePhase.active,
      PulsePhase.awakening when energy < 20 => PulsePhase.dormant,
      PulsePhase.awakening => PulsePhase.awakening,
      PulsePhase.active when energy >= 70 => PulsePhase.peaking,
      PulsePhase.active when energy < 40 => PulsePhase.recovering,
      PulsePhase.active => PulsePhase.active,
      PulsePhase.peaking when energy < 70 => PulsePhase.recovering,
      PulsePhase.peaking => PulsePhase.peaking,
      PulsePhase.recovering when energy >= 40 => PulsePhase.active,
      PulsePhase.recovering when energy < 20 => PulsePhase.dormant,
      PulsePhase.recovering => PulsePhase.recovering,
    };
  }
}
