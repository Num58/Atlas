import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/app/bootstrap/persistence_providers.dart';
import 'package:primeatlas/app/state/journey_state.dart';
import 'package:primeatlas/application/journey/confirm_journey_boundary.dart';

class _SucceedingConfirm implements ConfirmJourneyBoundary {
  @override
  Future<ConfirmJourneyBoundaryResult> call(
    ConfirmJourneyBoundaryCommand command,
  ) async {
    return const ConfirmJourneyBoundaryResult.success();
  }
}

class _FailingConfirm implements ConfirmJourneyBoundary {
  @override
  Future<ConfirmJourneyBoundaryResult> call(
    ConfirmJourneyBoundaryCommand command,
  ) async {
    return const ConfirmJourneyBoundaryResult.failure(
      code: 'storage_failed',
      message: '磁盘不足',
    );
  }
}

class _EmptyLoad implements LoadLatestJourneyBoundary {
  @override
  Future<JourneyBoundarySnapshot?> call() async => null;
}

class _SnapshotLoad implements LoadLatestJourneyBoundary {
  @override
  Future<JourneyBoundarySnapshot?> call() async {
    return const JourneyBoundarySnapshot(
      direction: '改善长距离跑步的稳定性',
      constraint: '每周三个晚间时段，每次四十分钟',
      domain: '体能',
      goalTitle: '完成一次稳定的十公里训练',
      milestoneTitle: '完成连续四周基础训练',
      milestoneEvidenceRule: '每周保留三次训练记录',
      milestoneWindow: '四周',
    );
  }
}

void main() {
  Future<void> seedCompleteDraft(JourneyController controller) async {
    controller.saveDirection(
      direction: '改善长距离跑步的稳定性',
      constraint: '每周三个晚间时段，每次四十分钟',
    );
    controller.selectDomain('体能');
    controller.saveGoal('完成一次稳定的十公里训练');
    controller.saveMilestone(
      const MilestoneDraft(
        title: '完成连续四周基础训练',
        evidenceRule: '每周保留三次训练记录',
        window: '四周',
      ),
    );
  }

  List<Override> baseOverrides({
    ConfirmJourneyBoundary? confirm,
    LoadLatestJourneyBoundary? load,
  }) {
    return [
      loadLatestJourneyBoundaryProvider.overrideWithValue(
        load ?? _EmptyLoad(),
      ),
      confirmJourneyBoundaryProvider.overrideWithValue(
        confirm ?? _SucceedingConfirm(),
      ),
    ];
  }

  test('persists confirmation only after use-case success', () async {
    final container = ProviderContainer(
      overrides: baseOverrides(confirm: _SucceedingConfirm()),
    );
    addTearDown(container.dispose);
    final controller = container.read(journeyControllerProvider.notifier);

    await seedCompleteDraft(controller);
    await controller.confirmBoundary();

    final state = container.read(journeyControllerProvider);
    expect(state.isConfirmed, isTrue);
    expect(state.saveStatus, LocalSaveStatus.persisted);
    expect(state.domain, '体能');
    expect(state.direction, isNotEmpty);
  });

  test('keeps edit buffer and marks failed when use-case fails', () async {
    final container = ProviderContainer(
      overrides: baseOverrides(confirm: _FailingConfirm()),
    );
    addTearDown(container.dispose);
    final controller = container.read(journeyControllerProvider.notifier);

    await seedCompleteDraft(controller);
    await controller.confirmBoundary();

    final state = container.read(journeyControllerProvider);
    expect(state.isConfirmed, isFalse);
    expect(state.saveStatus, LocalSaveStatus.failed);
    expect(state.saveError, '磁盘不足');
    expect(state.direction, '改善长距离跑步的稳定性');
    expect(state.goal, '完成一次稳定的十公里训练');
    expect(state.milestone?.title, '完成连续四周基础训练');
  });

  test('rejects confirmation when the local boundary is incomplete', () async {
    final container = ProviderContainer(
      overrides: baseOverrides(confirm: _SucceedingConfirm()),
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(journeyControllerProvider.notifier).confirmBoundary(),
      throwsStateError,
    );
    final state = container.read(journeyControllerProvider);
    expect(state.isConfirmed, isFalse);
    expect(state.saveStatus, LocalSaveStatus.pendingPersistence);
  });

  test('restores confirmed boundary from local load Port', () async {
    final container = ProviderContainer(
      overrides: baseOverrides(load: _SnapshotLoad()),
    );
    addTearDown(container.dispose);
    final controller = container.read(journeyControllerProvider.notifier);

    await controller.restoreFromLocalStore();

    final state = container.read(journeyControllerProvider);
    expect(state.isConfirmed, isTrue);
    expect(state.saveStatus, LocalSaveStatus.persisted);
    expect(state.direction, '改善长距离跑步的稳定性');
    expect(state.constraint, '每周三个晚间时段，每次四十分钟');
    expect(state.domain, '体能');
    expect(state.goal, '完成一次稳定的十公里训练');
    expect(state.milestone?.title, '完成连续四周基础训练');
    expect(state.milestone?.evidenceRule, '每周保留三次训练记录');
    expect(state.milestone?.window, '四周');
  });
}
