import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/design_system/app_icon.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/state/journey_state.dart';

class JourneyPage extends ConsumerWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journeyControllerProvider);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          Text('旅程', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppTokens.space2),
          Text(
            '把想提升的方向连接到现实约束、目标与里程碑。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTokens.colorTextSecondary,
                ),
          ),
          const SizedBox(height: AppTokens.space6),
          if (state.direction.isEmpty)
            _EmptyJourney(onStart: () => context.push('/journey/direction'))
          else ...[
            _BoundarySummary(state: state),
            const SizedBox(height: AppTokens.space4),
            _JourneyStep(
              label: '成长域',
              value: state.domain.isEmpty ? '待选择' : state.domain,
              actionLabel: state.domain.isEmpty ? '选择成长域' : '修改',
              onPressed: () => context.push('/journey/domain'),
            ),
            _JourneyStep(
              label: '目标',
              value: state.goal.isEmpty ? '待编辑' : state.goal,
              actionLabel: state.goal.isEmpty ? '编辑目标' : '修改',
              onPressed: () => context.push('/journey/goal'),
            ),
            _JourneyStep(
              label: '里程碑',
              value: state.milestone?.title ?? '待确认',
              actionLabel: state.milestone == null ? '设置里程碑' : '修改',
              onPressed: () => context.push('/journey/milestone'),
            ),
            const SizedBox(height: AppTokens.space4),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _canConfirm(state)
                    ? () {
                        ref
                            .read(journeyControllerProvider.notifier)
                            .confirmBoundary();
                      }
                    : null,
                child: Text(state.isConfirmed ? '目标边界已确认' : '确认目标边界'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _canConfirm(JourneyState state) {
    return !state.isConfirmed &&
        state.domain.isNotEmpty &&
        state.goal.isNotEmpty &&
        state.milestone != null;
  }
}

class _EmptyJourney extends StatelessWidget {
  const _EmptyJourney({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '尚未创建目标方向',
      child: DecoratedBox(
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
              const AppIcon(
                icon: AppIconKey.target,
                semanticLabel: '目标方向',
                color: AppTokens.colorActionPrimary,
              ),
              const SizedBox(height: AppTokens.space4),
              Text('先写下你想改善的方向',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppTokens.space2),
              const Text('你可以同时写下可用时间、场景与现实限制；先在本次会话整理，接入本机存储后再形成持久版本。'),
              const SizedBox(height: AppTokens.space5),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: onStart,
                  child: const Text('开始整理方向'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoundarySummary extends StatelessWidget {
  const _BoundarySummary({required this.state});

  final JourneyState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.colorActionPrimarySubtle,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('目标方向',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: () => context.push('/journey/direction'),
                  child: const Text('编辑'),
                ),
              ],
            ),
            Text(state.direction),
            const SizedBox(height: AppTokens.space3),
            Text(
              '现实约束：${state.constraint}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTokens.space3),
            Text(
              state.isConfirmed ? '目标边界已确认，等待写入本机' : '草案仅保留在本次会话',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTokens.colorStatusSuccess,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.label,
    required this.value,
    required this.actionLabel,
    required this.onPressed,
  });

  final String label;
  final String value;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTokens.colorBorderDefault),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppTokens.space1),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          TextButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
