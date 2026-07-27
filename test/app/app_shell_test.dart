import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/navigation/app_router.dart';
import 'package:primeatlas/app/primeatlas_app.dart';

void main() {
  testWidgets('registers only journey and me primary destinations',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PrimeAtlasApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('旅程'), findsWidgets);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('今日'), findsNothing);
    expect(find.text('训练'), findsNothing);
    expect(find.text('Pulse'), findsNothing);
    expect(find.text('知识'), findsNothing);
  });

  testWidgets('redirects the root path to journey', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PrimeAtlasApp()),
    );
    final context = tester.element(find.text('旅程').first);

    GoRouter.of(context).go('/');
    await tester.pumpAndSettle();

    expect(
      GoRouterState.of(tester.element(find.text('旅程').first)).uri.path,
      AppRoutePath.journey,
    );
    expect(find.text('先写下你想改善的方向'), findsOneWidget);
  });

  testWidgets('switches between journey and me while retaining app shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: PrimeAtlasApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('先写下你想改善的方向'), findsOneWidget);
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    expect(find.text('目标边界版本'), findsOneWidget);
    expect(find.textContaining('训练'), findsNothing);
    expect(find.textContaining('Pulse'), findsNothing);
    expect(find.textContaining('知识'), findsNothing);
    expect(find.textContaining('远程身份'), findsNothing);
    expect(find.textContaining('本机已保存'), findsNothing);
    expect(find.textContaining('已保存到本机'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
