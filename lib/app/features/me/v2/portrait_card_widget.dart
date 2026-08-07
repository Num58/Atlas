import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/me/v2/portrait_providers.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';

/// 画像卡片（P3-1 动态轴雷达 / 版本标签 / 过渡态叙事）。
///
/// 无画像时显示授权提示；有画像时仅渲染激活维度（P-RL1），以横向条形展示
/// 各激活轴取值，并展示版本号与过渡态叙事。不引入任何外部图表库，使用
/// Flutter 自带控件绘制；不使用 emoji，不使用紫→粉渐变。
class PortraitCardWidget extends ConsumerWidget {
  const PortraitCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(portraitProvider);
    final theme = Theme.of(context);

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.colorBgSurface,
        border: Border.all(color: AppTokens.colorBorderDefault),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space5),
        child: snapshot == null
            ? _EmptyState(theme: theme)
            : _Body(snapshot: snapshot, theme: theme),
      ),
    );

    return card;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Text(
        '暂无画像，请先授权',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: AppTokens.colorTextSecondary),
      );
}

class _Body extends StatelessWidget {
  const _Body({required this.snapshot, required this.theme});
  final PortraitSnapshot snapshot;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final maxValue = snapshot.values.isEmpty
        ? 1.0
        : snapshot.values.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('画像 v${snapshot.version}', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppTokens.space2),
        Text(
          '授权时间：${_format(snapshot.consentedAt)}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: AppTokens.colorTextMuted),
        ),
        const SizedBox(height: AppTokens.space4),
        for (final axis in snapshot.activeAxes) ...[
          _AxisBar(
            label: axis.label,
            value: snapshot.values[axis.id] ?? 0.0,
            ratio: maxValue <= 0 ? 0.0 : (snapshot.values[axis.id] ?? 0) / maxValue,
            theme: theme,
          ),
          const SizedBox(height: AppTokens.space3),
        ],
        if (snapshot.transitionNarrative.isNotEmpty) ...[
          const SizedBox(height: AppTokens.space2),
          Text(
            '过渡：${snapshot.transitionNarrative}',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppTokens.colorTextSecondary),
          ),
        ],
      ],
    );
  }

  String _format(DateTime dt) =>
      '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
      '${_pad(dt.hour)}:${_pad(dt.minute)}';

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _AxisBar extends StatelessWidget {
  const _AxisBar({
    required this.label,
    required this.value,
    required this.ratio,
    required this.theme,
  });

  final String label;
  final double value;
  final double ratio;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final clamped = ratio.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppTokens.space1),
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTokens.colorBgSubtle,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clamped,
            child: Container(
              decoration: BoxDecoration(
                color: AppTokens.colorActionPrimary,
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTokens.space1),
        Text(
          value.toStringAsFixed(2),
          style: theme.textTheme.bodySmall
              ?.copyWith(color: AppTokens.colorTextMuted),
        ),
      ],
    );
  }
}
