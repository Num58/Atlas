import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/features/journey/journey_edit_pages.dart';
import 'package:primeatlas/app/features/journey/journey_page.dart';
import 'package:primeatlas/app/features/me/me_page.dart';
import 'package:primeatlas/app/navigation/app_shell.dart';

abstract final class AppRoutePath {
  static const journey = '/journey';
  static const direction = '/journey/direction';
  static const domain = '/journey/domain';
  static const goal = '/journey/goal';
  static const milestone = '/journey/milestone';
  static const me = '/me';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutePath.journey,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => AppRoutePath.journey,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.journey,
                builder: (context, state) => const JourneyPage(),
                routes: [
                  GoRoute(
                    path: 'direction',
                    builder: (context, state) => const DirectionPage(),
                  ),
                  GoRoute(
                    path: 'domain',
                    builder: (context, state) => const DomainPage(),
                  ),
                  GoRoute(
                    path: 'goal',
                    builder: (context, state) => const GoalPage(),
                  ),
                  GoRoute(
                    path: 'milestone',
                    builder: (context, state) => const MilestonePage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.me,
                builder: (context, state) => const MePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
