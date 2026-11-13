import 'dart:async';

import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/routing/app_router.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

const String _shop = 'upi://pay?pa=sharmastore@okicici&pn=Sharma%20Store';

// Opened on top of Home, as the app does.
Future<void> _open(WidgetTester tester, String qr) async {
  unawaited(
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(routerProvider)
        .push(Routes.scanPay(qr)),
  );
  await tester.pumpAndSettle();
}

/// Scans the shop, types 250 for Food and taps Record & pay.
Future<void> _recordShop(WidgetTester tester) async {
  await _open(tester, _shop);
  expect(find.text('Sharma Store'), findsOneWidget);
  expect(find.text('sharmastore@okicici'), findsOneWidget);
  await tester.enterText(find.byType(TextField), '250');
  await tester.tap(find.text('Food & Dining'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Record ₹250 & pay'));
  await tester.pumpAndSettle();
}

void main() {
  appTest('the payment is recorded, then the UPI app opens to pay there', (
    tester,
  ) async {
    final upi = FakeUpiPayService();
    final db = await pumpApp(tester, upi: upi);
    await _recordShop(tester);

    expect(upi.opened, ['gpay']);
    // Saved before the UPI app opened, waiting for the answer.
    final txn = (await db.select(db.transactions).get()).single;
    expect(txn.amountPaise, 25000);
    expect(txn.payeeDisplay, 'Sharma Store');
    expect(txn.payeeKey, 'sharmastore@okicici');
    expect(txn.categoryId, 'cat_food');
    expect(txn.reviewStatus, ReviewStatus.needsReview);
    expect(find.text('Did the payment go through?'), findsOneWidget);
    expect(find.text('₹250 to Sharma Store'), findsOneWidget);
  });

  appTest('"Yes" confirms it', (tester) async {
    final db = await pumpApp(tester);
    await _recordShop(tester);
    await tester.tap(find.text('Yes, it went through'));
    await tester.pumpAndSettle();
    final txn = (await db.select(db.transactions).get()).single;
    expect(txn.reviewStatus, ReviewStatus.confirmed);
    expect(find.text('₹250 to Sharma Store saved'), findsOneWidget);
  });

  appTest('"No" removes it', (tester) async {
    final db = await pumpApp(tester);
    await _recordShop(tester);
    await tester.tap(find.text('No, it failed'));
    await tester.pumpAndSettle();
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(
      find.text('Payment not made, so nothing was recorded.'),
      findsOneWidget,
    );
  });

  appTest('a different amount is recorded as paid', (tester) async {
    final db = await pumpApp(tester);
    await _recordShop(tester);
    await tester.tap(find.text('It was a different amount'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '300');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final txn = (await db.select(db.transactions).get()).single;
    expect(txn.amountPaise, 30000);
    expect(txn.reviewStatus, ReviewStatus.confirmed);
  });

  appTest('no answer keeps it in Review', (tester) async {
    final db = await pumpApp(tester);
    await _recordShop(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    final txn = (await db.select(db.transactions).get()).single;
    expect(txn.reviewStatus, ReviewStatus.needsReview);
  });

  appTest('a UPI app that will not open records nothing', (tester) async {
    final upi = FakeUpiPayService()..opens = false;
    final db = await pumpApp(tester, upi: upi);
    await _recordShop(tester);
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(find.textContaining("couldn't be opened"), findsOneWidget);
  });

  appTest('a billing QR keeps its amount', (tester) async {
    const qr = 'upi://pay?pa=shop@hdfcbank&pn=Shop&am=499.00&tr=ORD1&sign=abc';
    final db = await pumpApp(tester);
    await _open(tester, qr);
    expect(find.text('This QR sets the amount.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Record ₹499 & pay'));
    await tester.pumpAndSettle();
    final txn = (await db.select(db.transactions).get()).single;
    expect(txn.amountPaise, 49900);
  });

  appTest('with several UPI apps, the payer chooses one', (tester) async {
    final upi = FakeUpiPayService()
      ..installed = const [
        (id: 'gpay', name: 'Google Pay'),
        (id: 'phonepe', name: 'PhonePe'),
      ];
    await pumpApp(tester, upi: upi);
    await _open(tester, _shop);
    await tester.enterText(find.byType(TextField), '80');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Record ₹80 & pay'));
    await tester.pumpAndSettle();
    expect(find.text('Pay with'), findsOneWidget);
    await tester.tap(find.text('PhonePe'));
    await tester.pumpAndSettle();
    expect(upi.opened, ['phonepe']);
  });

  appTest('no UPI app says so and offers no button', (tester) async {
    final upi = FakeUpiPayService()..installed = const [];
    await pumpApp(tester, upi: upi);
    await _open(tester, _shop);
    expect(find.textContaining('No UPI app found'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  appTest('a payee paid before keeps its category', (tester) async {
    final db = await pumpApp(tester);
    await db.customStatement(
      'INSERT INTO payee_rules (payee_key, category_id, updated_at) '
      "VALUES ('sharmastore@okicici', 'cat_groceries', 0)",
    );
    await _open(tester, _shop);
    expect(
      tester.getSemantics(find.text('Groceries')),
      matchesSemantics(
        isSelected: true,
        isButton: true,
        hasTapAction: true,
        label: 'Groceries',
        hasSelectedState: true,
      ),
    );
  });
}
