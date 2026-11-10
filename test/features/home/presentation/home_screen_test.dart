import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('a new install shows the month and the empty state', (tester) async {
    await pumpApp(tester);

    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('₹0'), findsOneWidget);
    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Add expense'), findsOneWidget);
  });

  appTest('two steps add a cash expense and Home updates', (tester) async {
    final haptics = FakeHaptics();
    await pumpApp(tester, haptics: haptics);

    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    await typeAmount(tester, '240');
    expect(find.text('₹240'), findsOneWidget);
    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();

    // Back on Home: total, top category and the recent row.
    expect(find.text('Spent this month'), findsOneWidget);
    expect(find.text('₹240'), findsNWidgets(3));
    expect(find.text('Top categories'), findsOneWidget);
    expect(find.text('Recent'), findsOneWidget);
    expect(haptics.events.last, 'commit');
  });

  appTest('a category tap with no amount saves nothing', (tester) async {
    final haptics = FakeHaptics();
    await pumpApp(tester, haptics: haptics);

    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();

    expect(find.text('Enter an amount'), findsOneWidget);
    expect(haptics.events, ['reject']);
  });

  appTest('rows are announced with amount, payee and category', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    await typeAmount(tester, '1234.5');
    await tester.tap(find.text('Fuel'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('₹1,234.50 spent this month'), findsOneWidget);
    expect(find.bySemanticsLabel('₹1,234.50 spent on Fuel'), findsOneWidget);
    expect(
      find.bySemanticsLabel('₹1,234.50 spent, Fuel, Fuel'),
      findsOneWidget,
    );
  });

  appTest('the previous month is empty and next returns', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
    // Cannot step past the current month.
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_right),
          )
          .onPressed,
      isNull,
    );
  });

  for (final brightness in Brightness.values) {
    appTest(
      'a small phone at 2x text in ${brightness.name} mode does not overflow',
      (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await pumpApp(tester, size: const Size(320, 640), textScale: 2);
        await tester.ensureVisible(find.text('Add expense'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add expense'));
        await tester.pumpAndSettle();
        await typeAmount(tester, '123456.78');
        await tester.ensureVisible(find.text('Bills & Utilities'));
        await tester.tap(find.text('Bills & Utilities'));
        await tester.pumpAndSettle();

        expect(find.text('₹1,23,456.78'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  }

  appTest('a tablet shows the side rail', (tester) async {
    await pumpApp(tester, size: const Size(900, 700));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
