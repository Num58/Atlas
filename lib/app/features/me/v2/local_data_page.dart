import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/me/v2/me_providers.dart';
import 'package:primeatlas/core/ports/local_persistence_repository.dart';

class LocalDataPage extends ConsumerWidget {
  const LocalDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(localDataStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('本机数据状态')),
      body: statusAsync.when(
        loading: () => const _LocalDataSkeleton(),
        error: (_, __) => _ErrorState(
          message: '本机数据状态读取失败',
          onRetry: () => ref.invalidate(localDataStatusProvider),
        ),
        data: (status) => _LocalDataContent(status: status),
      ),
    );
  }
}

class _LocalDataContent extends StatelessWidget {
  const _LocalDataContent({required this.status});

  final LocalDataStatus status;

  @override
  Widget build(BuildContext context) {
    final entries = status.schemaState.entries;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tablet = constraints.maxWidth > 600;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Banner(integrityOk: status.integrityOk),
            const SizedBox(height: AppTokens.space5),
            Text(
              'Schema 迁移记录',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTokens.space2),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppTokens.space3),
                child: Text('尚无迁移记录。'),
              )
            else
              ...entries.map((e) => _MigrationRow(entry: e)),
            const SizedBox(height: AppTokens.space5),
            _LocalFirstNotice(),
          ],
        );
        if (tablet) {
          return ListView(
            padding: const EdgeInsets.all(AppTokens.space4),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: content,
                ),
              ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [content],
        );
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.integrityOk});

  final bool integrityOk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space4),
      decoration: BoxDecoration(
        color: integrityOk
            ? AppTokens.colorActionPrimarySubtle
            : AppTokens.colorBgSubtle,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Row(
        children: [
          Icon(
            integrityOk
                ? Icons.verified_user_outlined
                : Icons.warning_amber_outlined,
            color: integrityOk
                ? AppTokens.colorStatusSuccess
                : AppTokens.colorStatusDanger,
          ),
          const SizedBox(width: AppTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  integrityOk ? '本机数据完整' : '本机数据完整性异常',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTokens.space1),
                Text(
                  integrityOk
                      ? '所有表与约束检查通过，数据仅存于本机。'
                      : '检测到完整性问题，请在设置中重新校验本机数据。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MigrationRow extends StatelessWidget {
  const _MigrationRow({required this.entry});

  final SchemaMigrationEntry entry;

  @override
  Widget build(BuildContext context) {
    final checksum = entry.checksum.length > 12
        ? '${entry.checksum.substring(0, 12)}…'
        : entry.checksum;
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(vertical: AppTokens.space2),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTokens.colorBorderDefault),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              'v${entry.version}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppTokens.space1),
                Text(
                  '校验 $checksum · 应用 ${entry.appVersion}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalFirstNotice extends StatelessWidget {
  const _LocalFirstNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space4),
      decoration: BoxDecoration(
        color: AppTokens.colorBgSubtle,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本地优先，没有云端',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            'PrimeAtlas 把你的成长手册完整保存在这台设备上。'
            '没有账号云端同步、没有后台上传——断网也能使用，'
            '数据归属与控制权始终在你手里。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _LocalDataSkeleton extends StatelessWidget {
  const _LocalDataSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppTokens.colorBgSubtle,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        ...List.generate(
          5,
          (_) => Container(
            height: 56,
            margin: const EdgeInsets.only(bottom: AppTokens.space2),
            decoration: BoxDecoration(
              color: AppTokens.colorBgSubtle,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
          ),
        ),
      ],
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
