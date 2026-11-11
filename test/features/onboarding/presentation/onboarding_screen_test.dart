import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('the welcome walks through to Home and sets the budget', (
    tester,
  ) async {
    final db = await pumpApp(tester, onboarded: false);
    expect(find.text('Every payment, written down for you'), findsOneWidget);
    expect(find.text('Step 1 of 6'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Your money stays on your phone'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Turn on auto-capture'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '20000');
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pumpAndSettle();

    expect(find.text('Safe to spend today'), findsOneWidget);
    final settings = await db.select(db.settings).get();
    expect(settings.map((s) => s.key), contains('onboarded'));
  });

  appTest('every step but the first can go back', (tester) async {
    await pumpApp(tester, onboarded: false);
    expect(find.byTooltip('Back'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 6'), findsOneWidget);
  });
}
