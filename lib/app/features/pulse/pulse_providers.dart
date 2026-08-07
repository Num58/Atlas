import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/core/common/result.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';
import 'package:primeatlas/core/pulse/pulse_engine.dart';
import 'package:primeatlas/core/pulse/pulse_types.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// Prime Pulse 每日状态（能量 + 执行 + 打卡），内存态，不落库。
///
/// 持久化是明确的后续工作；当前所有变更委托 [PulseEngine]，保证业务规则
/// （能量范围、打卡去重、执行评分校验）只存在于核心层。
///
/// 形态镜像 `lib/app/features/journey/v2/conflict_providers.dart` 的
/// [StateNotifier] 模式：状态由引擎产出，notifier 仅做委托与换状态。
final pulseProvider =
    StateNotifierProvider<PulseNotifier, DailyPulseState>((ref) {
  return PulseNotifier(ref);
});

/// 当前生效调性（observe-only 联动源）。
///
/// 默认 professional；上层（如 me/tone 设置）可在用户确认后写入，
/// 供 [PulseNotifier] 生成语气提示。本模块只读取，绝不修改调性状态。
final pulseToneProvider = StateProvider<ToneId>((ref) => ToneId.professional);

/// 当前活跃画像维度（observe-only 联动源）。
///
/// 默认空；上层（如 portrait 快照）写入活跃维度后，[PulseNotifier]
/// 据此推导今日聚焦维度。本模块只读取，绝不定义或贴身份标签。
final pulseActiveAxesProvider =
    StateProvider<List<PortraitAxis>>((ref) => const []);

class PulseNotifier extends StateNotifier<DailyPulseState> {
  PulseNotifier(this._ref) : super(DailyPulseState.today());

  final Ref _ref;
  final PulseEngine _engine = const PulseEngine();

  /// 记录能量读数。返回底层 [Result]，便于 UI 读取失败原因。
  Result<DailyPulseState> logEnergy(
    int level, {
    EnergySource source = EnergySource.subjective,
    String? note,
  }) {
    final res = _engine.logEnergy(
      state,
      level,
      source: source,
      note: note,
    );
    if (res.isSuccess) state = res.valueOrNull!;
    return res;
  }

  /// 记录一条执行完成。返回底层 [Result]，便于 UI 读取失败原因。
  Result<DailyPulseState> recordExecution({
    required String taskId,
    required String dimension,
    int? subjectiveRating,
    int? energyLevel,
    String? note,
  }) {
    final res = _engine.recordExecution(
      state,
      taskId: taskId,
      dimension: dimension,
      subjectiveRating: subjectiveRating,
      energyLevel: energyLevel,
      note: note,
    );
    if (res.isSuccess) state = res.valueOrNull!;
    return res;
  }

  /// Prime Pulse 每日打卡。返回底层 [Result]，便于 UI 读取失败原因。
  Result<DailyPulseState> checkIn({
    required int energyLevel,
    String? intention,
  }) {
    final res = _engine.checkIn(
      state,
      energyLevel: energyLevel,
      intention: intention,
    );
    if (res.isSuccess) state = res.valueOrNull!;
    return res;
  }

  /// 当前聚合快照（UI 视图模型），叠加 tone / portrait 联动信息。
  ///
  /// 通过 `_ref.read` 取当前调性与活跃维度（observe-only）；面板已
  /// `ref.watch` 这两个 provider 以保证联动变更时重建。
  DailyPulseSnapshot get snapshot {
    final tone = _ref.read(pulseToneProvider);
    final axes = _ref.read(pulseActiveAxesProvider);
    return _engine.summarize(state, activeTone: tone, activeAxes: axes);
  }
}
