import 'package:expense_tracker/core/dedup.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:test/test.dart';

final _t0 = DateTime.utc(2026, 11, 10, 9);

PaymentReport _report({
  int paise = 24000,
  TransactionKind kind = TransactionKind.expense,
  Duration after = Duration.zero,
  String source = 'android_notification:com.google.android.apps.messaging',
  String? account = '1234',
  String? ref,
  String? payeeKey,
  String? payeeName,
}) => PaymentReport(
  amount: Money(paise),
  kind: kind,
  occurredAt: _t0.add(after),
  sourceKey: source,
  accountLast4: account,
  refNo: ref,
  payeeKey: payeeKey,
  payeeName: payeeName,
);

KnownPayment _known(String id, PaymentReport r) =>
    (id: id, report: r, sourceKeys: {r.sourceKey});

const _gpay = 'android_notification:com.google.android.apps.nbu.paisa.user';

void main() {
  test('same reference number is the same payment', () {
    final saved = _known('a', _report(ref: '631245678901'));
    final incoming = _report(
      ref: '631245678901',
      source: _gpay,
      after: const Duration(hours: 3),
    );
    expect(findDuplicate(incoming, [saved]), 'a');
  });

  test('different reference numbers are never merged', () {
    final saved = _known('a', _report(ref: '111111111111'));
    expect(
      findDuplicate(_report(ref: '222222222222', source: _gpay), [saved]),
      isNull,
    );
  });

  test('bank SMS and UPI app notification of one payment merge', () {
    final sms = _known(
      'a',
      _report(payeeKey: 'swiggy@icici', ref: '631245678901'),
    );
    final gpay = _report(
      source: _gpay,
      account: null,
      payeeKey: 'name:SWIGGY',
      payeeName: 'Swiggy',
      after: const Duration(minutes: 1),
    );
    expect(findDuplicate(gpay, [sms]), 'a');
  });

  test('two equal payments from the same source stay two (two chais)', () {
    final first = _known(
      'a',
      _report(paise: 1500, source: _gpay, payeeName: 'Chai'),
    );
    final second = _report(
      paise: 1500,
      source: _gpay,
      payeeName: 'Chai',
      after: const Duration(minutes: 4),
    );
    expect(findDuplicate(second, [first]), isNull);
  });

  test('more than ten minutes apart is not a duplicate', () {
    final saved = _known('a', _report());
    expect(
      findDuplicate(
        _report(source: _gpay, after: const Duration(minutes: 11)),
        [saved],
      ),
      isNull,
    );
  });

  test('a different amount, kind or account is not a duplicate', () {
    final saved = _known('a', _report());
    expect(
      findDuplicate(_report(paise: 24001, source: _gpay), [saved]),
      isNull,
    );
    expect(
      findDuplicate(_report(kind: TransactionKind.income, source: _gpay), [
        saved,
      ]),
      isNull,
    );
    expect(
      findDuplicate(_report(account: '9999', source: _gpay), [saved]),
      isNull,
    );
  });

  test('different payees are not a duplicate', () {
    final saved = _known('a', _report(payeeName: 'Swiggy'));
    expect(
      findDuplicate(_report(source: _gpay, payeeName: 'Zomato'), [saved]),
      isNull,
    );
  });
}
