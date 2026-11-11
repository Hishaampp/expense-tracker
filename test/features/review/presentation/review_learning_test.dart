import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

var _next = 0;

RawCapture _paid(String text, {int hour = 8}) => RawCapture(
  id: 'l${++_next}',
  source: CaptureSource.androidNotification,
  origin: 'com.phonepe.app',
  text: text,
  receivedAt: DateTime.utc(2026, 11, 10, hour),
);

void main() {
  appTest('confirming learns the payee and clears its other payments', (
    tester,
  ) async {
    final queue = FakeCaptureQueue([
      _paid('Paid ₹62 to Sharma Dairy'),
      _paid('Paid ₹70 to Sharma Dairy', hour: 9),
      _paid('Paid ₹15 to Chai Point', hour: 7),
    ]);
    final db = await pumpApp(tester, captureQueue: queue);
    await tester.tap(find.text('3 to review'));
    await tester.pumpAndSettle();
    expect(
      find.text('Always use this category for Sharma Dairy'),
      findsWidgets,
    );

    await tester.tap(find.bySemanticsLabel('Confirm as Groceries').first);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Sharma Dairy will always go to Groceries. '
        '1 more payment from them confirmed too.',
      ),
      findsOneWidget,
    );
    expect(find.text('Sharma Dairy'), findsNothing);
    expect(find.text('Chai Point'), findsOneWidget);
    final rules = await db.select(db.payeeRules).get();
    expect(rules.single.categoryId, 'cat_groceries');

    // Undo puts both back and forgets the rule.
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Sharma Dairy'), findsNWidgets(2));
    expect(await db.select(db.payeeRules).get(), isEmpty);
  });

  appTest('unticking "Always use" confirms just this one', (tester) async {
    final queue = FakeCaptureQueue([
      _paid('Paid ₹62 to Sharma Dairy'),
      _paid('Paid ₹70 to Sharma Dairy', hour: 9),
    ]);
    final db = await pumpApp(tester, captureQueue: queue);
    await tester.tap(find.text('2 to review'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.text('Always use this category for Sharma Dairy').first,
    );
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Confirm as Groceries').first);
    await tester.pumpAndSettle();

    expect(find.text('Confirmed as Groceries'), findsOneWidget);
    expect(find.text('Sharma Dairy'), findsOneWidget);
    expect(await db.select(db.payeeRules).get(), isEmpty);
  });

  appTest('several payments are confirmed in one go', (tester) async {
    final queue = FakeCaptureQueue([
      _paid('Paid ₹62 to Sharma Dairy'),
      _paid('Paid ₹15 to Chai Point', hour: 9),
      _paid('Paid ₹99 to Book Shop', hour: 10),
    ]);
    await pumpApp(tester, captureQueue: queue);
    await tester.tap(find.text('3 to review'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Select payments'));
    await tester.pumpAndSettle();
    expect(find.text('Tap payments to select them'), findsOneWidget);
    await tester.tap(find.text('Sharma Dairy'));
    await tester.tap(find.text('Chai Point'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Choose category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food & Dining').last);
    await tester.pumpAndSettle();

    expect(find.text('2 payments confirmed as Food & Dining'), findsOneWidget);
    expect(find.text('Book Shop'), findsOneWidget);
    expect(find.text('Chai Point'), findsNothing);
  });
}
