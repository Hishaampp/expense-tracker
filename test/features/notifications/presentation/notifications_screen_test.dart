import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('alerts are kept in the inbox behind the bell on Home', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    expect(find.byTooltip('Notifications'), findsOneWidget);
    await db.customInsert(
      "INSERT INTO budgets (id, amount_paise) VALUES ('month', 10000)",
      updates: {db.budgets},
    );
    await addExpense(tester, '90', 'Fuel');

    expect(find.byTooltip('Notifications, 1 new'), findsOneWidget);
    await tester.tap(find.byTooltip('Notifications, 1 new'));
    await tester.pumpAndSettle();
    expect(find.text('80% of your monthly budget used'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);

    // Opening the inbox marks it seen; the bell goes quiet.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Notifications'), findsOneWidget);
  });

  appTest('a notice opens its screen', (tester) async {
    final db = await pumpApp(tester);
    await db.customInsert(
      "INSERT INTO budgets (id, amount_paise) VALUES ('month', 10000)",
      updates: {db.budgets},
    );
    await addExpense(tester, '120', 'Fuel');
    await tester.tap(find.byTooltip('Notifications, 1 new'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Monthly budget used up'));
    await tester.pumpAndSettle();
    expect(find.text('Monthly budget'), findsOneWidget);
  });

  appTest('the Sunday review is kept when the app next opens', (tester) async {
    final db = await pumpApp(tester);
    // Scheduled since 1 November: the review of Sunday 8 November is due.
    final since = DateTime.utc(2026, 11).millisecondsSinceEpoch;
    await db.customInsert(
      "UPDATE settings SET value = ? WHERE key = 'weekly_review_since'",
      variables: [Variable<String>('$since')],
      updates: {db.settings},
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Notifications, 1 new'));
    await tester.pumpAndSettle();
    expect(find.text('Your week in money'), findsOneWidget);
    await tester.tap(find.text('Your week in money'));
    await tester.pumpAndSettle();
    expect(find.text('Your week'), findsWidgets);
  });

  appTest('an empty inbox says what will arrive', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('No notifications yet'), findsOneWidget);
  });
}
