import 'package:expense_tracker/data/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

Future<void> _setMonthlyBudget(AppDatabase db, int rupees) => db.customInsert(
  "INSERT INTO budgets (id, amount_paise) VALUES ('month', ${rupees * 100})",
  updates: {db.budgets},
);

/// Lets the "Budget saved" message time out so it covers nothing.
Future<void> _waitOutSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Future<void> _typeBudget(WidgetTester tester, String rupees) async {
  await tester.enterText(find.byType(TextFormField), rupees);
  await tester.tap(find.widgetWithText(FilledButton, 'Save'));
  await tester.pumpAndSettle();
}

void main() {
  appTest('setting a budget turns Home into safe to spend', (tester) async {
    await pumpApp(tester);
    expect(find.text('Set a monthly budget'), findsOneWidget);

    await tester.tap(find.text('Set a monthly budget'));
    await tester.pumpAndSettle();
    expect(find.text('Budgets'), findsWidgets);
    await tester.tap(find.text('Set monthly budget'));
    await tester.pumpAndSettle();
    await _typeBudget(tester, '30000');
    expect(find.text('Budget saved'), findsOneWidget);
    expect(find.text('₹30,000 left of ₹30,000'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await _waitOutSnackBar(tester);
    // 10–30 November is 21 days: ₹30,000 ÷ 21, rounded down.
    expect(find.text('Safe to spend today'), findsOneWidget);
    expect(find.text('₹1,428.57'), findsOneWidget);
    expect(find.text('21 days left'), findsOneWidget);

    await addExpense(tester, '240', 'Food & Dining');
    expect(find.text('₹1,417.14'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Safe to spend today: ₹1,417\.14\. ₹29,760 left'),
      ),
      findsOneWidget,
    );
  });

  appTest('overspending says by how much, in words', (tester) async {
    final db = await pumpApp(tester);
    await _setMonthlyBudget(db, 100);
    await tester.pumpAndSettle();

    await addExpense(tester, '150', 'Fuel');
    expect(find.text('Over budget by ₹50'), findsOneWidget);
    expect(find.text('Spent ₹150 of ₹100 this month.'), findsOneWidget);
  });

  appTest('each budget alert fires once per threshold', (tester) async {
    final notifications = FakeNotifications();
    final db = await pumpApp(tester, notifications: notifications);
    await _setMonthlyBudget(db, 1000);
    await tester.pumpAndSettle();

    await addExpense(tester, '800', 'Fuel');
    expect(notifications.shown, ['alert:80% of your monthly budget used']);

    await addExpense(tester, '50', 'Fuel');
    expect(notifications.shown, hasLength(1));

    await addExpense(tester, '200', 'Fuel');
    expect(notifications.shown, [
      'alert:80% of your monthly budget used',
      'alert:Monthly budget used up',
    ]);

    await addExpense(tester, '10', 'Fuel');
    expect(notifications.shown, hasLength(2));
  });

  appTest('a budget set past its limit warns once, at 100%', (tester) async {
    final notifications = FakeNotifications();
    final db = await pumpApp(tester, notifications: notifications);
    await addExpense(tester, '500', 'Fuel');
    await _setMonthlyBudget(db, 400);
    await tester.pumpAndSettle();

    expect(notifications.shown, ['alert:Monthly budget used up']);
  });

  appTest('tapping an alert opens Budgets', (tester) async {
    final notifications = FakeNotifications();
    final db = await pumpApp(tester, notifications: notifications);
    await _setMonthlyBudget(db, 100);
    await addExpense(tester, '90', 'Fuel');

    notifications.tap('80% of your monthly budget used');
    await tester.pumpAndSettle();
    expect(find.text('Monthly budget'), findsOneWidget);
  });

  appTest('a category budget is added from Settings and shows progress', (
    tester,
  ) async {
    final notifications = FakeNotifications();
    await pumpApp(tester, notifications: notifications);
    await addExpense(tester, '300', 'Fuel');

    await openTab(tester, 'Settings');
    await tester.tap(find.bySemanticsLabel('Budgets, Not set'));
    await tester.pumpAndSettle();
    await bringIntoView(tester, find.text('Add category budget'));
    await tester.tap(find.text('Add category budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fuel').last);
    await tester.pumpAndSettle();
    expect(find.text('Fuel budget'), findsOneWidget);
    await _typeBudget(tester, '300');

    expect(
      find.bySemanticsLabel('Fuel: ₹300 spent of ₹300. Change'),
      findsOneWidget,
    );
    expect(notifications.shown, ['alert:Fuel budget used up']);
  });

  appTest('a refused permission is explained', (tester) async {
    final notifications = FakeNotifications()..allow = false;
    await pumpApp(tester, notifications: notifications);
    await tester.tap(find.text('Set a monthly budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set monthly budget'));
    await tester.pumpAndSettle();
    await _typeBudget(tester, '5000');

    await bringIntoView(tester, find.textContaining('Notifications are off'));
    expect(find.textContaining('Notifications are off'), findsOneWidget);
  });

  appTest('the weekly review is scheduled and can be turned off', (
    tester,
  ) async {
    final notifications = FakeNotifications();
    await pumpApp(tester, notifications: notifications);
    expect(notifications.weekly, 'on');

    await tester.tap(find.text('Set a monthly budget'));
    await tester.pumpAndSettle();
    await bringIntoView(tester, find.text('Sunday weekly review'));
    await tester.tap(find.text('Sunday weekly review'));
    await tester.pumpAndSettle();
    expect(notifications.weekly, 'off');
  });
}
