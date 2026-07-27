import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/journey/journey_editor_shared.dart';
import 'package:primeatlas/app/state/journey_state.dart';

class DomainPage extends ConsumerWidget {
  const DomainPage({super.key});

  static const domains = ['体能', '语言', '创作', '认知'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journeyControllerProvider);
    final selected = state.domains;
    return JourneyEditorScaffold(
      title: '选择成长域',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '最多保留三个活跃成长域。再次点按可取消；选择第 4 个域只给聚焦建议，不会写入。',
          ),
          const SizedBox(height: AppTokens.space3),
          Text(
            selected.isEmpty
                ? '当前未选择成长域'
                : '已选择 ${selected.length}/3：${selected.join(' · ')}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTokens.colorTextSecondary,
                ),
          ),
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
          ...domains.map(
            (domain) {
              final isSelected = selected.contains(domain);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.space2),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: isSelected
                        ? AppTokens.colorActionPrimarySubtle
                        : null,
                    side: BorderSide(
                      color: isSelected
                          ? AppTokens.colorActionPrimary
                          : AppTokens.colorBorderDefault,
                    ),
                  ),
                  onPressed: () {
                    final result = ref
                        .read(journeyControllerProvider.notifier)
                        .selectDomain(domain);
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
                    child: Text(isSelected ? '$domain（已选）' : domain),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppTokens.space4),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: selected.isEmpty
                  ? null
                  : () {
                      context.pop();
                    },
              child: const Text('完成选择'),
            ),
          ),
        ],
      ),
    );
  }
}

