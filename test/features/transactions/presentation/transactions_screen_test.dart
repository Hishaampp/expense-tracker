import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('an empty month says so and offers to add', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing in November 2026'), findsOneWidget);
    expect(find.text('Add expense'), findsOneWidget);
  });

  appTest('expenses are grouped under their day with a day total', (
    tester,
  ) async {
    await pumpApp(tester);
    for (final (amount, category) in [('100', 'Fuel'), ('50', 'Groceries')]) {
      await tester.tap(find.text('Add expense').last);
      await tester.pumpAndSettle();
      await typeAmount(tester, amount);
      await tester.tap(find.text(category));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Tue, Nov 10'), findsOneWidget);
    expect(find.text('₹150 spent'), findsOneWidget);
    expect(find.text('Fuel'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
  });
}
