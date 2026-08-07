import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/features/journey/v2/conflict_providers.dart';
import 'package:primeatlas/core/conflict/conflict_types.dart';

/// 活跃冲突横幅列表。无冲突时返回空组件。
class ConflictBannerList extends ConsumerWidget {
  const ConflictBannerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflicts = ref.watch(conflictProvider);
    if (conflicts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final conflict in conflicts)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ConflictBanner(conflict: conflict),
          ),
      ],
    );
  }
}

/// 单条冲突横幅（双轨裁决：采纳建议 / 我自己来）。
///
/// 约束：无 emoji 图标、无紫→粉渐变、无 AI 模板套话。
/// 身体安全通道使用实色警示边框与纯文字安全提示，区别于普通冲突。
class ConflictBanner extends ConsumerWidget {
  const ConflictBanner({super.key, required this.conflict});

  final Conflict conflict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(conflictProvider.notifier);
    final theme = Theme.of(context);
    final isBody = conflict.bodySafety;

    // 纯色背景与边框，不使用渐变。
    final backgroundColor =
        isBody ? const Color(0xFFFBE9E7) : const Color(0xFFF1F1F1);
    final borderColor =
        isBody ? const Color(0xFFB3261E) : const Color(0xFF757575);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBody)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFB3261E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '身体安全提示：涉及身体负荷，请优先评估恢复状态后再决定',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(conflict.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            conflict.tradeoffSummary,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => notifier.resolve(conflict, true),
                child: const Text('采纳建议'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => notifier.resolve(conflict, false),
                child: const Text('我自己来'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
