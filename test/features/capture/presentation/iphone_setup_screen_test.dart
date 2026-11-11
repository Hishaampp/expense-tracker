import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

Future<void> _openGuide(WidgetTester tester) async {
  await openTab(tester, 'Settings');
  await tester.tap(find.text('Auto-capture'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Set up auto-capture'));
  await tester.pumpAndSettle();
}

void main() {
  appTest('the guide walks through the automation and tests a message', (
    tester,
  ) async {
    await pumpApp(tester, captureControl: FakeCaptureControl(platform: 'ios'));
    await _openGuide(tester);

    expect(find.text('Open Shortcuts'), findsWidgets);
    expect(find.bySemanticsLabel('Step 1'), findsOneWidget);
    final field = find.byType(TextField);
    await bringIntoView(tester, field);
    await tester.enterText(
      field,
      'Rs.240.00 debited from A/c XX1234 to VPA swiggy@icici. '
      'UPI Ref No 631245678901.',
    );
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('Read as ₹240 spent, swiggy@icici'), findsOneWidget);

    await tester.enterText(field, 'OTP is 482913 for txn of INR 2,499.00.');
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "Not a payment, so it would be skipped: it's a one-time password.",
      ),
      findsOneWidget,
    );
  });

  appTest('finishing setup is remembered', (tester) async {
    await pumpApp(tester, captureControl: FakeCaptureControl(platform: 'ios'));
    await _openGuide(tester);
    final done = find.widgetWithText(FilledButton, "I've set it up");
    await bringIntoView(tester, done);
    await tester.tap(done);
    await tester.pumpAndSettle();

    expect(find.text('Auto-capture is set up'), findsOneWidget);
    expect(find.text('Set up'), findsOneWidget);
  });

  appTest('a message from the Shortcut is saved and waits for review', (
    tester,
  ) async {
    final queue = FakeCaptureQueue([
      RawCapture(
        id: 's1',
        source: CaptureSource.iosShortcut,
        text:
            'Rs.340.00 debited from A/c XX1234 to VPA swiggy@icici. '
            'UPI Ref No 631245678901.',
        receivedAt: DateTime.utc(2026, 11, 10, 8),
      ),
    ]);
    await pumpApp(tester, captureQueue: queue);

    expect(find.text("You've spent ₹340 this month."), findsOneWidget);
    expect(find.text('1 to review'), findsOneWidget);
    expect(queue.acked, ['s1']);
  });

  appTest('Home warns when nothing has arrived for five days', (tester) async {
    final db = await pumpApp(tester);
    final nineDaysAgo = testNow.toUtc().subtract(const Duration(days: 9));
    await tester.runAsync(
      () => db
          .into(db.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(
              key: 'ios_shortcut_setup_at',
              value: '${nineDaysAgo.millisecondsSinceEpoch}',
            ),
          ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Auto-capture may be off'), findsOneWidget);
    await tester.tap(find.text('Check setup'));
    await tester.pumpAndSettle();
    expect(find.text('Set up on iPhone'), findsWidgets);
  });
}
