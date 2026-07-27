import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/journey/journey_editor_shared.dart';
import 'package:primeatlas/app/state/journey_state.dart';

class GoalListPage extends ConsumerWidget {
  const GoalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journeyControllerProvider);
    final goals = state.goals
        .where((item) => item.status != GoalDraftStatus.archived)
        .toList(growable: false);

    return JourneyEditorScaffold(
      title: '目标列表',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('域内可维护多个目标。详情页是唯一正式编辑真源；列表只负责浏览与进入。'),
          const SizedBox(height: AppTokens.space4),
          if (goals.isEmpty)
            const Text('还没有目标。先新建一个，再进入详情完善。')
          else
            ...goals.map((goal) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppTokens.space2),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTokens.colorBorderDefault),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: ListTile(
                  title: Text(goal.title),
                  subtitle: Text(_statusLabel(goal.status)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/journey/goals/${goal.id}'),
                ),
              );
            }),
          const SizedBox(height: AppTokens.space4),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => context.push('/journey/goals/new'),
              child: const Text('新建目标'),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(GoalDraftStatus status) {
    switch (status) {
      case GoalDraftStatus.draft:
        return '草案';
      case GoalDraftStatus.active:
        return '已激活';
      case GoalDraftStatus.paused:
        return '已暂停';
      case GoalDraftStatus.archived:
        return '已归档';
    }
  }
}

class GoalCreatePage extends ConsumerStatefulWidget {
  const GoalCreatePage({super.key});

  @override
  ConsumerState<GoalCreatePage> createState() => _GoalCreatePageState();
}

class _GoalCreatePageState extends ConsumerState<GoalCreatePage> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JourneyEditorScaffold(
      title: '新建目标',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('目标来源于你的原话。数据不足时先保留探索态，不显示伪精确数值。'),
          const SizedBox(height: AppTokens.space4),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '目标描述',
              hintText: '写下可验证的目标方向',
            ),
          ),
          const SizedBox(height: AppTokens.space5),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  showJourneyEditorError(context, '请填写目标描述。');
                  return;
                }
                ref.read(journeyControllerProvider.notifier).addGoal(
                      controller.text,
                    );
                context.pop();
              },
              child: const Text('创建目标草案'),
            ),
          ),
        ],
      ),
    );
  }
}

class GoalDetailPage extends ConsumerStatefulWidget {
  const GoalDetailPage({super.key, required this.goalId});

  final String goalId;

  @override
  ConsumerState<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends ConsumerState<GoalDetailPage> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final goal = ref.read(journeyControllerProvider).goalById(widget.goalId);
    controller = TextEditingController(text: goal?.title ?? '');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(journeyControllerProvider).goalById(widget.goalId);
    if (goal == null) {
      return JourneyEditorScaffold(
        title: '目标详情',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('找不到该目标，可能已被归档或不存在。'),
            const SizedBox(height: AppTokens.space4),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.go('/journey/goals'),
                child: const Text('返回目标列表'),
              ),
            ),
          ],
        ),
      );
    }

    return JourneyEditorScaffold(
      title: '目标详情',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('状态：${_statusLabel(goal.status)}'),
          const SizedBox(height: AppTokens.space3),
          const Text('详情页是唯一正式编辑真源。保存后仍需在旅程页确认边界才会写入本机。'),
          const SizedBox(height: AppTokens.space4),
          TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: '目标描述',
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  showJourneyEditorError(context, '请填写目标描述。');
                  return;
                }
                ref.read(journeyControllerProvider.notifier).updateGoal(
                      widget.goalId,
                      controller.text,
                    );
                context.pop();
              },
              child: const Text('保存目标'),
            ),
          ),
          const SizedBox(height: AppTokens.space2),
          if (goal.status != GoalDraftStatus.paused)
            TextButton(
              onPressed: () {
                ref.read(journeyControllerProvider.notifier).setGoalStatus(
                      widget.goalId,
                      GoalDraftStatus.paused,
                    );
              },
              child: const Text('暂停目标'),
            ),
          if (goal.status == GoalDraftStatus.paused)
            TextButton(
              onPressed: () {
                ref.read(journeyControllerProvider.notifier).setGoalStatus(
                      widget.goalId,
                      GoalDraftStatus.draft,
                    );
              },
              child: const Text('恢复为草案'),
            ),
          TextButton(
            onPressed: () {
              ref.read(journeyControllerProvider.notifier).setGoalStatus(
                    widget.goalId,
                    GoalDraftStatus.archived,
                  );
              context.go('/journey/goals');
            },
            child: const Text('归档目标'),
          ),
        ],
      ),
    );
  }

  String _statusLabel(GoalDraftStatus status) {
    switch (status) {
      case GoalDraftStatus.draft:
        return '草案';
      case GoalDraftStatus.active:
        return '已激活';
      case GoalDraftStatus.paused:
        return '已暂停';
      case GoalDraftStatus.archived:
        return '已归档';
    }
  }
}

/// Compatibility route used by `/journey/goal`.
class GoalPage extends ConsumerWidget {
  const GoalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(journeyControllerProvider).goals;
    if (goals.isEmpty) {
      return const GoalCreatePage();
    }
    return GoalDetailPage(goalId: goals.first.id);
  }
}
