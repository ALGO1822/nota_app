import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nota_app/core/theme/app_colors.dart';
import 'package:nota_app/core/widgets/widgets.dart';
import 'package:nota_app/main.dart';

void main() {
  testWidgets('Nota foundation smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NotaApp());

    expect(find.text('Nota'), findsOneWidget);
    expect(find.text('MILESTONE 1 ACTIVE'), findsOneWidget);
  });

  testWidgets('NotaBottomSheet renders with solid Paper background', (WidgetTester tester) async {
    await tester.pumpWidget(const NotaApp());

    // Tap the settings action button in the AppBar
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    // Verify sheet content is visible
    expect(find.text('Settings Preview'), findsOneWidget);

    // Verify NotaBottomSheet root Material has solid paper color
    final sheetFinder = find.byType(NotaBottomSheet);
    expect(sheetFinder, findsOneWidget);

    final Material material = tester.widgetList<Material>(
      find.descendant(of: sheetFinder, matching: find.byType(Material)),
    ).first;
    expect(material.color, AppColors.paper);

    // Close the sheet
    await tester.tap(find.text('Close Sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Settings Preview'), findsNothing);
  });
}
