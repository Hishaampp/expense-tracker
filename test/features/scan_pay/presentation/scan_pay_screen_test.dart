import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/routing/app_router.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/services/upi_pay_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

const String _shop = 'upi://pay?pa=sharmastore@okicici&pn=Sharma%20Store';

Future<void> _open(WidgetTester tester, String qr) async {
  ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
      .read(routerProvider)
      .go(Routes.scanPay(qr));
  await tester.pumpAndSettle();
}

Future<void> _payShop(WidgetTester tester) async {
  await _open(tester, _shop);
  expect(find.text('Sharma Store'), findsOneWidget);
  expect(find.text('sharmastore@okicici'), findsOneWidget);
  await tester.enterText(find.byType(TextField), '250');
  await tester.tap(find.text('Food & Dining'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Pay ₹250'));
  await tester.pumpAndSettle();
}

void main() {
  appTest('Android success saves the payment with its reference', (
    tester,
  ) async {
    final upi = FakeUpiPayService()
      ..answer = (outcome: UpiOutcome.success, refNo: '432198765432');
    final db = await pumpApp(tester, upi: upi);
    await _payShop(tester);

    // The QR is handed over as scanned; the amount is typed there too.
    expect(upi.paid.single.toString(), _shop);
    final txn = (await db.select(db.transactions).get()).single;
    expect(txn.amountPaise, 25000);
    expect(txn.payeeDisplay, 'Sharma Store');
    expect(txn.payeeKey, 'sharmastore@okicici');
    expect(txn.categoryId, 'cat_food');
    expect(txn.refNo, '432198765432');
    expect(txn.reviewStatus, ReviewStatus.confirmed);
    expect(find.text('₹250 to Sharma Store saved'), findsOneWidget);
  });

  appTest('a failed payment saves nothing', (tester) async {
    final upi = FakeUpiPayService()
      ..answer = (outcome: UpiOutcome.failure, refNo: null);
    final db = await pumpApp(tester, upi: upi);
    await _payShop(tester);
    expect(find.text('Payment failed. Nothing was saved.'), findsOneWidget);
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  appTest('a pending payment waits in Review', (tester) async {
    final upi = FakeUpiPayService()
      ..answer = (outcome: UpiOutcome.pending, refNo: 'R1');
    final db = await pumpApp(tester, upi: upi);
    await _payShop(tester);
    final txn = (await db.select(db.transactions).get()).single;
    expect(txn.reviewStatus, ReviewStatus.needsReview);
  });

  group('with no answer (iPhone)', () {
    appTest('"Yes" saves it', (tester) async {
      final db = await pumpApp(tester);
      await _payShop(tester);
      expect(find.text('Did the payment go through?'), findsOneWidget);
      expect(find.text('₹250 to Sharma Store'), findsOneWidget);
      await tester.tap(find.text('Yes, it went through'));
      await tester.pumpAndSettle();
      final txn = (await db.select(db.transactions).get()).single;
      expect(txn.reviewStatus, ReviewStatus.confirmed);
    });

    appTest('"No" saves nothing', (tester) async {
      final db = await pumpApp(tester);
      await _payShop(tester);
      await tester.tap(find.text('No, it failed'));
      await tester.pumpAndSettle();
      expect(await db.select(db.transactions).get(), isEmpty);
    });

    appTest('a different amount is saved as paid', (tester) async {
      final db = await pumpApp(tester);
      await _payShop(tester);
      await tester.tap(find.text('It was a different amount'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '300');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final txn = (await db.select(db.transactions).get()).single;
      expect(txn.amountPaise, 30000);
    });

    appTest('no answer keeps it in Review', (tester) async {
      final db = await pumpApp(tester);
      await _payShop(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      final txn = (await db.select(db.transactions).get()).single;
      expect(txn.reviewStatus, ReviewStatus.needsReview);
    });
  });

  appTest('a billing QR keeps its amount and is paid as scanned', (
    tester,
  ) async {
    const qr = 'upi://pay?pa=shop@hdfcbank&pn=Shop&am=499.00&tr=ORD1&sign=abc';
    final upi = FakeUpiPayService()
      ..answer = (outcome: UpiOutcome.success, refNo: null);
    await pumpApp(tester, upi: upi);
    await _open(tester, qr);
    expect(find.text('This QR sets the amount.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Pay ₹499'));
    await tester.pumpAndSettle();
    expect(upi.paid.single.toString(), qr);
  });

  appTest('with several UPI apps, the payer chooses one', (tester) async {
    final upi = FakeUpiPayService()
      ..installed = const [
        (id: 'gpay', name: 'Google Pay'),
        (id: 'phonepe', name: 'PhonePe'),
      ]
      ..answer = (outcome: UpiOutcome.success, refNo: null);
    final db = await pumpApp(tester, upi: upi);
    await _open(tester, _shop);
    await tester.enterText(find.byType(TextField), '80');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Pay ₹80'));
    await tester.pumpAndSettle();
    expect(find.text('Pay with'), findsOneWidget);
    await tester.tap(find.text('PhonePe'));
    await tester.pumpAndSettle();
    expect(await db.select(db.transactions).get(), hasLength(1));
  });

  appTest('no UPI app says so and offers no Pay button', (tester) async {
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
