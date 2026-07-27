import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/app/state/journey_state.dart';

void main() {
  test('completes the local direction-goal-milestone boundary', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(journeyControllerProvider.notifier);

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
    controller.confirmBoundary();

    final state = container.read(journeyControllerProvider);
    expect(state.isConfirmed, isTrue);
    expect(state.saveStatus, LocalSaveStatus.pendingPersistence);
    expect(state.domain, '体能');
  });

  test('rejects confirmation when the local boundary is incomplete', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(journeyControllerProvider.notifier).confirmBoundary,
      throwsStateError,
    );
  });
}
