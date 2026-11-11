import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/seed.dart';

void main() {
  appTest('the review compares last week and lists who was paid', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    // Tuesday 10 Nov: the review covers 2–8 Nov, against 26 Oct–1 Nov.
    await seedExpense(db, DateTime(2026, 11, 3, 13), 300, payee: 'Swiggy');
    await seedExpense(db, DateTime(2026, 11, 6, 20), 200, payee: 'Swiggy');
    await seedExpense(db, DateTime(2026, 10, 28, 9), 800);
    await openTab(tester, 'Stats');
    await bringIntoView(tester, find.text('Your week'));
    await tester.tap(find.text('Your week'));
    await tester.pumpAndSettle();

    expect(find.text('Nov 2 – Nov 8'), findsOneWidget);
    expect(find.text('You spent ₹500 this week.'), findsOneWidget);
    expect(find.text('₹300 less than last week'), findsOneWidget);
    expect(find.text('Last week: ₹800'), findsOneWidget);
    await bringIntoView(tester, find.text('Who you paid most'));
    expect(
      find.bySemanticsLabel('₹500 paid to Swiggy, 2 payments'),
      findsOneWidget,
    );
  });

  appTest('a watched category shows on Home with this week so far', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await seedExpense(db, DateTime(2026, 11, 4, 13), 300);
    await openTab(tester, 'Stats');
    await bringIntoView(tester, find.text('Your week'));
    await tester.tap(find.text('Your week'));
    await tester.pumpAndSettle();

    await bringIntoView(tester, find.text('One thing to watch next week'));
    await tester.tap(find.text('Food & Dining').last);
    await tester.pumpAndSettle();
    expect(find.text('Watching Food & Dining next week'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await openTab(tester, 'Home');
    // Let the snack bar time out so it covers no key.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await addExpense(tester, '240', 'Food & Dining');
    // Only this week (9–15 Nov) counts: the ₹300 on 4 Nov does not.
    expect(find.text('Watching Food & Dining: ₹240 this week'), findsOneWidget);
  });
}
