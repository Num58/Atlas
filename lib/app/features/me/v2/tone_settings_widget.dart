import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/core/common/domain_failure.dart';
import 'package:primeatlas/core/tone/tone_types.dart';
import 'package:primeatlas/app/features/me/v2/tone_providers.dart';

/// 调性设置面板（T2-1）。
///
/// 以可选 chip 展示四种语义调性；未解锁的调性显示“未解锁”且不可点按。
/// 切换委托 [toneStateProvider]，引擎返回失败时以 SnackBar 说明理由。
/// 仅使用语义 token（label / description / accentToken），不直接着色。
class ToneSettingsWidget extends ConsumerWidget {
  const ToneSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(toneStateProvider);
    final notifier = ref.read(toneStateProvider.notifier);
    const profiles = ToneProfile.all;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              label: '对话调性设置',
              child: Text(
                '对话调性',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '选择 Atlas 与你说话的方式。',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final profile in profiles)
                  _ToneChip(
                    profile: profile,
                    selected: state.activeTone == profile.id,
                    locked: !state.unlockedTones.contains(profile.id),
                    selectedColor: theme.colorScheme.primary,
                    onTap: () {
                      final res = notifier.switchTone(
                        profile.id,
                        energyBandwidth: 80,
                      );
                      if (res.isFailure) {
                        final failure = res.failureOrNull;
                        if (failure != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_reason(failure)),
                            ),
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 将引擎失败码映射为用户可见的说明文案。
  static String _reason(DomainFailure failure) {
    switch (failure.code) {
      case 'bandwidth':
        return '切换过于频繁，请稍后再试。';
      case 'low_energy':
        return '当前精力偏低，先照顾好自己再切换。';
      case 'tone_locked':
        return '该调性尚未解锁。';
      default:
        return '暂时无法切换调性，请稍后再试。';
    }
  }
}

class _ToneChip extends StatelessWidget {
  const _ToneChip({
    required this.profile,
    required this.selected,
    required this.locked,
    required this.selectedColor,
    required this.onTap,
  });

  final ToneProfile profile;
  final bool selected;
  final bool locked;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stateText = locked
        ? '未解锁'
        : (selected ? '当前' : '可切换');
    return Tooltip(
      message: profile.description,
      child: Semantics(
        label: '${profile.label} 调性，$stateText',
        button: !locked,
        enabled: !locked,
        child: ChoiceChip(
          label: Text(locked ? '未解锁' : profile.label),
          selected: selected,
          onSelected: locked ? null : (_) => onTap(),
          selectedColor: selectedColor.withValues(alpha: 0.18),
          avatar: locked
              ? const Icon(Icons.lock_outline, size: 16)
              : null,
        ),
      ),
    );
  }
}
