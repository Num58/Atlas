/// FAD 决策组合层 —— 编排器（组合消费 Route C 三引擎 + safety + fusion + agents）。
///
/// 纯 Dart，无 `package:flutter` 依赖。
///
/// **组合顺序（优先级从高到低）**：
/// 1. 数据充分性（data_insufficient）
/// 2. Safety 否决（safety_blocked，但 C-RL1 不阻断用户目标）
/// 3. Conflict 未决（conflict_unresolved，C-RL1 不硬阻断）
/// 4. 通过 → Fusion 证据 + Agents 多Agent评估 + Tone 选取 → 产出 [DecisionOutcome]
///
/// 身份红线：本编排器只读 `PortraitSnapshot.activeAxes` 作为融合证据源，
/// 不创建、不贴任何身份标签。
library;

import 'package:primeatlas/core/agents/agent_orchestrator.dart';
import 'package:primeatlas/core/agents/agent_types.dart' as agent;
import 'package:primeatlas/core/common/result.dart';
import 'package:primeatlas/core/conflict/conflict_engine.dart';
import 'package:primeatlas/core/fusion/fusion_engine.dart';
import 'package:primeatlas/core/fusion/fusion_types.dart';
import 'package:primeatlas/core/safety/safety_engine.dart';
import 'package:primeatlas/core/safety/safety_types.dart' hide ProposedAction;
import 'package:primeatlas/core/safety/safety_types.dart' as safety;
import 'package:primeatlas/core/tone/tone_engine.dart';
import 'package:primeatlas/core/tone/tone_types.dart';
import 'decision_types.dart';

/// 决策组合编排器。
///
/// 构造时注入五个引擎实例（均为无副作用的纯计算单元）：
/// [SafetyEngine]、[ConflictEngine]、[FusionEngine]、[AgentOrchestrator]、[ToneEngine]。
class DecisionOrchestrator {
  final SafetyEngine _safetyEngine;
  final ConflictEngine _conflictEngine;
  final FusionEngine _fusionEngine;
  final AgentOrchestrator _agentOrchestrator;
  final ToneEngine _toneEngine;

  const DecisionOrchestrator({
    required SafetyEngine safetyEngine,
    required ConflictEngine conflictEngine,
    required FusionEngine fusionEngine,
    required AgentOrchestrator agentOrchestrator,
    required ToneEngine toneEngine,
  })  : _safetyEngine = safetyEngine,
        _conflictEngine = conflictEngine,
        _fusionEngine = fusionEngine,
        _agentOrchestrator = agentOrchestrator,
        _toneEngine = toneEngine;

  /// 运行一次决策组合。
  ///
  /// 返回 [Result<DecisionOutcome>]：成功分支携带完整决策依据；失败分支携带
  /// [DecisionFailures] 中的一种失败码（safety_blocked / data_insufficient /
  /// conflict_unresolved）。
  Result<DecisionOutcome> runDecision(
    ProposedAction action,
    DecisionContext ctx,
  ) {
    // 1) 数据充分性：缺少形成决策所需的证据源则不能决定。
    if (ctx.activeDomains.isEmpty || ctx.portrait.activeAxes.isEmpty) {
      return const Failure<DecisionOutcome>(DecisionFailures.dataInsufficient);
    }

    // 2) Safety（最高优先级，类否决权）。
    final safetyEvaluation = _safetyEngine.evaluate(
      ctx.safetyContext,
      safety.ProposedAction(
        actionType: action.actionType,
        domain: action.domain,
        intensity: action.intensity,
        durationMin: action.durationMin,
        scheduledAtUs: action.scheduledAtUs,
      ),
    );
    if (safetyEvaluation.maxSeverity == Severity.block) {
      // C-RL1：失败闭合但不阻断用户目标——详情中始终携带 blocked_user:false
      // 与替代路径，用户保留执行自主权。
      return Failure<DecisionOutcome>(DecisionFailures.safetyBlocked(
        warnings: safetyEvaluation.warnings,
        alternatives: safetyEvaluation.alternativePaths,
      ));
    }

    // 3) Conflict（C-RL1 不硬阻断，但自动化决策暂不予批准直至仲裁）。
    final conflicts = _conflictEngine.detect(ctx.scheduledItems);
    if (conflicts.isNotEmpty) {
      return Failure<DecisionOutcome>(DecisionFailures.conflictUnresolved(
        conflictIds: conflicts.map((c) => c.id).toList(),
      ));
    }

    // 4) Fusion：跨域融合证据（只读 activeAxes 作为证据源）。
    final fusionOpportunities = _fusionEngine.discover(
      ctx.portrait,
      ctx.activeDomains,
    );

    // 5) Agents：多 Agent 评估 + 冲突裁决。
    final agentContext = agent.AgentContext(
      ownerId: ctx.ownerId,
      currentState: const {},
      recentDecisions: const [],
      userPreferences: const {},
    );
    final agentDecisions = _agentOrchestrator.evaluateAction(
      agentContext,
      agent.ProposedAction(
        actionType: action.actionType,
        description: action.description,
        parameters: action.parameters,
      ),
    );
    final agentResolution = _agentOrchestrator.resolveConflict(agentDecisions);

    // 6) Tone：依据融合机会的 toneHint 选取调性，须经 ToneEngine 解锁校验。
    final hint =
        fusionOpportunities.isNotEmpty ? fusionOpportunities.first.toneHint : null;
    final recommendedTone = (hint != null && _toneEngine.canUnlock(ctx.currentToneState, hint))
        ? hint
        : ctx.currentToneState.activeTone;

    // 7) 汇总证据链 + 产出。
    final status = safetyEvaluation.warnings.isNotEmpty
        ? DecisionStatus.caution
        : DecisionStatus.approved;

    final evidenceChain = _buildEvidenceChain(
      safetyEvaluation: safetyEvaluation,
      fusionOpportunities: fusionOpportunities,
      agentResolution: agentResolution,
      recommendedTone: recommendedTone,
    );

    final summary = _buildSummary(
      status: status,
      safetyStatus: _mapSafety(safetyEvaluation),
      fusionCount: fusionOpportunities.length,
      recommendedTone: recommendedTone,
    );

    return Success<DecisionOutcome>(DecisionOutcome(
      status: status,
      summary: summary,
      safetyStatus: _mapSafety(safetyEvaluation),
      safetyWarnings: safetyEvaluation.warnings,
      safetyAlternatives: safetyEvaluation.alternativePaths,
      fusionOpportunities: fusionOpportunities,
      agentDecisions: agentDecisions,
      agentResolution: agentResolution,
      recommendedTone: recommendedTone,
      evidenceChain: evidenceChain,
      decidedAt: ctx.now,
    ));
  }

