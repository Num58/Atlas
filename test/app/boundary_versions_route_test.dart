import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/bootstrap/persistence_providers.dart';
import 'package:primeatlas/app/navigation/app_router.dart';
import 'package:primeatlas/app/primeatlas_app.dart';
import 'package:primeatlas/application/journey/boundary_version_ports.dart';
import 'package:primeatlas/application/journey/confirm_journey_boundary.dart'
    as app;
import 'package:primeatlas/core/journey/journey_boundary.dart' as core;

class _EmptyLoad implements app.LoadLatestJourneyBoundary {
  @override
  Future<app.JourneyBoundarySnapshot?> call() async => null;
}

class _NoopConfirm implements app.ConfirmJourneyBoundary {
  @override
  Future<app.ConfirmJourneyBoundaryResult> call(
    app.ConfirmJourneyBoundaryCommand command,
  ) async {
    return const app.ConfirmJourneyBoundaryResult.success();
  }
}

class _FakeList implements ListBoundaryVersions {
  @override
  Future<List<core.BoundaryVersionSummary>> call() async {
    return const [
      core.BoundaryVersionSummary(
        versionId: 'v-active',
        ordinal: 2,
        lifecycle: 'active',
        kind: 'confirmed',
        direction: 'Improve planning',
        constraint: 'Evenings only',
        domainCode: 'cognition',
        goalTitle: 'Ship weekly planning',
        milestone: core.JourneyMilestoneInput(
          title: 'Four reviews',
          evidenceRule: 'notes',
          window: '28d',
        ),
        activatedAtUs: 2,
      ),
      core.BoundaryVersionSummary(
        versionId: 'v-old',
        ordinal: 1,
        lifecycle: 'superseded',
        kind: 'confirmed',
        direction: 'Earlier direction',
        constraint: 'Weekends',
        domainCode: 'body',
        goalTitle: 'Earlier goal',
        milestone: core.JourneyMilestoneInput(
          title: 'Two reviews',
          evidenceRule: 'logs',
          window: '14d',
        ),
        activatedAtUs: 1,
      ),
    ];
  }
}

void main() {
  testWidgets('boundary versions route shows history entries', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loadLatestJourneyBoundaryProvider.overrideWithValue(_EmptyLoad()),
          confirmJourneyBoundaryProvider.overrideWithValue(_NoopConfirm()),
          listBoundaryVersionsProvider.overrideWithValue(_FakeList()),
        ],
        child: const PrimeAtlasApp(),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.text('旅程').first);
    GoRouter.of(context).go(AppRoutePath.boundaryVersions);
    await tester.pumpAndSettle();

    expect(find.text('目标边界版本'), findsOneWidget);
    expect(find.textContaining('当前活跃'), findsOneWidget);
    expect(find.textContaining('历史'), findsOneWidget);
    expect(find.text('恢复为新版本'), findsOneWidget);
    expect(find.textContaining('云同步'), findsNothing);
  });
}
