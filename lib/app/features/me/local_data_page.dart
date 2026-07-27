import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/journey/journey_editor_shared.dart';
import 'package:primeatlas/app/state/journey_state.dart';

class LocalDataPage extends ConsumerWidget {
  const LocalDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journey = ref.watch(journeyControllerProvider);
    return JourneyEditorScaffold(
      title: '本机数据状态',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('这里只显示本机保存与恢复状态，不显示云同步或远端进度。'),
          const SizedBox(height: AppTokens.space4),
          _row('写入状态', _saveStatus(journey)),
          _row('活跃成长域', journey.domains.isEmpty ? '无' : journey.domainsLabel),
          _row(
            '已暂停成长域',
            journey.pausedDomains.isEmpty ? '无' : journey.pausedDomainsLabel,
          ),
          _row('目标数', '${journey.goals.length}'),
          _row('里程碑', journey.milestone?.title ?? '未设置'),
          _row('边界确认', journey.isConfirmed ? '已确认' : '未确认'),
          if (journey.saveError != null) ...[
            const SizedBox(height: AppTokens.space3),
            Text(
              journey.saveError!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTokens.colorStatusDanger,
                  ),
            ),
          ],
          const SizedBox(height: AppTokens.space5),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                ref
                    .read(journeyControllerProvider.notifier)
                    .restoreFromLocalStore();
              },
              child: const Text('重新从本机恢复'),
            ),
          ),
        ],
      ),
    );
  }

  String _saveStatus(JourneyState journey) {
    switch (journey.saveStatus) {
      case LocalSaveStatus.persisted:
        return '已写入本机';
      case LocalSaveStatus.failed:
        return '写入失败';
      case LocalSaveStatus.saving:
        return '正在写入本机';
      case LocalSaveStatus.pendingPersistence:
        return '仅会话中，尚未写入';
    }
  }

  Widget _row(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTokens.colorBorderDefault),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
