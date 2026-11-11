import 'package:expense_tracker/services/cloud/cloud_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Next'));
  await tester.pumpAndSettle();
}

Future<void> _toPayday(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await _next(tester);
  }
  expect(find.text('Turn on auto-capture'), findsOneWidget);
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
  expect(find.text('When does your salary come in?'), findsOneWidget);
}

void main() {
  appTest('the welcome asks salary day and budget, then reaches Home', (
    tester,
  ) async {
    final db = await pumpApp(tester, onboarded: false);
    expect(find.text('Every payment, written down for you'), findsOneWidget);
    expect(find.text('Step 1 of 8'), findsOneWidget);
    await _toPayday(tester);

    await tester.tap(find.text('Day 25'));
    await tester.pumpAndSettle();
    await _next(tester);

    await tester.enterText(find.byType(TextField), '20000');
    await _next(tester);
    expect(
      find.text('Keep your data safe if you change phones'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pumpAndSettle();

    expect(find.text('Safe to spend today'), findsOneWidget);
    final settings = {
      for (final s in await db.select(db.settings).get()) s.key: s.value,
    };
    expect(settings['month_start_day'], '25');
    expect(settings.containsKey('onboarded'), isTrue);
    expect(await db.select(db.budgets).get(), hasLength(1));
  });

  appTest('another salary day comes from the day sheet', (tester) async {
    final db = await pumpApp(tester, onboarded: false);
    await _toPayday(tester);
    await tester.tap(find.text('Another day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('12').last);
    await tester.pumpAndSettle();
    expect(find.text('Day 12'), findsOneWidget);

    await _next(tester);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pumpAndSettle();
    final day = await (db.select(
      db.settings,
    )..where((s) => s.key.equals('month_start_day'))).getSingle();
    expect(day.value, '12');
    expect(await db.select(db.budgets).get(), isEmpty);
  });

  appTest('a typo in the budget stops on that step', (tester) async {
    await pumpApp(tester, onboarded: false);
    await _toPayday(tester);
    await _next(tester);
    await tester.enterText(find.byType(TextField), '0');
    await _next(tester);
    expect(find.text('Set a monthly budget'), findsOneWidget);
  });

  appTest('the sync step offers only the providers that are on', (
    tester,
  ) async {
    final auth = FakeCloudAuth()..enabled = {CloudProvider.google};
    await pumpApp(tester, onboarded: false, cloudAuth: auth);
    await _toPayday(tester);
    await _next(tester);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
    // Apple is offered on iPhone only.
    expect(find.text('Continue with Apple'), findsNothing);
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(auth.opened, CloudProvider.google);

    // The sign-in returns through the browser: the recovery code follows.
    auth.signInByLink('asha@example.com');
    await tester.pumpAndSettle();
    expect(find.text('Write down your recovery code'), findsOneWidget);
  });

  appTest('every step but the first can go back', (tester) async {
    await pumpApp(tester, onboarded: false);
    expect(find.byTooltip('Back'), findsNothing);
    await _next(tester);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 8'), findsOneWidget);
  });
}
