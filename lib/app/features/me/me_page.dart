import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/state/journey_state.dart';

class MePage extends ConsumerWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journey = ref.watch(journeyControllerProvider);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          Text('我的', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppTokens.space2),
          Text(
            '查看本次会话的目标边界与本机存储能力接入状态。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTokens.colorTextSecondary,
                ),
          ),
          const SizedBox(height: AppTokens.space6),
          _StatusSection(journey: journey),
          const SizedBox(height: AppTokens.space6),
          Text('本机存储能力', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppTokens.space3),
          const _InfoRow(label: '当前状态', value: '研发接入中'),
          const _InfoRow(label: '会话数据', value: '退出后不保证保留'),
          const _InfoRow(label: '持久版本', value: '尚未形成'),
          const SizedBox(height: AppTokens.space6),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppTokens.colorBgSubtle,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: const Padding(
              padding: EdgeInsets.all(AppTokens.space4),
              child: Text(
                '当前研发状态：方向、现实约束、成长域、目标与里程碑先保留在本次会话；接入存储用例后再提供本机持久版本。',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.journey});

  final JourneyState journey;

  @override
  Widget build(BuildContext context) {
    final hasDraft = journey.direction.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.colorBgSurface,
        border: Border.all(color: AppTokens.colorBorderDefault),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('目标边界版本', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space3),
            Text(
              journey.isConfirmed
                  ? '当前边界已由你明确确认，正在等待接入本机持久化。'
                  : hasDraft
                      ? '本次会话有一份方向草案，尚未确认目标边界。'
                      : '尚无目标边界草案。先从旅程写下方向。',
            ),
            const SizedBox(height: AppTokens.space3),
            Text(
              journey.isConfirmed ? '已确认，等待写入本机' : '当前仅保留在本次会话',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: journey.isConfirmed
                        ? AppTokens.colorStatusSuccess
                        : AppTokens.colorTextMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTokens.colorBorderDefault),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
