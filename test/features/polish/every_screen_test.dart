import 'package:expense_tracker/routing/app_router.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/seed.dart';

/// Accessibility target (spec §11.1 E): every screen works at the largest
/// text size and in dark mode. A layout overflow fails the test.
void main() {
  const screens = [
    Routes.home,
    Routes.activity,
    Routes.stats,
    Routes.rooms,
    Routes.settings,
    Routes.budgets,
    Routes.weeklyReview,
    Routes.notifications,
    Routes.payees,
    Routes.backup,
    Routes.account,
    Routes.review,
    Routes.unparsed,
    Routes.autoCapture,
    Routes.addExpense,
    Routes.newRoom,
    Routes.welcome,
  ];

  for (final brightness in Brightness.values) {
    for (final route in screens) {
      appTest('$route at 2× text, ${brightness.name}', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final db = await pumpApp(tester, textScale: 2);
        await seedExpense(
          db,
          DateTime(2026, 11, 9, 13),
          1240,
          payee: 'A shop with a rather long name',
        );
        await seedExpense(
          db,
          DateTime(2026, 11, 10, 9),
          75,
          payee: 'Swiggy',
          reviewStatus: 'needsReview',
          origin: 'auto',
        );
        await db.customInsert(
          "INSERT INTO budgets (id, amount_paise) VALUES ('month', 100000)",
          updates: {db.budgets},
        );
        await tester.pumpAndSettle();

        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        container.read(routerProvider).go(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