  List<DecisionEvidenceItem> _buildEvidenceChain({
    required SafetyEvaluation safetyEvaluation,
    required List<FusionOpportunity> fusionOpportunities,
    required agent.AgentDecision? agentResolution,
    required ToneId recommendedTone,
  }) {
    final items = <DecisionEvidenceItem>[];

    // 安全依据（即便无告警也给出“已评估”信号，保持透明）。
    items.add(DecisionEvidenceItem(
      source: DecisionEvidenceSource.safety,
      label: safetyEvaluation.warnings.isEmpty
          ? '安全评估：无冲突项'
          : '安全评估：存在提醒',
      detail: safetyEvaluation.warnings.isEmpty
          ? '已对照健康与安全规则评估，未发现需劝阻的风险。'
          : safetyEvaluation.warnings.join('；'),
    ));

    // 融合证据（每条机会一项）。
    for (final opp in fusionOpportunities) {
      items.add(DecisionEvidenceItem(
        source: DecisionEvidenceSource.fusion,
        label:
            '融合机会：${opp.domainsInvolved.join(' + ')}（${opp.connectionType.code}）',
        detail: opp.description,
      ));
    }

    // 多 Agent 裁决依据。
    if (agentResolution != null) {
      items.add(DecisionEvidenceItem(
        source: DecisionEvidenceSource.agents,
        label: '多 Agent 裁决：${agentResolution.recommendation}',
        detail: agentResolution.reasoning,
      ));
    }

    // 调性依据。
    items.add(DecisionEvidenceItem(
      source: DecisionEvidenceSource.tone,
      label: '建议调性：${ToneProfile.byId(recommendedTone).label}',
      detail: ToneProfile.byId(recommendedTone).description,
    ));

    return items;
  }

  String _buildSummary({
    required DecisionStatus status,
    required agent.SafetyStatus safetyStatus,
    required int fusionCount,
    required ToneId recommendedTone,
  }) {
    final buffer = StringBuffer();
    buffer.write(status == DecisionStatus.approved ? '可通过' : '可谨慎通过');
    if (safetyStatus == agent.SafetyStatus.advisory) {
      buffer.write('；安全层有提醒，已附带替代路径');
    }
    if (fusionCount > 0) {
      buffer.write('；发现 $fusionCount 条跨域融合机会');
    }
    buffer.write(
        '；建议以「${ToneProfile.byId(recommendedTone).label}」调性呈现。');
    return buffer.toString();
  }

  agent.SafetyStatus _mapSafety(SafetyEvaluation e) {
    if (e.maxSeverity == Severity.block) return agent.SafetyStatus.blockedNonUser;
    if (e.warnings.isNotEmpty) return agent.SafetyStatus.advisory;
    return agent.SafetyStatus.clear;
  }
}
