import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/design_system/app_icon.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/me/v2/me_providers.dart';
import 'package:primeatlas/app/state/app_providers.dart';

class MePage extends ConsumerWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(localDataStatusProvider);
    final ownerId = ref.watch(ownerIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final tablet = constraints.maxWidth > 600;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '本地优先的个人成长系统',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTokens.space2),
              Text(
                '所有边界、目标与里程碑都保存在你的设备本机，'
                '不上传任何云端。',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTokens.colorTextSecondary,
                    ),
              ),
              const SizedBox(height: AppTokens.space6),
              statusAsync.when(
                loading: () => const _StatusCardSkeleton(),
                error: (_, __) => const _StatusCardError(),
                data: (status) => _LocalDataStatusCard(status: status),
              ),
              const SizedBox(height: AppTokens.space4),
              _EntryTile(
                icon: AppIconKey.route,
                title: '成长域管理',
                subtitle: '查看与聚焦你的成长方向',
                onTap: () => context.go('/journey'),
              ),
              _EntryTile(
                icon: AppIconKey.target,
                title: '本机数据状态',
                subtitle: '查看 Schema 版本与完整性',
                onTap: () => context.push('/me/local-data'),
              ),
              const SizedBox(height: AppTokens.space6),
              _AppInfoCard(ownerId: ownerId),
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
      ),
    );
  }
}

class _LocalDataStatusCard extends StatelessWidget {
  const _LocalDataStatusCard({required this.status});

  final LocalDataStatus status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('本机数据状态', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space3),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Schema 版本',
                    value: '${status.schemaVersionCount}',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: '完整性',
                    value: status.integrityOk ? '正常' : '异常',
                    valueColor: status.integrityOk
                        ? AppTokens.colorStatusSuccess
                        : AppTokens.colorStatusDanger,
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: '保存位置',
                    value: '本机',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space3),
            Row(
              children: [
                Icon(
                  status.integrityOk
                      ? Icons.verified_user_outlined
                      : Icons.warning_amber_outlined,
                  size: 18,
                  color: status.integrityOk
                      ? AppTokens.colorStatusSuccess
                      : AppTokens.colorStatusDanger,
                ),
                const SizedBox(width: AppTokens.space2),
                Expanded(
                  child: Text(
                    '${status.syncLabelText} · 无云端同步',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTokens.colorActionPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: valueColor ?? AppTokens.colorTextPrimary,
              ),
        ),
        const SizedBox(height: AppTokens.space1),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final AppIconKey icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.space2),
      child: ListTile(
        leading: AppIcon(icon: icon, semanticLabel: title, size: 20),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard({required this.ownerId});

  final String ownerId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('应用信息', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space2),
            _Row(label: '版本', value: '0.2.0 (本地优先)'),
            _Row(label: '账户', value: ownerId == 'guest' ? '游客（本机）' : ownerId),
            _Row(label: '云端同步', value: '未启用'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTokens.colorBorderDefault),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StatusCardSkeleton extends StatelessWidget {
  const _StatusCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppTokens.colorBgSubtle,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
    );
  }
}

class _StatusCardError extends StatelessWidget {
  const _StatusCardError();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space4),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined, color: AppTokens.colorStatusDanger),
            const SizedBox(width: AppTokens.space2),
            Expanded(
              child: Text(
                '本机数据状态读取失败',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
