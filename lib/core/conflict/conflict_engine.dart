import 'package:meta/meta.dart';
import 'package:primeatlas/core/conflict/conflict_types.dart';

/// 冲突检测器抽象契约（C1-1）。
abstract class ConflictDetector {
  /// 检测一次冲突并返回结果。
  ConflictDetectionResult detect(ConflictDetectionRequest req);
}

/// S0 基础冲突检测器。
///
/// 契约保证：
/// - **C-RL1**：结果 `disposition.blockedUser` 恒为 `false`（非阻断）。
/// - **C-RL3**：若 `isBodyRelated == true`，必须携带非空的
///   `bodyReasonTraceableId`，否则直接抛错（fail loudly），保证身体冲突可追溯。
class BasicConflictDetector implements ConflictDetector {
  const BasicConflictDetector();

  @override
  ConflictDetectionResult detect(ConflictDetectionRequest req) {
    if (req.isBodyRelated &&
        (req.bodyReasonTraceableId == null ||
            req.bodyReasonTraceableId!.isEmpty)) {
      throw ArgumentError(
          'C-RL3 violation: body-related conflict (${req.conflictId}) '
          'requires non-empty body_reason_traceable_id');
    }

    const disposition = Disposition(blockedUser: false);

    return ConflictDetectionResult(
      conflictId: req.conflictId,
      conflictType: req.conflictType,
      isBodyRelated: req.isBodyRelated,
      bodyReason: req.bodyReason,
      bodyReasonTraceableId: req.bodyReasonTraceableId,
      disposition: disposition,
      recommendedOrchestration: req.recommendedOrchestration,
    );
  }
}

/// ===========================================================================
/// C1-1 冲突检测引擎（纯 Dart，无 flutter 依赖）。
/// ===========================================================================

/// 每日精力预算上限（energyBudget 阈值）。
const int dailyEnergyBudget = 100;

/// 低恢复水平阈值（trainingLoadVsRecovery）。
const int lowRecoveryThreshold = 30;

/// 高训练负荷阈值（trainingLoadVsRecovery 中视为「高 plannedEnergy」）。
const int highTrainingLoad = 50;

/// 冲突检测引擎。
///
/// 权衡非禁止：所有检测与提议均为纯函数，且任何裁决结果
/// `blockedUser` 恒为 `false`（C-RL1，绝不硬阻断用户）。
@immutable
class ConflictEngine {
  const ConflictEngine();

  /// 检测给定日程项集合中的冲突。
  List<Conflict> detect(Iterable<ScheduledItem> items) {
    final list = items.toList();
    final conflicts = <Conflict>[];

    // 1) scheduleOverlap：时间区间重叠。
    for (var i = 0; i < list.length; i++) {
      for (var j = i + 1; j < list.length; j++) {
        if (list[i].overlaps(list[j])) {
          conflicts.add(Conflict(
            id: 'overlap:${list[i].id}:${list[j].id}',
            kind: ConflictKind.scheduleOverlap,
            involvedItemIds: [list[i].id, list[j].id],
            description:
                '「${list[i].id}」与「${list[j].id}」时间重叠，需选择其一或调整时段。',
            tradeoffSummary:
                '采纳建议：将其中一项顺延；自行处理：保留两者并接受时间冲突。',
            bodySafety: false,
            severity: ConflictSeverity.caution,
          ));
        }
      }
    }

    // 2) energyBudget：当日计划精力之和超出预算。
    final totalEnergy = list.fold<int>(0, (s, e) => s + e.plannedEnergy);
    if (totalEnergy > dailyEnergyBudget) {
      conflicts.add(Conflict(
        id: 'energy:$totalEnergy',
        kind: ConflictKind.energyBudget,
        involvedItemIds: list.map((e) => e.id).toList(growable: false),
        description: '当日计划精力 $totalEnergy 超出预算 $dailyEnergyBudget。',
        tradeoffSummary:
            '采纳建议：削减低优先项；自行处理：自行承担超负荷风险。',
        bodySafety: false,
        severity: ConflictSeverity.caution,
      ));
    }

    // 3) trainingLoadVsRecovery：高负荷训练叠加低恢复（身体安全通道）。
    final hasLowRecovery =
        list.any((e) => e.recoveryLevel < lowRecoveryThreshold);
    if (hasLowRecovery) {
      for (final item in list.where(
        (e) => e.isTraining && e.plannedEnergy >= highTrainingLoad,
      )) {
        conflicts.add(Conflict(
          id: 'trainRec:${item.id}',
          kind: ConflictKind.trainingLoadVsRecovery,
          involvedItemIds: [item.id],
          description:
              '训练项「${item.id}」负荷较高，但当前恢复水平偏低，存在身体风险。',
          tradeoffSummary:
              '采纳建议：降低强度或增加恢复；自行处理：评估身体状态后自行决定。',
          bodySafety: true,
          severity: ConflictSeverity.warning,
        ));
      }
    }

    return conflicts;
  }

  /// 双轨裁决：生成裁决结果。
  ///
  /// `userAdopt == true` → 采纳建议；否则用户自行处理。
  /// 两种情况下 `blockedUser` 均为 `false`（C-RL1）。
  ConflictResolution propose(Conflict c, {required bool userAdopt}) {
    if (userAdopt) {
      return ConflictResolution(
        conflictId: c.id,
        verdict: ConflictVerdict.adopt,
        note: c.tradeoffSummary,
        blockedUser: false,
      );
    }
    return ConflictResolution(
      conflictId: c.id,
      verdict: ConflictVerdict.selfManaged,
      note: '用户选择自行处理',
      blockedUser: false,
    );
  }

  /// 不变量校验：任何裁决都不得硬阻断用户。
  bool enforcesNoHardBlock(ConflictResolution r) => r.blockedUser == false;
}
