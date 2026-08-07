import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/journey/v2/journey_providers.dart';
import 'package:primeatlas/app/features/journey/v2/journey_strings.dart';
import 'package:primeatlas/app/state/app_providers.dart';
import 'package:primeatlas/core/ports/goal_repository.dart';

class GoalDetailPage extends ConsumerWidget {
  const GoalDetailPage({required this.goalId, super.key});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(goalDetailProvider(goalId));
    final actions = ref.watch(goalActionsProvider);

    ref.listen<GoalActionState>(goalActionsProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.details['message'] as String? ?? '操作未完成'),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('目标详情')),
      floatingActionButton: actions.busy
          ? const CircularProgressIndicator()
          : null,
      body: detailAsync.when(
        loading: () => const _DetailSkeleton(),
        error: (error, _) {
          return _ErrorState(
            message: '目标加载失败',
            onRetry: () => ref.invalidate(goalDetailProvider(goalId)),
          );
        },
        data: (detail) => _DetailContent(detail: detail),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.detail});

  final GoalDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = detail.goal;
    final ownerId = ref.watch(ownerIdProvider);
    final actions = ref.read(goalActionsProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tablet = constraints.maxWidth > 600;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(goal: goal, ownerId: ownerId),
            const SizedBox(height: AppTokens.space4),
            Text('里程碑', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space2),
            if (detail.milestones.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppTokens.space3),
                child: Text('尚未设置里程碑。'),
              )
            else
              ...detail.milestones.map((m) => _MilestoneTile(milestone: m)),
            const SizedBox(height: AppTokens.space6),
            _Actions(
              status: goal.status,
              onConfirm: () => actions.confirm(goal.id),
              onPause: () => actions.pause(goal.id),
              onArchive: () => actions.archive(goal.id),
            ),
          ],
        );
        if (tablet) {
          return ListView(
            padding: const EdgeInsets.all(AppTokens.space4),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: content,
                ),
              ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [content],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.goal, required this.ownerId});

  final Goal goal;
  final String ownerId;

  @override
  Widget build(BuildContext context) {
    final target = goal.targetAtUs;
    final targetText = target == null
        ? '未设置目标日期'
        : '目标日期 ${DateTime.fromMicrosecondsSinceEpoch(target).toLocal().toString().split(' ').first}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Chip(
                  label: Text(goalStatusLabel(goal.status)),
                  backgroundColor: AppTokens.colorActionPrimarySubtle,
                  labelStyle: TextStyle(color: AppTokens.colorActionPrimary),
                ),
              ],
            ),
            if (goal.description != null && goal.description!.isNotEmpty) ...[
              const SizedBox(height: AppTokens.space2),
              Text(goal.description!, style: Theme.of(context).textTheme.bodyLarge),
            ],
            const SizedBox(height: AppTokens.space2),
            Text(
              '成长域 ${goal.domainId} · $targetText',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({required this.milestone});

  final Milestone milestone;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.space2),
      child: ListTile(
        leading: Icon(
          milestone.status == 'achieved'
              ? Icons.check_circle_outline
              : Icons.radio_button_unchecked,
          color: milestone.status == 'achieved'
              ? AppTokens.colorStatusSuccess
              : AppTokens.colorTextMuted,
        ),
        title: Text(milestone.title),
        subtitle: Text(milestoneStatusLabel(milestone.status)),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.status,
    required this.onConfirm,
    required this.onPause,
    required this.onArchive,
  });

  final String status;
  final VoidCallback onConfirm;
  final VoidCallback onPause;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final canConfirm = status == 'draft';
    final canPause = status == 'active';
    final canArchive = status != 'archived';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canConfirm)
          FilledButton(
            onPressed: onConfirm,
            child: const Text('确认目标'),
          ),
        if (canPause) ...[
          const SizedBox(height: AppTokens.space2),
          OutlinedButton(
            onPressed: onPause,
            child: const Text('暂停目标'),
          ),
        ],
        if (canArchive) ...[
          const SizedBox(height: AppTokens.space2),
          OutlinedButton(
            onPressed: onArchive,
            child: const Text('归档目标'),
          ),
        ],
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppTokens.colorBgSubtle,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        ...List.generate(
          3,
          (_) => Container(
            height: 56,
            margin: const EdgeInsets.only(bottom: AppTokens.space2),
            decoration: BoxDecoration(
              color: AppTokens.colorBgSubtle,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: AppTokens.space4),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space4),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
