import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/widgets/choice_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('a payee is renamed and taught a category from Settings', (
    tester,
  ) async {
    final queue = FakeCaptureQueue([
      RawCapture(
        id: 'p1',
        source: CaptureSource.androidSms,
        origin: 'AX-HDFCBK',
        text:
            'Rs.62.00 debited from A/c XX1234 to VPA 9876543210@ybl. '
            'UPI Ref No 631245678902.',
        receivedAt: DateTime.utc(2026, 11, 10, 8),
      ),
    ]);
    final db = await pumpApp(tester, captureQueue: queue);
    await openTab(tester, 'Settings');
    await tester.tap(find.bySemanticsLabel('Payees and rules'));
    await tester.pumpAndSettle();
    expect(find.text('Payees & rules'), findsWidgets);

    await tester.tap(find.bySemanticsLabel(RegExp('No rule')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Milk man');
    await tester.tap(find.widgetWithText(ChoicePill, 'More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groceries').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Saved for Milk man'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('^Milk man. Always Groceries')),
      findsOneWidget,
    );
    final txn = (await db.select(db.transactions).get()).single;
    expect(txn.payeeDisplay, 'Milk man');
  });

  appTest('with no payments, the book says where payees come from', (
    tester,
  ) async {
    await pumpApp(tester);
    await openTab(tester, 'Settings');
    await tester.tap(find.bySemanticsLabel('Payees and rules'));
    await tester.pumpAndSettle();
    expect(find.text('No payees yet'), findsOneWidget);
  });
}
