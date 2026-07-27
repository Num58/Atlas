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
    final isSaving = state.saveStatus == LocalSaveStatus.saving;
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
              value: state.domains.isEmpty ? '待选择' : state.domainsLabel,
              actionLabel: state.domains.isEmpty ? '选择成长域' : '修改',
              onPressed:
                  isSaving ? null : () => context.push('/journey/domain'),
            ),
            _JourneyStep(
              label: '目标',
              value: state.goal.isEmpty ? '待编辑' : state.goal,
              actionLabel: state.goal.isEmpty ? '编辑目标' : '修改',
              onPressed: isSaving ? null : () => context.push('/journey/goal'),
            ),
            _JourneyStep(
              label: '里程碑',
              value: state.milestone?.title ?? '待确认',
              actionLabel: state.milestone == null ? '设置里程碑' : '修改',
              onPressed:
                  isSaving ? null : () => context.push('/journey/milestone'),
            ),
            const SizedBox(height: AppTokens.space4),
            if (state.saveStatus == LocalSaveStatus.failed) ...[
              Text(
                state.saveError ?? '写入本机失败，请重试',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTokens.colorStatusDanger,
                    ),
              ),
              const SizedBox(height: AppTokens.space3),
            ],
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
                child: Text(_confirmLabel(state)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _canConfirm(JourneyState state) {
    final complete = state.domains.isNotEmpty &&
        state.goal.isNotEmpty &&
        state.milestone != null &&
        state.direction.isNotEmpty &&
        state.constraint.isNotEmpty;
    if (!complete) {
      return false;
    }
    if (state.saveStatus == LocalSaveStatus.saving ||
        state.saveStatus == LocalSaveStatus.persisted) {
      return false;
    }
    return true;
  }

  String _confirmLabel(JourneyState state) {
    switch (state.saveStatus) {
      case LocalSaveStatus.saving:
        return '正在写入本机…';
      case LocalSaveStatus.persisted:
        return '目标边界已写入本机';
      case LocalSaveStatus.failed:
        return '重试写入本机';
      case LocalSaveStatus.pendingPersistence:
        return '确认目标边界';
    }
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
              const Text(
                '你可以同时写下可用时间、场景与现实限制。确认目标边界后才会尝试写入本机。',
              ),
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
                  onPressed: state.saveStatus == LocalSaveStatus.saving
                      ? null
                      : () => context.push('/journey/direction'),
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
              _statusLabel(state),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _statusColor(state),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(JourneyState state) {
    switch (state.saveStatus) {
      case LocalSaveStatus.pendingPersistence:
        return '草案尚未写入本机';
      case LocalSaveStatus.saving:
        return '等待写入本机';
      case LocalSaveStatus.persisted:
        return '目标边界已写入本机';
      case LocalSaveStatus.failed:
        return '写入本机失败，可重试';
    }
  }

  Color _statusColor(JourneyState state) {
    switch (state.saveStatus) {
      case LocalSaveStatus.persisted:
        return AppTokens.colorStatusSuccess;
      case LocalSaveStatus.failed:
        return AppTokens.colorStatusDanger;
      case LocalSaveStatus.saving:
        return AppTokens.colorActionPrimary;
      case LocalSaveStatus.pendingPersistence:
        return AppTokens.colorTextMuted;
    }
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
  final VoidCallback? onPressed;

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
