import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/seed.dart';

/// Phase 10: once income is recorded, Home leads with the balance.
void main() {
  appTest('salary this month: what is left, and how much of it is spent', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await seedIncome(db, DateTime(2026, 11, 1, 9), 60000);
    await seedExpense(db, DateTime(2026, 11, 3, 13), 42000);
    await tester.pumpAndSettle();

    expect(find.text('You have ₹18,000 left this month.'), findsOneWidget);
    expect(find.text('₹42,000 spent of ₹60,000'), findsOneWidget);
    expect(find.text('+ ₹60,000'), findsOneWidget);
    expect(find.text('Spent'), findsOneWidget);
  });

  appTest('what last month left carries into this one', (tester) async {
    final db = await pumpApp(tester);
    await seedIncome(db, DateTime(2026, 10, 1, 9), 50000);
    await seedExpense(db, DateTime(2026, 10, 12, 13), 30000);
    await seedExpense(db, DateTime(2026, 11, 4, 13), 5000);
    await tester.pumpAndSettle();

    expect(find.text('You have ₹15,000 left this month.'), findsOneWidget);
    expect(find.text('Carried over'), findsOneWidget);
    expect(find.text('₹20,000'), findsOneWidget);
    expect(find.text('₹5,000 spent of ₹20,000'), findsOneWidget);
  });

  appTest('spending tracked before the first income does not count', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await seedExpense(db, DateTime(2026, 9, 5, 13), 10000);
    await seedIncome(db, DateTime(2026, 10, 1, 9), 50000);
    await seedExpense(db, DateTime(2026, 10, 12, 13), 30000);
    await tester.pumpAndSettle();

    expect(find.text('You have ₹20,000 left this month.'), findsOneWidget);
  });

  appTest('spending more than came in says by how much', (tester) async {
    final db = await pumpApp(tester);
    await seedIncome(db, DateTime(2026, 11, 1, 9), 10000);
    await seedExpense(db, DateTime(2026, 11, 3, 13), 12000);
    await tester.pumpAndSettle();

    expect(
      find.text("You've spent ₹2,000 more than you had this month."),
      findsOneWidget,
    );
  });

  appTest('with no income at all, Home keeps the spending view', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await seedExpense(db, DateTime(2026, 11, 3, 13), 400);
    await tester.pumpAndSettle();

    expect(find.text("You've spent ₹400 this month."), findsOneWidget);
    expect(find.text('Carried over'), findsNothing);
  });
}
