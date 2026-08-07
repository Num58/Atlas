import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/design_system/app_icon.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/journey/v2/journey_providers.dart';
import 'package:primeatlas/app/features/journey/v2/journey_strings.dart';
import 'package:primeatlas/app/state/app_providers.dart';
import 'package:primeatlas/application/domains/activate_domain.dart';
import 'package:primeatlas/core/ports/domain_repository.dart';

class DomainListPage extends ConsumerWidget {
  const DomainListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domainsAsync = ref.watch(activeDomainsProvider);
    final ownerId = ref.watch(ownerIdProvider);
    final actions = ref.watch(domainActionsProvider);

    ref.listen<DomainActionState>(domainActionsProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        final failure = next.error!;
        final message = failure.details['message'] as String? ??
            '操作未完成，请稍后重试';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    final isFull = domainsAsync.valueOrNull?.length == 3;

    return Scaffold(
      appBar: AppBar(title: const Text('成长域')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: actions.busy
            ? null
            : () => _openActivateSheet(context, ref, ownerId, isFull),
        icon: const AppIcon(
          icon: AppIconKey.target,
          semanticLabel: '激活成长域',
          size: 20,
        ),
        label: const Text('激活成长域'),
      ),
      body: domainsAsync.when(
        loading: () => const _DomainSkeleton(),
        error: (error, _) => _ErrorState(
          message: '成长域加载失败',
          onRetry: () => ref.invalidate(activeDomainsProvider),
        ),
        data: (domains) => _DomainContent(
          domains: domains,
          isFull: isFull,
        ),
      ),
    );
  }

  Future<void> _openActivateSheet(
    BuildContext context,
    WidgetRef ref,
    String ownerId,
    bool isFull,
  ) async {
    if (isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已聚焦 3 个成长域，请先归档一个再激活新的'),
        ),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const _ActivateSheet(),
    );
    if (picked == null || !context.mounted) return;

    final activeCount = ref.read(activeDomainsProvider).valueOrNull?.length ?? 0;
    final command = ActivateDomainCommand(
      ownerId: ownerId,
      domainCode: picked,
      priority: activeCount + 1,
      sourcePortraitVersionId: '',
    );
    await ref.read(domainActionsProvider.notifier).activate(command);
  }
}

class _DomainContent extends StatelessWidget {
  const _DomainContent({required this.domains, required this.isFull});

  final List<Domain> domains;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final tablet = maxWidth > 600;
        final children = [
          if (domains.isEmpty)
            const _DomainEmpty()
          else ...[
            if (isFull) const _FocusSuggestion(),
            ...domains.map((d) => _DomainCard(domain: d)),
          ],
        ];
        return ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            if (tablet)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              )
            else
              ...children,
          ],
        );
      },
    );
  }
}

class _FocusSuggestion extends StatelessWidget {
  const _FocusSuggestion();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTokens.space3),
      padding: const EdgeInsets.all(AppTokens.space4),
      decoration: BoxDecoration(
        color: AppTokens.colorActionPrimarySubtle,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '已聚焦 3 个成长域',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTokens.colorActionPrimary,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            '专注比贪多更重要。同时激活超过 3 个成长域会稀释精力，'
            '建议先深耕现有方向，或归档一个再开启新的。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _DomainCard extends ConsumerWidget {
  const _DomainCard({required this.domain});

  final Domain domain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(ownerIdProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.space3),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    domainLabel(domain.domainCode),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTokens.space1),
                  Text(
                    '优先级 ${domain.priority} · 已激活',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              tooltip: '归档${domainLabel(domain.domainCode)}成长域',
              onPressed: () => _confirmArchive(context, ref, ownerId, domain),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmArchive(
    BuildContext context,
    WidgetRef ref,
    String ownerId,
    Domain domain,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('归档「${domainLabel(domain.domainCode)}」？'),
        content: const Text(
          '归档会暂停该成长域下所有活跃目标，且需要你确认操作影响。'
          '归档后仍可从本机恢复。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认归档'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final command = ArchiveDomainCommand(
      ownerId: ownerId,
      domainId: domain.id,
      expectedVersion: domain.version,
      impactSha256: computeDomainImpactSha256(
        domain.id,
        domain.domainCode,
        domain.status,
        domain.version,
      ),
      nowUs: DateTime.now().microsecondsSinceEpoch,
    );
    await ref.read(domainActionsProvider.notifier).archive(command);
  }
}

class _ActivateSheet extends StatefulWidget {
  const _ActivateSheet();

  @override
  State<_ActivateSheet> createState() => _ActivateSheetState();
}

class _ActivateSheetState extends State<_ActivateSheet> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('激活成长域', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space3),
            DropdownButtonFormField<String>(
              value: _selected,
              hint: const Text('选择一个成长方向'),
              items: domainCatalog.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _selected = value),
              decoration: const InputDecoration(
                labelText: '成长域',
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            FilledButton(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.of(context).pop(_selected),
              child: const Text('激活'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DomainEmpty extends StatelessWidget {
  const _DomainEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.explore_outlined, size: 48),
          const SizedBox(height: AppTokens.space4),
          Text(
            '还没有激活的成长域',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            '先聚焦一个方向，像精密决策工具一样把精力收束到最重要的事上。',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DomainSkeleton extends StatelessWidget {
  const _DomainSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: List.generate(
        3,
        (_) => Container(
          height: 72,
          margin: const EdgeInsets.only(bottom: AppTokens.space3),
          decoration: BoxDecoration(
            color: AppTokens.colorBgSubtle,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
        ),
      ),
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
