import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/bootstrap/persistence_providers.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/journey/journey_editor_shared.dart';
import 'package:primeatlas/app/state/journey_state.dart';
import 'package:primeatlas/core/journey/journey_boundary.dart';

class BoundaryVersionsPage extends ConsumerStatefulWidget {
  const BoundaryVersionsPage({super.key});

  @override
  ConsumerState<BoundaryVersionsPage> createState() =>
      _BoundaryVersionsPageState();
}

class _BoundaryVersionsPageState extends ConsumerState<BoundaryVersionsPage> {
  late Future<List<BoundaryVersionSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(listBoundaryVersionsProvider).call();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ref.read(listBoundaryVersionsProvider).call();
    });
    await _future;
  }

  Future<void> _restore(BoundaryVersionSummary version) async {
    final result =
        await ref.read(restoreBoundaryVersionProvider).call(version.versionId);
    if (!mounted) {
      return;
    }
    if (!result.ok) {
      showJourneyEditorError(
        context,
        result.message ?? '恢复失败，请重试',
      );
      return;
    }
    await ref.read(journeyControllerProvider.notifier).restoreFromLocalStore();
    await _reload();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已创建新的活跃边界版本（恢复不会改写历史）')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JourneyEditorScaffold(
      title: '目标边界版本',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '仅展示你确认过的目标边界版本。恢复会创建新的 active 版本，不会原地覆盖历史。',
          ),
          const SizedBox(height: AppTokens.space4),
          FutureBuilder<List<BoundaryVersionSummary>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppTokens.space6),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text(
                  '读取版本失败，请稍后重试。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTokens.colorStatusDanger,
                      ),
                );
              }
              final versions = snapshot.data ?? const <BoundaryVersionSummary>[];
              if (versions.isEmpty) {
                return const Text('还没有已确认的目标边界版本。先在旅程中完成确认。');
              }
              return Column(
                children: versions.map((version) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppTokens.space3),
                    padding: const EdgeInsets.all(AppTokens.space4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTokens.colorBorderDefault),
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      color: version.isActive
                          ? AppTokens.colorActionPrimarySubtle
                          : AppTokens.colorBgSurface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'v${version.ordinal} · ${version.isActive ? '当前活跃' : '历史'}'
                          '${version.kind == 'restored' ? ' · 恢复生成' : ''}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppTokens.space2),
                        Text('方向：${version.direction}'),
                        Text('约束：${version.constraint}'),
                        Text('成长域：${version.domainCode}'),
                        Text('目标：${version.goalTitle}'),
                        Text('里程碑：${version.milestone.title}'),
                        if (!version.isActive) ...[
                          const SizedBox(height: AppTokens.space3),
                          SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => _restore(version),
                              child: const Text('恢复为新版本'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(growable: false),
              );
            },
          ),
          const SizedBox(height: AppTokens.space3),
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: _reload,
              child: const Text('刷新版本列表'),
            ),
          ),
        ],
      ),
    );
  }
}
