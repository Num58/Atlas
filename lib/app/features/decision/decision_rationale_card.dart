import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/core/agents/agent_types.dart' hide ProposedAction;
import 'package:primeatlas/core/decision/decision_types.dart';
import 'package:primeatlas/core/tone/tone_types.dart';
import 'decision_providers.dart';
import 'fusion_evidence_chain.dart';

/// 决策依据卡片：展示最近一次决策的总结、安全状态、建议调性与证据链。
///
/// 移动端优先；无 emoji 图标、无紫粉渐变；文案为事实陈述——
/// 成功时如实说明依据，失败时如实说明未自动批准的原因并提示用户保留自主权。
class DecisionRationaleCard extends ConsumerWidget {
  const DecisionRationaleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(decisionProvider);
    if (state.decidedAt == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: state.isFailure
            ? _FailureView(code: state.failureCode, details: state.failureDetails)
            : _SuccessView(outcome: state.outcome!),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final DecisionOutcome outcome;

  const _SuccessView({required this.outcome});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approved = outcome.status == DecisionStatus.approved;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: approved
                    ? const Color(0xFF1F8F7A)
                    : const Color(0xFFB26A1F),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                approved ? '可通过' : '可谨慎通过',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '安全：${_safetyLabel(outcome.safetyStatus)}',
              style: theme.textTheme.bodySmall,
            ),
            const Spacer(),
            Text(
              '调性：${ToneProfile.byId(outcome.recommendedTone).label}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(outcome.summary, style: theme.textTheme.bodyMedium),
        if (outcome.safetyAlternatives.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '替代路径：${outcome.safetyAlternatives.join('；')}',
            style: theme.textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        FusionEvidenceChain(items: outcome.evidenceChain),
      ],
    );
  }

  String _safetyLabel(SafetyStatus s) => switch (s) {
        SafetyStatus.clear => '无冲突',
        SafetyStatus.advisory => '有提醒',
        SafetyStatus.blockedNonUser => '已劝阻',
      };
}

class _FailureView extends StatelessWidget {
  final String? code;
  final List<String> details;

  const _FailureView({required this.code, required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = switch (code) {
      'safety_blocked' => '系统出于安全考虑未自动批准本次决策。',
      'data_insufficient' => '当前证据不足以形成决策。',
      'conflict_unresolved' => '检测到尚未仲裁的日程冲突。',
      _ => '本次决策未通过自动评估。',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 6),
        Text(
          code == 'safety_blocked'
              ? '你可自行评估风险后决定是否执行，系统不会阻止你的目标。'
              : '处理上述事项后再次运行即可得到决策依据。',
          style: theme.textTheme.bodySmall,
        ),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final d in details)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('· $d', style: theme.textTheme.bodySmall),
            ),
        ],
      ],
    );
  }
}
