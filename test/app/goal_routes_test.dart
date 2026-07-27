import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/bootstrap/persistence_providers.dart';
import 'package:primeatlas/app/navigation/app_router.dart';
import 'package:primeatlas/app/primeatlas_app.dart';
import 'package:primeatlas/app/state/journey_state.dart';
import 'package:primeatlas/application/journey/confirm_journey_boundary.dart';

class _EmptyLoad implements LoadLatestJourneyBoundary {
  @override
  Future<JourneyBoundarySnapshot?> call() async => null;
}

class _NoopConfirm implements ConfirmJourneyBoundary {
  @override
  Future<ConfirmJourneyBoundaryResult> call(
    ConfirmJourneyBoundaryCommand command,
  ) async {
    return const ConfirmJourneyBoundaryResult.success();
  }
}

void main() {
  testWidgets('legacy goal path redirects to goals list and opens create',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loadLatestJourneyBoundaryProvider.overrideWithValue(_EmptyLoad()),
          confirmJourneyBoundaryProvider.overrideWithValue(_NoopConfirm()),
        ],
        child: const PrimeAtlasApp(),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.text('旅程').first);
    GoRouter.of(context).go(AppRoutePath.goal);
    await tester.pumpAndSettle();

    expect(find.text('目标列表'), findsOneWidget);
    await tester.tap(find.text('新建目标'));
    await tester.pumpAndSettle();
    expect(find.text('创建目标草案'), findsOneWidget);
  });

  testWidgets('goal detail is reachable from goals list after create',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loadLatestJourneyBoundaryProvider.overrideWithValue(_EmptyLoad()),
          confirmJourneyBoundaryProvider.overrideWithValue(_NoopConfirm()),
        ],
        child: const PrimeAtlasApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.text('旅程').first),
    );
    container.read(journeyControllerProvider.notifier).addGoal('完成十公里训练');

    final context = tester.element(find.text('旅程').first);
    GoRouter.of(context).go(AppRoutePath.goals);
    await tester.pumpAndSettle();

    expect(find.text('完成十公里训练'), findsOneWidget);
    await tester.tap(find.text('完成十公里训练'));
    await tester.pumpAndSettle();
    expect(find.text('目标详情'), findsOneWidget);
    expect(find.text('保存目标'), findsOneWidget);
  });
}
