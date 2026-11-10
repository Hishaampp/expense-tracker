import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

RawCapture _share(String id, String text) => RawCapture(
  id: id,
  source: CaptureSource.share,
  text: text,
  receivedAt: DateTime.utc(2026, 11, 10, 8),
);

const _debit =
    'Rs.240.00 debited from A/c XX1234 on 10-11-26 to VPA swiggy@icici. '
    'UPI Ref No 631245678901.';

void main() {
  appTest('a message shared before opening fills Quick Add', (tester) async {
    final queue = FakeCaptureQueue([_share('s1', _debit)]);
    await pumpApp(tester, captureQueue: queue);

    expect(find.text('Add expense'), findsWidgets);
    expect(find.text('₹240'), findsOneWidget);
    expect(find.text('swiggy@icici'), findsOneWidget);
    expect(queue.acked, ['s1']);

    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();
    expect(find.text("You've spent ₹240 this month."), findsOneWidget);
  });

  appTest('a message shared while the app is open fills Quick Add', (
    tester,
  ) async {
    final queue = FakeCaptureQueue();
    await pumpApp(tester, captureQueue: queue);
    expect(find.text('No expenses yet'), findsOneWidget);

    queue.arrive(_share('s2', 'Received ₹1,000 from Anita Sharma'));
    await tester.pumpAndSettle();

    expect(find.text('Add money in'), findsOneWidget);
    expect(find.text('₹1,000'), findsOneWidget);
  });

  appTest('a shared OTP says it is not a payment', (tester) async {
    final queue = FakeCaptureQueue([
      _share('s3', 'OTP is 482913 for txn of INR 2,499.00. Do not share.'),
    ]);
    await pumpApp(tester, captureQueue: queue);

    expect(
      find.text("That isn't a payment: it's a one-time password."),
      findsOneWidget,
    );
  });
}
