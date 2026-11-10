import 'package:expense_tracker/core/models/appearance_mode.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('changing the month start day moves the month on Home', (
    tester,
  ) async {
    await pumpApp(tester);
    await openTab(tester, 'Settings');
    expect(find.text('Day 1'), findsOneWidget);

    await tester.tap(find.text('Month starts on'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Day 25'));
    await tester.pumpAndSettle();
    expect(find.text('Month now starts on day 25'), findsOneWidget);

    // 10 November is before the 25th: the month runs 25 Oct – 24 Nov.
    await openTab(tester, 'Home');
    // The large title is drawn twice (expanded and collapsed).
    expect(find.text('November'), findsWidgets);
    expect(find.text("You've spent ₹0 since Oct 25."), findsOneWidget);
  });

  appTest('dismissing the picker changes nothing', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Settings');
    await tester.tap(find.text('Month starts on'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Day 1'), findsOneWidget);
  });

  appTest('choosing Dark switches the app to dark and is saved', (
    tester,
  ) async {
    await pumpApp(tester);
    await openTab(tester, 'Settings');
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Dark'));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Appearance'));
    expect(Theme.of(context).brightness, Brightness.dark);
    final container = ProviderScope.containerOf(context);
    expect(
      await container.read(appearanceProvider.future),
      AppearanceMode.dark,
    );
  });
}
