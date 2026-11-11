import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('a new install shows the month, the hero and the empty state', (
    tester,
  ) async {
    await pumpApp(tester);

    // The large title is drawn twice (expanded and collapsed).
    expect(find.text('November'), findsWidgets);
    expect(find.text('Hi!'), findsOneWidget);
    expect(find.text("You've spent ₹0 this month."), findsOneWidget);
    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Add expense'), findsOneWidget);
  });

  appTest('two steps add a cash expense and Home updates', (tester) async {
    final haptics = FakeHaptics();
    await pumpApp(tester, haptics: haptics);

    await addExpense(tester, '240', 'Food & Dining');

    expect(find.text("You've spent ₹240 this month."), findsOneWidget);
    expect(find.text('Top categories'), findsOneWidget);
    // The budget card sits between the hero and the lists.
    await bringIntoView(tester, find.text('Recent'));
    expect(find.text('Recent'), findsOneWidget);
    expect(
      find.bySemanticsLabel('₹240 spent on Food & Dining'),
      findsOneWidget,
    );
    expect(haptics.events.last, 'commit');
  });

  appTest('a category tap with no amount saves nothing and says why', (
    tester,
  ) async {
    final haptics = FakeHaptics();
    await pumpApp(tester, haptics: haptics);

    await tester.tap(find.byTooltip('Add expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();

    expect(find.text('Enter an amount'), findsOneWidget);
    expect(find.text('Add expense'), findsWidgets);
    expect(haptics.events, ['reject']);
  });

  appTest('rows are announced with amount and meaning', (tester) async {
    await pumpApp(tester);
    await addExpense(tester, '1234.5', 'Fuel');

    expect(
      find.bySemanticsLabel("You've spent ₹1,234.50 this month."),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('₹1,234.50 spent on Fuel'), findsOneWidget);
    await bringIntoView(
      tester,
      find.bySemanticsLabel('₹1,234.50 spent, Fuel, Fuel'),
    );
    expect(
      find.bySemanticsLabel('₹1,234.50 spent, Fuel, Fuel'),
      findsOneWidget,
    );
  });

  appTest('the month picker switches to an earlier month', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Change month, November'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('October'));
    await tester.pumpAndSettle();

    expect(find.text('October'), findsWidgets);
    expect(find.text('You spent ₹0 in October.'), findsOneWidget);
    expect(find.text('Hi!'), findsNothing);
  });

  for (final brightness in Brightness.values) {
    appTest(
      'a small phone at 2x text in ${brightness.name} mode does not overflow',
      (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await pumpApp(tester, size: const Size(320, 640), textScale: 2);
        await addExpense(tester, '123456.78', 'Food & Dining');
        await openTab(tester, 'Activity');
        await openTab(tester, 'Settings');
        await openTab(tester, 'Rooms');

        expect(tester.takeException(), isNull);
      },
    );
  }

  appTest('a tablet shows the side rail', (tester) async {
    await pumpApp(tester, size: const Size(900, 700));
    expect(find.byType(NavigationRail), findsOneWidget);
  });

  appTest('with reduced motion everything still arrives', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);
    await addExpense(tester, '99', 'Groceries');

    expect(find.text("You've spent ₹99 this month."), findsOneWidget);
  });
}
