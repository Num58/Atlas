import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:primeatlas/app/design_system/app_icon.dart';

void main() {
  testWidgets('renders pinned Lucide SVG through the AppIcon boundary', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppIcon(
            icon: AppIconKey.target,
            semanticLabel: '目标',
            size: 24,
            color: Colors.blue,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.bySemanticsLabel('目标'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('rejects sizes outside the frozen set', () {
    expect(
      () => AppIcon(
        icon: AppIconKey.target,
        semanticLabel: '目标',
        size: 18,
      ),
      throwsAssertionError,
    );
  });
}
