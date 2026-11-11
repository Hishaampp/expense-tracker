import 'package:expense_tracker/routing/app_router.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/seed.dart';

Future<void> _open(WidgetTester tester) async {
  ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
      .read(routerProvider)
      .go(Routes.backup);
  await tester.pumpAndSettle();
}

Future<void> _password(
  WidgetTester tester,
  String pw, {
  bool twice = true,
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.first, pw);
  if (twice) await tester.enterText(fields.last, pw);
  await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
  await tester.pumpAndSettle();
}

void main() {
  appTest('a backup made on one phone restores on another', (tester) async {
    final share = FakeFileShare();
    final db = await pumpApp(tester, fileShare: share);
    await seedExpense(db, DateTime(2026, 11, 3, 13), 300, payee: 'Swiggy');
    await seedExpense(db, DateTime(2026, 11, 4, 13), 120, payee: 'Uber');
    await _open(tester);

    await tester.tap(find.text('Create backup'));
    await tester.pumpAndSettle();
    await _password(tester, 'short');
    expect(find.text('Use at least 8 characters'), findsOneWidget);
    await _password(tester, 'a good long password');
    expect(find.text('Backup created'), findsOneWidget);
    final file = share.shared.values.single;

    // Wipe this phone, then restore.
    await db.customStatement('DELETE FROM transactions');
    share.toPick = file;
    await tester.tap(find.text('Choose backup file'));
    await tester.pumpAndSettle();
    await _password(tester, 'a good long password', twice: false);
    expect(find.text('Replace all data?'), findsOneWidget);
    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();

    expect(find.text('Restored, with 2 payments'), findsOneWidget);
    expect(await db.select(db.transactions).get(), hasLength(2));
  });

  appTest('a wrong password restores nothing and says so', (tester) async {
    final share = FakeFileShare();
    final db = await pumpApp(tester, fileShare: share);
    await seedExpense(db, DateTime(2026, 11, 3, 13), 300);
    await _open(tester);
    await tester.tap(find.text('Create backup'));
    await tester.pumpAndSettle();
    await _password(tester, 'a good long password');

    share.toPick = share.shared.values.single;
    await tester.tap(find.text('Choose backup file'));
    await tester.pumpAndSettle();
    await _password(tester, 'not the password', twice: false);
    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    expect(
      find.text("That password doesn't open this backup."),
      findsOneWidget,
    );
  });

  appTest('CSV export shares a spreadsheet of payments', (tester) async {
    final share = FakeFileShare();
    final db = await pumpApp(tester, fileShare: share);
    await seedExpense(db, DateTime(2026, 11, 3, 13), 300, payee: 'Swiggy');
    await _open(tester);
    await bringIntoView(tester, find.text('Export CSV'));
    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();

    expect(find.text('CSV exported'), findsOneWidget);
    final csv = String.fromCharCodes(share.shared.values.single);
    expect(csv, startsWith('Date,Time,Type,Amount (INR)'));
    expect(csv, contains('2026-11-03,13:00,expense,300.00,Food & Dining'));
  });
}
