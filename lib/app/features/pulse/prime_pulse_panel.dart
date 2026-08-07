import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/design_system/app_icon.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/core/common/domain_failure.dart';
import 'package:primeatlas/core/common/result.dart';
import 'package:primeatlas/core/pulse/pulse_types.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';
import 'package:primeatlas/core/tone/tone_types.dart';
import 'package:primeatlas/app/features/pulse/pulse_providers.dart';

/// Prime Pulse 每日面板（独立组件，尚未挂载到任何路由）。
///
/// 展示：今日能量 + 今日执行 + Prime Pulse 打卡控件。
/// 反馈语义关联目标进度（“离目标又近了一步”），而非“打卡成功”。
///
/// 联动（observe-only）：
/// - 调性（tone）：从 [pulseToneProvider] 读取当前生效调性，显示语气；
/// - 画像（portrait）：从 [pulseActiveAxesProvider] 读取活跃维度，显示今日聚焦维度。
/// 本组件绝不修改调性 / 画像状态，也不对用户做任何身份判定。
///
/// 布局：移动端单列（手机 portrait/landscape），平板 / 宽屏（≥720）双栏自适应。
///
/// 挂载说明（后续路由）：在 [AppShell] 增加 Pulse 导航项，或于 me/journey
/// 页面嵌入本组件——当前为避免触碰 route C 文件，保持独立、不接线。
class PrimePulsePanel extends ConsumerWidget {
  const PrimePulsePanel({super.key});

  /// 双栏断点（逻辑像素）。低于此宽度单列，达到此宽度双栏。
  static const double twoColumnBreakpoint = 720;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(pulseProvider);
    ref.watch(pulseToneProvider);
    ref.watch(pulseActiveAxesProvider);
    final notifier = ref.read(pulseProvider.notifier);
    final snapshot = notifier.snapshot;

    final tone = ref.read(pulseToneProvider);
    final axes = ref.read(pulseActiveAxesProvider);
    final theme = Theme.of(context);

    final focusLabel = snapshot.focusDimension == null
        ? null
        : _labelForAxis(axes, snapshot.focusDimension!);
    final toneLabel = ToneProfile.byId(tone).label;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= twoColumnBreakpoint;
        final runSpacing = AppTokens.space3;
        final cardWidth = isWide
            ? (constraints.maxWidth - runSpacing) / 2
            : constraints.maxWidth;

        final cards = <Widget>[
          SizedBox(
            width: cardWidth,
            child: _EnergyCard(
              band: snapshot.energyBand,
              latest: snapshot.latestEnergyLevel,
              onMark: (level) => _report(context, notifier.logEnergy(level)),
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _ExecutionCard(
              total: snapshot.executionTotal,
              done: snapshot.executionDone,
              onComplete: (taskId, dimension, rating) => _report(
                context,
                notifier.recordExecution(
                  taskId: taskId,
                  dimension: dimension,
                  subjectiveRating: rating,
                  energyLevel: snapshot.latestEnergyLevel,
                ),
              ),
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _CheckInCard(
              done: snapshot.checkInDone,
              energyLevel: snapshot.latestEnergyLevel,
              onCheckIn: (intention) {
                final res = notifier.checkIn(
                  energyLevel: snapshot.latestEnergyLevel ?? 60,
                  intention: intention,
                );
                if (res.isSuccess) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已打卡。今天离目标又近了一步。'),
                      ),
                    );
                  }
                } else {
                  _report(context, res);
                }
              },
            ),
          ),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                label: 'Prime Pulse 今日',
                child: Text(
                  'Prime Pulse · 今日',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: AppTokens.space2),
              Text(
                '先标记此刻的能量，再记录今日完成，最后做一次 Prime Pulse 打卡。',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppTokens.space3),
              _LinkageBar(toneLabel: toneLabel, focusLabel: focusLabel),
              const SizedBox(height: AppTokens.space3),
              Wrap(
                spacing: runSpacing,
                runSpacing: runSpacing,
                children: cards,
              ),
              const SizedBox(height: AppTokens.space2),
              Text(
                '该面板为独立组件，稍后由路由接入 AppShell 或 me/journey 页面。',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        );
      },
    );
  }

  static String? _labelForAxis(List<PortraitAxis> axes, String id) {
    for (final a in axes) {
      if (a.id == id) return a.label;
    }
    return null;
  }

  void _report<T>(BuildContext context, Result<T> res) {
    if (res.isFailure) {
      final failure = res.failureOrNull;
      if (failure != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_reason(failure))),
        );
      }
    }
  }

  static String _reason(DomainFailure failure) {
    switch (failure.code) {
      case 'energy_out_of_range':
        return '能量值需在 0 到 100 之间。';
      case 'already_checked_in':
        return '今天已经完成 Prime Pulse 打卡了。';
      case 'execution_invalid_rating':
        return '主观评分需在 1 到 5 之间。';
      case 'execution_invalid_energy':
        return '能量值需在 0 到 100 之间。';
      default:
        return '操作未能完成，请稍后再试。';
    }
  }
}

/// 联动信息条：显示当前语气（tone）与今日聚焦维度（portrait）。
///
/// observe-only：仅展示，不提供切换/编辑入口。
class _LinkageBar extends StatelessWidget {
  const _LinkageBar({required this.toneLabel, this.focusLabel});

