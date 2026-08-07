import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/design_system/app_icon.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/journey/v2/journey_providers.dart';
import 'package:primeatlas/app/features/journey/v2/journey_strings.dart';
import 'package:primeatlas/core/ports/goal_repository.dart';

class GoalOverviewPage extends ConsumerStatefulWidget {
  const GoalOverviewPage({super.key});

  @override
  ConsumerState<GoalOverviewPage> createState() => _GoalOverviewPageState();
}

class _GoalOverviewPageState extends ConsumerState<GoalOverviewPage> {
  final List<GoalSummary> _accumulated = [];
  JourneyOverviewCursor? _nextCursor;
  JourneyOverviewArgs _args = const JourneyOverviewArgs();
  bool _refreshing = false;

  void _merge(JourneyOverviewResult result) {
    for (final goal in result.goals) {
      if (!_accumulated.any((x) => x.id == goal.id)) {
        _accumulated.add(goal);
      }
    }
    _nextCursor = result.nextCursor;
  }

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _accumulated.clear();
      _nextCursor = null;
      _args = const JourneyOverviewArgs();
    });
    ref.invalidate(journeyOverviewProvider(_args));
    setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(journeyOverviewProvider(_args));

    return Scaffold(
      appBar: AppBar(title: const Text('目标')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/journey/goals/new'),
        icon: const AppIcon(
          icon: AppIconKey.target,
          semanticLabel: '新建目标',
          size: 20,
        ),
        label: const Text('新建目标'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: overviewAsync.when(
          loading: () =>
              _refreshing || _accumulated.isEmpty ? const _GoalSkeleton() : _body(),
          error: (error, _) => _accumulated.isEmpty
              ? _ErrorState(
                  message: '目标加载失败',
                  onRetry: () => ref.invalidate(journeyOverviewProvider(_args)),
                )
              : _body(),
          data: (result) {
            _merge(result);
            return _body();
          },
        ),
      ),
    );
  }

  Widget _body() {
    if (_accumulated.isEmpty) {
      return const _GoalEmpty();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final tablet = constraints.maxWidth > 600;
        final list = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._accumulated.map((g) => _GoalCard(goal: g)),
            if (_nextCursor != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTokens.space4),
                child: Center(
                  child: FilledButton.tonal(
                    onPressed: () =>
                        setState(() => _args = JourneyOverviewArgs(cursor: _nextCursor)),
                    child: const Text('加载更多'),
                  ),
                ),
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
                  child: list,
                ),
              ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [list],
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final GoalSummary goal;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.space3),
      child: ListTile(
        title: Text(goal.title),
        subtitle: Text(
          '${goalStatusLabel(goal.status)} · ${goal.domainId}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/journey/goals/${goal.id}'),
      ),
    );
  }
}

class _GoalEmpty extends StatelessWidget {
  const _GoalEmpty();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
          child: Column(
            children: [
              const Icon(Icons.flag_outlined, size: 48),
              const SizedBox(height: AppTokens.space4),
              Text(
                '还没有目标',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space2),
              Text(
                '创建第一个成长目标，把它收束到一个明确的成长域上。',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalSkeleton extends StatelessWidget {
  const _GoalSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: List.generate(
        4,
        (_) => Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: AppTokens.space3),
          decoration: BoxDecoration(
            color: AppTokens.colorBgSubtle,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
        ),
      ),
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
