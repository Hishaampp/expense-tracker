import 'dart:async';

import 'package:expense_tracker/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

Future<void> _addExpense(
  WidgetTester tester,
  String amount,
  String category,
) async {
  await tester.tap(find.text('Add expense').last);
  await tester.pumpAndSettle();
  await typeAmount(tester, amount);
  await tester.tap(find.text(category));
  await tester.pumpAndSettle();
}

void main() {
  appTest('keypad: paise, backspace and the hint', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();

    expect(find.text('Enter an amount'), findsOneWidget);
    await typeAmount(tester, '12.5');
    expect(find.text('₹12.5'), findsOneWidget);
    expect(find.text('Tap a category to save'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Backspace'));
    await tester.pump();
    expect(find.text('₹12.'), findsOneWidget);
  });

  appTest('editing changes the amount and category', (tester) async {
    await pumpApp(tester);
    await _addExpense(tester, '100', 'Food & Dining');

    await tester.tap(find.bySemanticsLabel(RegExp('₹100 spent, ')));
    await tester.pumpAndSettle();
    expect(find.text('Edit expense'), findsOneWidget);
    await typeAmount(tester, '0');
    await tester.tap(find.text('Groceries'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('₹1,000 spent this month'), findsOneWidget);
    expect(find.bySemanticsLabel('₹1,000 spent on Groceries'), findsOneWidget);
  });

  appTest('delete removes the expense and Undo restores it', (tester) async {
    await pumpApp(tester);
    await _addExpense(tester, '100', 'Food & Dining');

    await tester.tap(find.bySemanticsLabel(RegExp('₹100 spent, ')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No expenses yet'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('₹100 spent this month'), findsOneWidget);
  });

  appTest('a link to a missing expense offers a way back', (tester) async {
    await pumpApp(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.text('No expenses yet')),
    );
    unawaited(container.read(routerProvider).push('/transactions/nope'));
    await tester.pumpAndSettle();

    expect(find.text('This expense no longer exists.'), findsOneWidget);
    await tester.tap(find.text('Go back'));
    await tester.pumpAndSettle();
    expect(find.text('No expenses yet'), findsOneWidget);
  });

  appTest('an unknown link shows the not-found screen', (tester) async {
    await pumpApp(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.text('No expenses yet')),
    );
    container.read(routerProvider).go('/nowhere');
    await tester.pumpAndSettle();

    expect(find.text("This page doesn't exist"), findsOneWidget);
    await tester.tap(find.text('Go to Home'));
    await tester.pumpAndSettle();
    expect(find.text('No expenses yet'), findsOneWidget);
  });
}
