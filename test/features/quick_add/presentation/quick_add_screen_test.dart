import 'dart:async';

import 'package:expense_tracker/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('keypad: paise, backspace and the hint', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Add expense'));
    await tester.pumpAndSettle();

    expect(find.text('Enter an amount'), findsOneWidget);
    await typeAmount(tester, '12.5');
    expect(find.text('₹12.5'), findsOneWidget);
    expect(find.text('Tap a category to save'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Backspace'));
    await tester.pumpAndSettle();
    expect(find.text('₹12.'), findsOneWidget);
  });

  appTest('More opens every category and a pick there saves', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Add expense'));
    await tester.pumpAndSettle();
    await typeAmount(tester, '75');

    expect(find.text('Gifts & Shagun'), findsNothing);
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Gifts & Shagun'));
    await tester.tap(find.text('Gifts & Shagun'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('₹75 spent on Gifts & Shagun'),
      findsOneWidget,
    );
  });

  appTest('the most-used category moves to the front', (tester) async {
    await pumpApp(tester);
    await addExpense(tester, '10', 'Groceries');
    await tester.tap(find.byTooltip('Add expense').first);
    await tester.pumpAndSettle();

    final groceries = tester.getTopLeft(find.text('Groceries'));
    final food = tester.getTopLeft(find.text('Food & Dining'));
    expect(groceries.dx, lessThan(food.dx));
  });

  appTest('editing changes the amount and category', (tester) async {
    await pumpApp(tester);
    await addExpense(tester, '100', 'Food & Dining');

    await bringIntoView(tester, find.bySemanticsLabel(RegExp('₹100 spent, ')));
    await tester.tap(find.bySemanticsLabel(RegExp('₹100 spent, ')));
    await tester.pumpAndSettle();
    expect(find.text('Edit expense'), findsOneWidget);
    await typeAmount(tester, '0');
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text("You've spent ₹1,000 this month."), findsOneWidget);
    expect(find.bySemanticsLabel('₹1,000 spent on Groceries'), findsOneWidget);
  });

  appTest('delete removes the expense and Undo restores it', (tester) async {
    await pumpApp(tester);
    await addExpense(tester, '100', 'Food & Dining');

    await bringIntoView(tester, find.bySemanticsLabel(RegExp('₹100 spent, ')));
    await tester.tap(find.bySemanticsLabel(RegExp('₹100 spent, ')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No expenses yet'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text("You've spent ₹100 this month."), findsOneWidget);
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

    expect(find.text("This page doesn't exist."), findsOneWidget);
    await tester.tap(find.text('Go to Home'));
    await tester.pumpAndSettle();
    expect(find.text('No expenses yet'), findsOneWidget);
  });
}
