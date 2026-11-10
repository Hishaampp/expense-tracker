import 'package:clock/clock.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/services/haptics.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

/// The "now" every app test runs at: Tuesday 10 November 2026, 2:30 pm.
final DateTime testNow = DateTime(2026, 11, 10, 14, 30);

/// Counts haptic events instead of vibrating.
final class FakeHaptics implements Haptics {
  /// Events fired so far, in order.
  final List<String> events = [];

  @override
  void commit() => events.add('commit');

  @override
  void reject() => events.add('reject');

  @override
  void select() => events.add('select');
}

/// A widget test of the whole app. After [body] it unmounts the app and
/// lets the database's stream-cleanup timers run, which the test binding
/// requires before it will pass.
void appTest(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    try {
      await body(tester);
    } finally {
      // Also on failure: a mounted app would leave the database's close
      // waiting on live queries, and the run would hang.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    }
  });
}

/// Pumps the whole app over a fresh in-memory database and a fixed clock.
/// Returns the database so a test can seed or inspect it.
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  FakeHaptics? haptics,
  Size? size,
  double textScale = 1,
}) async {
  final clock = Clock.fixed(testNow);
  final db = openTestDatabase(clock: clock);
  if (size != null) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        hapticsProvider.overrideWithValue(haptics ?? FakeHaptics()),
      ],
      child: const App(),
    ),
  );
  addTearDown(db.close);
  await tester.pumpAndSettle();
  return db;
}

/// Types [amount] on the Quick Add keypad, for example `240` or `12.5`.
Future<void> typeAmount(WidgetTester tester, String amount) async {
  for (final key in amount.split('')) {
    final button = find.widgetWithText(TextButton, key);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }
}
