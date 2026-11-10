import 'package:expense_tracker/data/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

const _hdfcDebit =
    'Rs.240.00 debited from A/c XX1234 on 10-11-26 to VPA swiggy@icici. '
    'UPI Ref No 631245678901. Not you? Call 18002586161';

Future<void> _paste(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Add expense').first);
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Paste a payment message'));
  await tester.pumpAndSettle();
}

Future<int> _transactionCount(AppDatabase db) async =>
    (await db.select(db.transactions).get()).length;

void main() {
  appTest('pasting a debit SMS fills the form; a category saves it', (
    tester,
  ) async {
    final db = await pumpApp(tester, clipboard: FakeClipboard(_hdfcDebit));
    await _paste(tester);

    expect(find.text('₹240'), findsOneWidget);
    // Pasted text has no SMS sender, so the bank is unknown.
    expect(find.text('A/c ••1234'), findsOneWidget);
    expect(find.text('swiggy@icici'), findsOneWidget);
    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();

    expect(find.text("You've spent ₹240 this month."), findsOneWidget);
    final txn = await tester.runAsync(
      () => db.select(db.transactions).getSingle(),
    );
    expect(txn!.refNo, '631245678901');
    expect(txn.payeeDisplay, 'swiggy@icici');
  });

  appTest('an OTP creates nothing and says why', (tester) async {
    final db = await pumpApp(
      tester,
      clipboard: FakeClipboard(
        'OTP is 482913 for txn of INR 2,499.00 at AMAZON. Do not share.',
      ),
    );
    await _paste(tester);

    expect(
      find.text("That isn't a payment: it's a one-time password."),
      findsOneWidget,
    );
    expect(find.text('₹0'), findsOneWidget);
    expect(await tester.runAsync(() => _transactionCount(db)), 0);
  });

  appTest('a promotion creates nothing and says why', (tester) async {
    final db = await pumpApp(
      tester,
      clipboard: FakeClipboard(
        'Get cashback up to Rs 500 on bill payments! Offer valid till 30 Nov.',
      ),
    );
    await _paste(tester);

    expect(find.text("That isn't a payment: it's an offer."), findsOneWidget);
    expect(await tester.runAsync(() => _transactionCount(db)), 0);
  });

  appTest('an empty clipboard explains what to do', (tester) async {
    await pumpApp(tester, clipboard: FakeClipboard());
    await _paste(tester);

    expect(
      find.text('Copy a bank or UPI message first, then tap Paste.'),
      findsOneWidget,
    );
  });

  appTest('money received opens as money in with income categories', (
    tester,
  ) async {
    await pumpApp(
      tester,
      clipboard: FakeClipboard('Received ₹1,000 from Anita Sharma'),
    );
    await _paste(tester);

    expect(find.text('Add money in'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food & Dining'), findsNothing);
    await tester.tap(find.text('Salary'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('₹1,000 money in'), findsOneWidget);
  });

  appTest('an unreadable message is kept and can be added from Settings', (
    tester,
  ) async {
    await pumpApp(
      tester,
      clipboard: FakeClipboard('Txn alert: Rs 75 at KIRANA corner 10/11.'),
    );
    await _paste(tester);
    expect(
      find.text(
        "Couldn't read that message. It's saved under Unparsed messages in "
        'Settings.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await openTab(tester, 'Settings');
    expect(find.bySemanticsLabel('Unparsed messages, 1'), findsOneWidget);
    await tester.tap(find.text('Unparsed messages'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('KIRANA'));
    await tester.pumpAndSettle();
    expect(find.text('₹75'), findsOneWidget);
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing to sort out'), findsOneWidget);
  });

  appTest('pasting a payment already added says so', (tester) async {
    await pumpApp(tester, clipboard: FakeClipboard(_hdfcDebit));
    await _paste(tester);
    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();
    await _paste(tester);

    expect(find.text('That payment is already added.'), findsOneWidget);
    expect(find.text('₹0'), findsOneWidget);
  });
}
