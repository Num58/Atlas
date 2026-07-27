import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/state/journey_state.dart';

class MePage extends ConsumerWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journey = ref.watch(journeyControllerProvider);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          Text('我的', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppTokens.space2),
          Text(
            '查看目标边界版本与本机写入状态。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTokens.colorTextSecondary,
                ),
          ),
          const SizedBox(height: AppTokens.space6),
          _StatusSection(journey: journey),
          const SizedBox(height: AppTokens.space6),
          Text('本机存储能力', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppTokens.space3),
          _InfoRow(label: '当前状态', value: _capabilityStatus(journey)),
          _InfoRow(label: '会话草稿', value: _sessionDraftStatus(journey)),
          _InfoRow(label: '持久版本', value: _persistenceStatus(journey)),
          const SizedBox(height: AppTokens.space4),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.push('/me/local-data'),
              child: const Text('打开本机数据状态'),
            ),
          ),
          const SizedBox(height: AppTokens.space6),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppTokens.colorBgSubtle,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.space4),
              child: Text(_notice(journey)),
            ),
          ),
        ],
      ),
    );
  }

  String _capabilityStatus(JourneyState journey) {
    switch (journey.saveStatus) {
      case LocalSaveStatus.persisted:
        return '本机写入可用';
      case LocalSaveStatus.failed:
        return '本机写入失败';
      case LocalSaveStatus.saving:
        return '正在写入本机';
      case LocalSaveStatus.pendingPersistence:
        return '研发接入中';
    }
  }

  String _sessionDraftStatus(JourneyState journey) {
    if (journey.direction.isEmpty) {
      return '无';
    }
    if (journey.saveStatus == LocalSaveStatus.persisted) {
      return '已提交为持久版本';
    }
    return '仅本次会话';
  }

  String _persistenceStatus(JourneyState journey) {
    switch (journey.saveStatus) {
      case LocalSaveStatus.persisted:
        return '已写入本机';
      case LocalSaveStatus.failed:
        return '写入失败，可重试';
      case LocalSaveStatus.saving:
        return '等待写入本机';
      case LocalSaveStatus.pendingPersistence:
        return '尚未形成';
    }
  }

  String _notice(JourneyState journey) {
    switch (journey.saveStatus) {
      case LocalSaveStatus.persisted:
        return '目标边界已写入本机。杀进程后应能恢复同一确认结果；若不能恢复说明写入链路仍有缺口。';
      case LocalSaveStatus.failed:
        return '最近一次本机写入失败，编辑缓冲仍保留。请从旅程重试，未成功前不会显示已写入。';
      case LocalSaveStatus.saving:
        return '正在通过应用层用例写入本机，请勿关闭应用。';
      case LocalSaveStatus.pendingPersistence:
        return '方向、现实约束、成长域、目标与里程碑目前仅在会话中整理；确认后才会尝试写入本机。';
    }
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.journey});

  final JourneyState journey;

  @override
  Widget build(BuildContext context) {
    final hasDraft = journey.direction.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.colorBgSurface,
        border: Border.all(color: AppTokens.colorBorderDefault),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('目标边界版本', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space3),
            Text(_summary(journey, hasDraft)),
            const SizedBox(height: AppTokens.space3),
            Text(
              _badge(journey),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _badgeColor(journey),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _summary(JourneyState journey, bool hasDraft) {
    if (journey.saveStatus == LocalSaveStatus.persisted &&
        journey.isConfirmed) {
      return '当前边界已由你明确确认，并已写入本机。';
    }
    if (journey.saveStatus == LocalSaveStatus.failed) {
      return '最近一次确认写入失败，本次会话草案仍保留，可继续修改后重试。';
    }
    if (journey.saveStatus == LocalSaveStatus.saving) {
      return '正在确认目标边界并写入本机。';
    }
    if (hasDraft) {
      return '本次会话有一份方向草案，尚未成功写入本机。';
    }
    return '尚无目标边界草案。先从旅程写下方向。';
  }

  String _badge(JourneyState journey) {
    switch (journey.saveStatus) {
      case LocalSaveStatus.persisted:
        return '已写入本机';
      case LocalSaveStatus.failed:
        return '写入失败';
      case LocalSaveStatus.saving:
        return '等待写入本机';
      case LocalSaveStatus.pendingPersistence:
        return '当前仅保留在本次会话';
    }
  }

  Color _badgeColor(JourneyState journey) {
    switch (journey.saveStatus) {
      case LocalSaveStatus.persisted:
        return AppTokens.colorStatusSuccess;
      case LocalSaveStatus.failed:
        return AppTokens.colorStatusDanger;
      case LocalSaveStatus.saving:
        return AppTokens.colorActionPrimary;
      case LocalSaveStatus.pendingPersistence:
        return AppTokens.colorTextMuted;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
