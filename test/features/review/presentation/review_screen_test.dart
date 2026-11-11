import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

var _next = 0;

RawCapture _notification(String text, String origin) => RawCapture(
  id: 'n${++_next}',
  source: CaptureSource.androidNotification,
  origin: origin,
  text: text,
  receivedAt: DateTime.utc(2026, 11, 10, 8),
);

const _messages = 'com.google.android.apps.messaging';
const _phonepe = 'com.phonepe.app';

void main() {
  appTest('captured payments count on Home and wait in review', (tester) async {
    final queue = FakeCaptureQueue([
      _notification(
        'Rs.340.00 debited from A/c XX1234 to VPA swiggy@icici. '
        'UPI Ref No 631245678901.',
        _messages,
      ),
      _notification('Paid ₹62 to Sharma Dairy', _phonepe),
    ]);
    await pumpApp(tester, captureQueue: queue);

    expect(queue.acked, hasLength(2));
    expect(find.text("You've spent ₹402 this month."), findsOneWidget);
    expect(find.text('2 to review'), findsOneWidget);

    await tester.tap(find.text('2 to review'));
    await tester.pumpAndSettle();
    expect(find.text('Sharma Dairy'), findsOneWidget);
    expect(find.text('swiggy@icici'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Confirm as Food & Dining, suggested'),
      findsOneWidget,
    );
  });

  appTest('a category tap confirms; Undo puts it back', (tester) async {
    final queue = FakeCaptureQueue([
      _notification('Paid ₹62 to Sharma Dairy', _phonepe),
    ]);
    await pumpApp(tester, captureQueue: queue);
    await tester.tap(find.text('1 to review'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Confirm as Food & Dining'));
    await tester.pumpAndSettle();
    expect(find.text('All caught up'), findsOneWidget);
    expect(find.text('Confirmed as Food & Dining'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Sharma Dairy'), findsOneWidget);
  });

  appTest('confirm all confirms every suggested payment', (tester) async {
    final queue = FakeCaptureQueue([
      _notification('Paid ₹340 to Swiggy', _phonepe),
      _notification('Paid ₹120 to Uber India', _phonepe),
      _notification('Paid ₹62 to Sharma Dairy', _phonepe),
    ]);
    await pumpApp(tester, captureQueue: queue);
    await tester.tap(find.text('3 to review'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(FilledButton, 'Confirm all suggested (2)'),
    );
    await tester.pumpAndSettle();
    expect(find.text('2 payments confirmed'), findsOneWidget);
    expect(find.text('Sharma Dairy'), findsOneWidget);
    expect(find.text('Swiggy'), findsNothing);
  });

  appTest('marking a transfer takes it out of spending', (tester) async {
    final queue = FakeCaptureQueue([
      _notification('Paid ₹5,000 to Hisham Savings', _phonepe),
    ]);
    await pumpApp(tester, captureQueue: queue);
    expect(find.text("You've spent ₹5,000 this month."), findsOneWidget);
    await tester.tap(find.text('1 to review'));
    await tester.pumpAndSettle();

    await tester.tap(find.text("It's a transfer"));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text("You've spent ₹0 this month."), findsOneWidget);
    expect(find.text('1 to review'), findsNothing);
  });

  appTest('a wedding is offered, never forced; Undo takes it out', (
    tester,
  ) async {
    final queue = FakeCaptureQueue([
      _notification('Paid ₹62 to Sharma Dairy', _phonepe),
    ]);
    final db = await pumpApp(tester, captureQueue: queue);
    await db
        .into(db.rooms)
        .insert(
          RoomsCompanion.insert(
            id: 'wedding',
            name: 'Wedding',
            type: RoomType.wedding,
            autoTagMode: AutoTagMode.suggest,
            createdAt: 0,
          ),
        );
    await tester.tap(find.text('1 to review'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add to Wedding?'));
    await tester.pumpAndSettle();
    expect(find.text('In Wedding'), findsOneWidget);
    expect(find.text('Added to Wedding'), findsOneWidget);
    expect((await db.select(db.transactions).get()).single.roomId, 'wedding');

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await db.select(db.transactions).get()).single.roomId, isNull);
    expect(find.text('Add to Wedding?'), findsOneWidget);
  });
}
