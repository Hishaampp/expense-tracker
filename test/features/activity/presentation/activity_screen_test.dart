import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('an empty month says so and offers to add', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Activity');

    expect(find.text('Nothing in November'), findsOneWidget);
  });

  appTest('expenses are grouped under Today with a day total', (tester) async {
    await pumpApp(tester);
    await addExpense(tester, '100', 'Fuel');
    await addExpense(tester, '50', 'Groceries');
    await openTab(tester, 'Activity');

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('₹150 spent'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^₹100 spent, Fuel')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('^₹50 spent, Groceries')),
      findsOneWidget,
    );
  });

  appTest('See all on Home opens Activity', (tester) async {
    await pumpApp(tester);
    await addExpense(tester, '100', 'Fuel');
    await bringIntoView(tester, find.text('See all'));
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
  });
}
