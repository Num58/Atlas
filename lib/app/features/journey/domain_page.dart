import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/journey/journey_editor_shared.dart';
import 'package:primeatlas/app/state/journey_state.dart';

class DomainPage extends ConsumerWidget {
  const DomainPage({super.key});

  static const catalog = ['体能', '语言', '创作', '认知'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journeyControllerProvider);
    final active = state.domains;
    final paused = state.pausedDomains;
    final controller = ref.read(journeyControllerProvider.notifier);

    return JourneyEditorScaffold(
      title: '选择成长域',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '最多 3 个活跃成长域。可点按切换活跃；对已活跃域可暂停，对已暂停域可恢复。第 4 个活跃域只给聚焦建议。',
          ),
          const SizedBox(height: AppTokens.space3),
          Text(
            active.isEmpty
                ? '当前无活跃成长域'
                : '活跃 ${active.length}/3：${active.join(' · ')}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTokens.colorTextSecondary,
                ),
          ),
          if (paused.isNotEmpty) ...[
            const SizedBox(height: AppTokens.space2),
            Text(
              '已暂停：${paused.join(' · ')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTokens.colorTextSecondary,
                  ),
            ),
          ],
          if (state.domainFocusSuggestion != null) ...[
            const SizedBox(height: AppTokens.space3),
            Text(
              state.domainFocusSuggestion!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTokens.colorStatusDanger,
                  ),
            ),
          ],
          const SizedBox(height: AppTokens.space4),
          ...catalog.map((domain) {
            final isActive = active.contains(domain);
            final isPaused = paused.contains(domain);
            final label = isActive
                ? '$domain（活跃）'
                : isPaused
                    ? '$domain（已暂停）'
                    : domain;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: isActive
                          ? AppTokens.colorActionPrimarySubtle
                          : null,
                      side: BorderSide(
                        color: isActive
                            ? AppTokens.colorActionPrimary
                            : AppTokens.colorBorderDefault,
                      ),
                    ),
                    onPressed: () {
                      final result = isPaused
                          ? controller.resumeDomain(domain)
                          : controller.selectDomain(domain);
                      if (!result.accepted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.focusSuggestion ?? '请先聚焦现有成长域',
                            ),
                          ),
                        );
                      }
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(label),
                    ),
                  ),
                  if (isActive)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          final result = controller.pauseDomain(domain);
                          if (!result.accepted && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.focusSuggestion ?? '无法暂停',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('暂停该域'),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppTokens.space3),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: active.isEmpty ? null : () => context.pop(),
              child: const Text('完成选择'),
            ),
          ),
        ],
      ),
    );
  }
}
