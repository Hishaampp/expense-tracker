import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/seed.dart';

void main() {
  appTest('Stats starts empty and says how to fill it', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Stats');

    expect(find.text('Nothing to chart yet'), findsOneWidget);
  });

  appTest('Stats charts the month by category, by day and by month', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await seedExpense(db, DateTime(2026, 11, 3, 13), 300);
    await seedExpense(db, DateTime(2026, 11, 3, 20), 100, category: 'cat_fuel');
    await seedExpense(db, DateTime(2026, 10, 15, 13), 1000);
    await openTab(tester, 'Stats');

    expect(find.text('Where it went'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Spending by category, ₹400 in all. The categories are listed below.',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Food & Dining: ₹300, 75% of spending'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Fuel: ₹100, 25% of spending'),
      findsOneWidget,
    );

    await bringIntoView(tester, find.text('Highest: ₹400 on Nov 3'));
    expect(find.text('Highest: ₹400 on Nov 3'), findsOneWidget);
    // ₹400 over 10 days so far.
    expect(find.text('Average ₹40 a day'), findsOneWidget);

    await bringIntoView(tester, find.text('Last 6 months'));
    // October ₹1,000 and November ₹400: the months that had spending.
    expect(find.text('Average ₹700 a month'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'October: ₹1,000\. November: ₹400$')),
      findsOneWidget,
    );
  });

  appTest('another month is one tap on the title away', (tester) async {
    final db = await pumpApp(tester);
    await seedExpense(db, DateTime(2026, 10, 15, 13), 1000);
    await openTab(tester, 'Stats');
    expect(find.text('Nothing to chart yet'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Change month, November'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('October').last);
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel('Food & Dining: ₹1,000, 100% of spending'),
      findsOneWidget,
    );
  });
}
