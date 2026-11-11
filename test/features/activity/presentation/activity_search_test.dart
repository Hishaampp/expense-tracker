import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/seed.dart';

void main() {
  appTest('search finds payments by payee across months', (tester) async {
    final db = await pumpApp(tester);
    await seedExpense(db, DateTime(2026, 11, 3, 13), 300, payee: 'Swiggy');
    await seedExpense(db, DateTime(2026, 9, 20, 13), 450, payee: 'Swiggy');
    await seedExpense(db, DateTime(2026, 11, 4, 13), 90, payee: 'Chai Point');
    await openTab(tester, 'Activity');

    await tester.enterText(find.byType(TextField), 'swig');
    await tester.pumpAndSettle();
    expect(
      find.text('2 results · Searching the last 12 months'),
      findsOneWidget,
    );
    expect(find.text('Chai Point'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    // Back to November alone.
    expect(find.text('Chai Point'), findsOneWidget);
  });

  appTest('a filter with no match says so and clears in one tap', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await seedExpense(db, DateTime(2026, 11, 3, 13), 300, payee: 'Swiggy');
    await openTab(tester, 'Activity');

    await tester.tap(find.bySemanticsLabel('Source: Any'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Captured'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing matches'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('Swiggy'), findsOneWidget);
  });
}