  final String toneLabel;
  final String? focusLabel;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _Chip(
        icon: AppIcon(
          icon: AppIconKey.target,
          semanticLabel: '当前语气',
          size: 16,
        ),
        label: '语气 · $toneLabel',
      ),
    ];
    if (focusLabel != null) {
      chips.add(_Chip(
        icon: AppIcon(
          icon: AppIconKey.route,
          semanticLabel: '今日聚焦维度',
          size: 16,
        ),
        label: '今日聚焦 · $focusLabel',
      ));
    }
    return Wrap(
      spacing: AppTokens.space2,
      runSpacing: AppTokens.space2,
      children: chips,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space2,
      ),
      decoration: BoxDecoration(
        color: AppTokens.colorActionPrimarySubtle,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppTokens.colorBorderDefault, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: AppTokens.space2),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTokens.colorTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 能量卡片：显示当前档位，并提供三档快捷标记。
class _EnergyCard extends StatelessWidget {
  const _EnergyCard({
    required this.band,
    required this.latest,
    required this.onMark,
  });

  final EnergyBand? band;
  final int? latest;
  final ValueChanged<int> onMark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = band?.label ?? '未标记';
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  icon: AppIconKey.energy,
                  semanticLabel: '今日能量',
                  size: 20,
                ),
                const SizedBox(width: AppTokens.space2),
                Text('今日能量', style: theme.textTheme.titleMedium),
                const Spacer(),
                Semantics(
                  label: '当前能量档位 $label',
                  child: Text(label, style: theme.textTheme.labelLarge),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space2),
            Text(
              latest == null ? '还没标记今天的状态。' : '当前能量：$latest / 100',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppTokens.space3),
            Wrap(
              spacing: AppTokens.space2,
              runSpacing: AppTokens.space2,
              children: [
                for (final level in const [25, 55, 85])
                  ChoiceChip(
                    label: Text(_bandHint(level)),
                    selected: latest == level,
                    onSelected: (_) => onMark(level),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _bandHint(int level) => switch (EnergyBand.fromLevel(level)) {
        EnergyBand.high => '充沛',
        EnergyBand.medium => '平稳',
        EnergyBand.low => '偏低',
        EnergyBand.recovering => '恢复中',
      };
}

/// 今日执行卡片：内联表单记录一次完成（任务 / 维度 / 主观评分）。
class _ExecutionCard extends StatefulWidget {
  const _ExecutionCard({
    required this.total,
    required this.done,
    required this.onComplete,
  });

  final int total;
  final int done;
  final void Function(String taskId, String dimension, int? rating) onComplete;

  @override
  State<_ExecutionCard> createState() => _ExecutionCardState();
}

class _ExecutionCardState extends State<_ExecutionCard> {
  final _taskCtrl = TextEditingController();
  final _dimCtrl = TextEditingController(text: '体能');
  int? _rating;

  @override
  void dispose() {
    _taskCtrl.dispose();
    _dimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  icon: AppIconKey.checkCircle,
                  semanticLabel: '今日执行',
                  size: 20,
                ),
                const SizedBox(width: AppTokens.space2),
                Text('今日执行', style: theme.textTheme.titleMedium),
                const Spacer(),
                Semantics(
                  label: '已完成 ${widget.done} 项，共 ${widget.total} 项',
                  child: Text(
                    '${widget.done} / ${widget.total} 完成',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space3),
            TextField(
              controller: _taskCtrl,
              decoration: const InputDecoration(
                labelText: '完成了什么',
                hintText: '例如：深蹲 5×5',
                isDense: true,
              ),
            ),
            const SizedBox(height: AppTokens.space2),
            TextField(
              controller: _dimCtrl,
              decoration: const InputDecoration(
                labelText: '维度',
                hintText: '体能 / 语言 / 认知',
                isDense: true,
              ),
            ),
            const SizedBox(height: AppTokens.space2),
            Wrap(
              spacing: 6,
              children: [
                for (final r in const [1, 2, 3, 4, 5])
                  ChoiceChip(
                    label: Text('$r'),
                    selected: _rating == r,
                    onSelected: (_) => setState(() => _rating = r),
                  ),
              ],
            ),
            const SizedBox(height: AppTokens.space3),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const AppIcon(
                  icon: AppIconKey.zap,
                  semanticLabel: '记录完成',
                  size: 20,
                ),
                label: const Text('记录完成'),
                onPressed: () {
                  final task = _taskCtrl.text.trim();
                  if (task.isEmpty) return;
                  widget.onComplete(task, _dimCtrl.text.trim(), _rating);
                  _taskCtrl.clear();
                  setState(() => _rating = null);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Prime Pulse 打卡卡片：完成一次今日承诺；已打卡则展示点亮态。
class _CheckInCard extends StatelessWidget {
  const _CheckInCard({
    required this.done,
    required this.energyLevel,
    required this.onCheckIn,
  });

  final bool done;
  final int? energyLevel;
  final ValueChanged<String?> onCheckIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  icon: AppIconKey.zap,
                  semanticLabel: 'Prime Pulse 打卡',
                  size: 20,
                  color: cs.primary,
                ),
                const SizedBox(width: AppTokens.space2),
                Text('Prime Pulse 打卡', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppTokens.space2),
            Text(
              done
                  ? '今天已经打卡。把注意力放在真正推进目标的事上。'
                  : '做一次今日承诺：标记此刻能量，写下今天最重要的那一件事。',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppTokens.space3),
            if (!done)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => onCheckIn(null),
                  child: const Text('完成今日 Prime Pulse 打卡'),
                ),
              )
            else
              Semantics(
                label: '已打卡，能量标记 ${energyLevel ?? '—'} 每 100',
                child: Row(
                  children: [
                    AppIcon(
                      icon: AppIconKey.zap,
                      semanticLabel: '已打卡',
                      size: 20,
                      color: cs.primary,
                    ),
                    const SizedBox(width: AppTokens.space2),
                    Expanded(
                      child: Text(
                        '已点亮。能量标记：${energyLevel ?? '—'} / 100',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
