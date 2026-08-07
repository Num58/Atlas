import 'package:test/test.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';
import 'package:primeatlas/core/pulse/pulse_engine.dart';
import 'package:primeatlas/core/pulse/pulse_types.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// Prime Pulse 核心引擎单测（纯 Dart，不依赖 flutter_test）。
///
/// 覆盖：能量 / 执行 / 打卡业务规则，以及 tone / portrait 的 observe-only 联动。
/// 全部用例使用确定性输入，可稳定复跑。
void main() {
  late PulseEngine engine;
  late DailyPulseState empty;

  setUp(() {
    engine = const PulseEngine();
    empty = DailyPulseState.today(DateTime(2026, 3, 1));
  });

  group('logEnergy 业务规则', () {
    test('合法能量值追加到日志并返回成功', () {
      final res = engine.logEnergy(empty, 72);
      expect(res.isSuccess, isTrue);
      final s = res.valueOrNull!;
      expect(s.energyLogs.length, 1);
      expect(s.energyLogs.first.level, 72);
      expect(s.energyLogs.first.source, EnergySource.subjective);
    });

    test('能量越界（<0 或 >100）返回 energy_out_of_range 失败', () {
      expect(
        engine.logEnergy(empty, -1).failureOrNull?.code,
        'energy_out_of_range',
      );
      expect(
        engine.logEnergy(empty, 101).failureOrNull?.code,
        'energy_out_of_range',
      );
    });

    test('多次标记累加日志，不替换', () {
      final s1 = engine.logEnergy(empty, 40).valueOrNull!;
      final s2 = engine.logEnergy(s1, 55).valueOrNull!;
      expect(s2.energyLogs.length, 2);
    });
  });

  group('recordExecution 业务规则', () {
    test('合法执行记录追加并返回成功', () {
      final res = engine.recordExecution(
        empty,
        taskId: 't1',
        dimension: '体能',
        subjectiveRating: 4,
        energyLevel: 60,
      );
      expect(res.isSuccess, isTrue);
      final rec = res.valueOrNull!.executions.first;
      expect(rec.taskId, 't1');
      expect(rec.status, ExecutionStatus.done);
      expect(rec.subjectiveRating, 4);
    });

    test('主观评分越界（<1 或 >5）返回 execution_invalid_rating', () {
      expect(
        engine
            .recordExecution(empty, taskId: 't', dimension: 'd',
                subjectiveRating: 0)
            .failureOrNull
            ?.code,
        'execution_invalid_rating',
      );
      expect(
        engine
            .recordExecution(empty, taskId: 't', dimension: 'd',
                subjectiveRating: 6)
            .failureOrNull
            ?.code,
        'execution_invalid_rating',
      );
    });

    test('执行能量越界返回 execution_invalid_energy', () {
      expect(
        engine
            .recordExecution(empty, taskId: 't', dimension: 'd',
                energyLevel: 200)
            .failureOrNull
            ?.code,
        'execution_invalid_energy',
      );
    });
  });

  group('checkIn 业务规则', () {
    test('首次打卡成功写入 checkIn', () {
      final res = engine.checkIn(empty, energyLevel: 65);
      expect(res.isSuccess, isTrue);
      expect(res.valueOrNull!.checkIn, isNotNull);
      expect(res.valueOrNull!.checkIn!.energyLevel, 65);
    });

    test('已打卡再次打卡返回 already_checked_in（不产生连续天数）', () {
      final once = engine.checkIn(empty, energyLevel: 65).valueOrNull!;
      final twice = engine.checkIn(once, energyLevel: 70);
      expect(twice.isFailure, isTrue);
      expect(twice.failureOrNull?.code, 'already_checked_in');
    });

    test('打卡能量越界返回 energy_out_of_range', () {
      expect(
        engine.checkIn(empty, energyLevel: 999).failureOrNull?.code,
        'energy_out_of_range',
      );
    });
  });

  group('summarize 聚合', () {
    test('无数据时完成度 0、火焰 dim', () {
      final snap = engine.summarize(empty);
      expect(snap.executionTotal, 0);
      expect(snap.executionDone, 0);
      expect(snap.completionRatio, 0.0);
      expect(snap.fire, PulseFireLevel.dim);
      expect(snap.checkInDone, isFalse);
    });

    test('全部完成但无能量日志 → 火焰 blaze（band 缺失视为不低）', () {
      var s = engine.recordExecution(empty,
          taskId: 'a', dimension: '体能', energyLevel: 70).valueOrNull!;
      s = engine.recordExecution(s,
          taskId: 'b', dimension: '语言', energyLevel: 70).valueOrNull!;
      final snap = engine.summarize(s);
      expect(snap.completionRatio, 1.0);
      expect(snap.fire, PulseFireLevel.blaze);
    });

    test('低能量（恢复中）下高完成度 → 火焰不旺盛（ember）', () {
      final withEnergy = engine.logEnergy(empty, 25).valueOrNull!;
      final s = engine.recordExecution(withEnergy,
          taskId: 'a', dimension: '体能', energyLevel: 25).valueOrNull!;
      final snap = engine.summarize(s);
      expect(snap.completionRatio, 1.0);
      expect(snap.fire, PulseFireLevel.ember);
    });

    test('能量平稳 + 部分完成（2/3）→ 火焰 steady', () {
      final withEnergy = engine.logEnergy(empty, 70).valueOrNull!;
      var s = engine.recordExecution(withEnergy,
          taskId: 'a', dimension: '体能').valueOrNull!;
      s = engine.recordExecution(s,
          taskId: 'b', dimension: '语言').valueOrNull!;
      final pending = ExecutionRecord(
        id: 'p1',
        taskId: 'c',
        dimension: '认知',
        status: ExecutionStatus.pending,
        startedAt: DateTime(2026),
      );
      s = s.copyWith(executions: [...s.executions, pending]);
      final snap = engine.summarize(s);
      expect(snap.executionTotal, 3);
      expect(snap.executionDone, 2);
      expect(snap.fire, PulseFireLevel.steady);
    });

    test('能量档位与最新读数一致（medium）', () {
      final s = engine.logEnergy(empty, 55).valueOrNull!;
      final snap = engine.summarize(s);
      expect(snap.latestEnergyLevel, 55);
      expect(snap.energyBand, EnergyBand.medium);
    });
  });

  group('tone 联动（observe-only）', () {
    test('四种调性各返回对应的 microcopy 语气键', () {
      expect(engine.toneHint(ToneId.professional), 'pulse.tone.professional');
      expect(engine.toneHint(ToneId.warm), 'pulse.tone.warm');
      expect(engine.toneHint(ToneId.encouraging), 'pulse.tone.encouraging');
      expect(engine.toneHint(ToneId.strict), 'pulse.tone.strict');
    });

    test('snapshot 携带 toneHintKey 但不修改调性状态', () {
      final s = engine.logEnergy(empty, 80).valueOrNull!;
      final snap = engine.summarize(s, activeTone: ToneId.encouraging);
      expect(snap.toneHintKey, 'pulse.tone.encouraging');
    });
  });

  group('portrait 联动（observe-only，按 activeAxes）', () {
    final axes = [
      const PortraitAxis(id: 'endurance', label: '耐力', active: true),
      const PortraitAxis(id: 'social', label: '社交', active: true),
      const PortraitAxis(id: 'hidden', label: '隐藏', active: false),
    ];

    test('activeDimensions 仅返回激活维度 id', () {
      expect(
        engine.activeDimensions(axes),
        containsAll(['endurance', 'social']),
      );
      expect(engine.activeDimensions(axes).contains('hidden'), isFalse);
    });

    test('suggestFocusDimension 取首个活跃维度，无活跃时返回 null', () {
      expect(engine.suggestFocusDimension(axes), 'endurance');
      expect(
        engine.suggestFocusDimension([
          const PortraitAxis(id: 'x', label: 'X', active: false),
        ]),
        isNull,
      );
    });

    test('snapshot 携带 focusDimension 与 activeDimensionCount', () {
      final snap = engine.summarize(empty, activeAxes: axes);
      expect(snap.focusDimension, 'endurance');
      expect(snap.activeDimensionCount, 2);
    });

    test('无活跃维度时 snapshot.focusDimension 为 null', () {
      final snap = engine.summarize(empty, activeAxes: const [
        PortraitAxis(id: 'x', label: 'X', active: false),
      ]);
      expect(snap.focusDimension, isNull);
      expect(snap.activeDimensionCount, 0);
    });
  });

  group('Enum.code 规则（snake_case）', () {
    test('ExecutionStatus.inProgress.code 返回 in_progress', () {
      expect(ExecutionStatus.inProgress.code, 'in_progress');
      expect(ExecutionStatus.fromCode('in_progress'), ExecutionStatus.inProgress);
    });

    test('EnergyBand / PulsePhase / ToneId 的 code 均为 snake_case', () {
      expect(EnergyBand.recovering.code, 'recovering');
      expect(PulsePhase.peaking.code, 'peaking');
      expect(ToneId.encouraging.code, 'encouraging');
    });
  });
}
