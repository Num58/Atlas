import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/core/agents/agent_orchestrator.dart';
import 'package:primeatlas/core/common/domain_failure.dart';
import 'package:primeatlas/core/conflict/conflict_engine.dart';
import 'package:primeatlas/core/decision/decision_orchestrator.dart';
import 'package:primeatlas/core/decision/decision_types.dart';
import 'package:primeatlas/core/fusion/fusion_engine.dart';
import 'package:primeatlas/core/safety/safety_engine.dart';
import 'package:primeatlas/core/tone/tone_engine.dart';

/// 决策组合层提供者（内存态，无新增 DB 表）。
///
/// 暴露最近一次决策结果 [DecisionState]；`run` 调用 [DecisionOrchestrator]
/// 并保存成功结果或失败码（safety_blocked / data_insufficient /
/// conflict_unresolved）。
final decisionProvider =
    StateNotifierProvider<DecisionNotifier, DecisionState>((ref) {
  return DecisionNotifier(DecisionOrchestrator(
    safetyEngine: const SafetyEngine(),
    conflictEngine: const ConflictEngine(),
    fusionEngine: const FusionEngine(),
    agentOrchestrator: AgentOrchestrator(),
    toneEngine: ToneEngine(),
  ));
});

/// 决策状态：成功携带 [DecisionOutcome]，失败携带失败码与详情。
class DecisionState {
  final DecisionOutcome? outcome;
  final bool isFailure;
  final String? failureCode;
  final List<String> failureDetails;
  final DateTime? decidedAt;

  const DecisionState({
    this.outcome,
    this.isFailure = false,
    this.failureCode,
    this.failureDetails = const [],
    this.decidedAt,
  });

  static const DecisionState initial = DecisionState();
}

/// 决策状态持有者：运行组合决策并维护最近结果。
class DecisionNotifier extends StateNotifier<DecisionState> {
  DecisionNotifier(this._orchestrator) : super(const DecisionState());

  final DecisionOrchestrator _orchestrator;

  /// 运行一次决策组合，结果写入状态。
  void run(ProposedAction action, DecisionContext ctx) {
    final result = _orchestrator.runDecision(action, ctx);
    if (result.isSuccess) {
      final outcome = result.valueOrNull!;
      state = DecisionState(
        outcome: outcome,
        isFailure: false,
        decidedAt: outcome.decidedAt,
      );
    } else {
      final failure = result.failureOrNull!;
      state = DecisionState(
        outcome: null,
        isFailure: true,
        failureCode: failure.code,
        failureDetails: _extractDetails(failure),
        decidedAt: ctx.now,
      );
    }
  }

  /// 从失败详情中抽取可读条目（安全告警 / 替代路径）。
  List<String> _extractDetails(DomainFailure failure) {
    final details = failure.details;
    final out = <String>[];
    final warnings = details['warnings'];
    if (warnings is List) {
      for (final w in warnings) {
        if (w is String && w.isNotEmpty) out.add(w);
      }
    }
    final alternatives = details['alternative_paths'];
    if (alternatives is List) {
      for (final a in alternatives) {
        if (a is String && a.isNotEmpty) out.add('替代路径：$a');
      }
    }
    return out;
  }
}
