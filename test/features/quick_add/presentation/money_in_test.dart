import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

/// Phase 10: Add records money in as well as spending.
void main() {
  appTest('Money in on Add saves income, and Home shows the balance', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await tester.tap(find.byTooltip('Add expense').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Money in'));
    await tester.pumpAndSettle();
    expect(find.text('Add money in'), findsOneWidget);
    // The categories are income ones now.
    expect(find.text('Food & Dining'), findsNothing);

    await typeAmount(tester, '60000');
    await tester.tap(find.text('Salary'));
    await tester.pumpAndSettle();

    final txn = (await db.select(db.transactions).get()).single;
    expect(txn.kind, TransactionKind.income);
    expect(txn.categoryId, 'cat_salary');
    expect(find.text('You have ₹60,000 left this month.'), findsOneWidget);
  });

  appTest('switching back to Spent brings the spending categories', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Add expense').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Money in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spent'));
    await tester.pumpAndSettle();
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
  });
}
