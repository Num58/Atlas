import 'package:test/test.dart';
import 'package:primeatlas/core/conflict/conflict_engine.dart';
import 'package:primeatlas/core/conflict/conflict_types.dart';

void main() {
  final engine = const ConflictEngine();

  group('ConflictEngine.detect', () {
    test('时间重叠产生 scheduleOverlap 冲突', () {
      final items = [
        ScheduledItem(
          id: 'a',
          start: DateTime(2025, 1, 1, 9),
          end: DateTime(2025, 1, 1, 10),
          plannedEnergy: 10,
          isTraining: false,
          recoveryLevel: 50,
        ),
        ScheduledItem(
          id: 'b',
          start: DateTime(2025, 1, 1, 9, 30),
          end: DateTime(2025, 1, 1, 11),
          plannedEnergy: 10,
          isTraining: false,
          recoveryLevel: 50,
        ),
      ];
      final conflicts = engine.detect(items);
      final overlap =
          conflicts.where((c) => c.kind == ConflictKind.scheduleOverlap);
      expect(overlap, isNotEmpty);
      expect(overlap.first.involvedItemIds, containsAll(<String>['a', 'b']));
      expect(overlap.first.bodySafety, isFalse);
      expect(overlap.first.severity, ConflictSeverity.caution);
    });

    test('当日精力超出预算产生 energyBudget 冲突（caution）', () {
      final items = <ScheduledItem>[
        for (var i = 0; i < 3; i++)
          ScheduledItem(
            id: 'e$i',
            start: DateTime(2025, 1, 1, i),
            end: DateTime(2025, 1, 1, i + 1),
            plannedEnergy: 40,
            isTraining: false,
            recoveryLevel: 50,
          ),
      ];
      final conflicts = engine.detect(items);
      final budget =
          conflicts.where((c) => c.kind == ConflictKind.energyBudget);
      expect(budget, isNotEmpty);
      expect(budget.first.severity, ConflictSeverity.caution);
      expect(budget.first.bodySafety, isFalse);
    });

    test('高负荷训练 + 低恢复产生 bodySafety=true 警告', () {
      final items = [
        ScheduledItem(
          id: 't',
          start: DateTime(2025, 1, 1, 8),
          end: DateTime(2025, 1, 1, 9),
          plannedEnergy: 80,
          isTraining: true,
          recoveryLevel: 10,
        ),
      ];
      final conflicts = engine.detect(items);
      final rec = conflicts
          .where((c) => c.kind == ConflictKind.trainingLoadVsRecovery);
      expect(rec, isNotEmpty);
      expect(rec.first.bodySafety, isTrue);
      expect(rec.first.severity, ConflictSeverity.warning);
    });

    test('无重叠、未超预算、恢复充足时无冲突', () {
      final items = [
        ScheduledItem(
          id: 'a',
          start: DateTime(2025, 1, 1, 9),
          end: DateTime(2025, 1, 1, 10),
          plannedEnergy: 10,
          isTraining: false,
          recoveryLevel: 50,
        ),
        ScheduledItem(
          id: 'b',
          start: DateTime(2025, 1, 1, 11),
          end: DateTime(2025, 1, 1, 12),
          plannedEnergy: 10,
          isTraining: false,
          recoveryLevel: 50,
        ),
      ];
      expect(engine.detect(items), isEmpty);
    });
  });

  group('ConflictEngine.propose (双轨裁决)', () {
    final conflict = const Conflict(
      id: 'c1',
      kind: ConflictKind.scheduleOverlap,
      involvedItemIds: const <String>['a', 'b'],
      description: 'desc',
      tradeoffSummary: '采纳建议摘要',
      bodySafety: false,
      severity: ConflictSeverity.caution,
    );

    test('采纳建议 → adopt，note 为 tradeoffSummary', () {
      final r = engine.propose(conflict, userAdopt: true);
      expect(r.verdict, ConflictVerdict.adopt);
      expect(r.note, conflict.tradeoffSummary);
      expect(r.blockedUser, isFalse);
    });

    test('自行处理 → selfManaged，note 固定文案', () {
      final r = engine.propose(conflict, userAdopt: false);
      expect(r.verdict, ConflictVerdict.selfManaged);
      expect(r.note, '用户选择自行处理');
      expect(r.blockedUser, isFalse);
    });

    test('不变量：所有裁决 blockedUser 恒为 false (C-RL1)', () {
      final resolutions = <ConflictResolution>[
        engine.propose(conflict, userAdopt: true),
        engine.propose(conflict, userAdopt: false),
      ];
      for (final r in resolutions) {
        expect(r.blockedUser, isFalse, reason: 'C-RL1: 不得硬阻断用户');
        expect(engine.enforcesNoHardBlock(r), isTrue);
      }
    });
  });
}
