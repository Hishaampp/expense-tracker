import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/upi_qr.dart';
import 'package:test/test.dart';

void main() {
  test('a shop QR gives the UPI id and name, with no amount', () {
    final r = UpiRequest.tryParse(
      'upi://pay?pa=SharmaStore@okicici&pn=Sharma%20Store&cu=INR',
    )!;
    expect(r.payeeVpa, 'sharmastore@okicici');
    expect(r.payeeName, 'Sharma Store');
    expect(r.amount, isNull);
    expect(r.isFixed, isFalse);
  });

  test('the payment link is the QR exactly as scanned', () {
    // A shop QR's merchant details must reach the UPI app untouched, or
    // it refuses the payment under its risk policy.
    const text =
        'upi://pay?pa=paytm.s2fr2ln@pty&pn=Green%20And%20Protein'
        '&mc=5499&mode=02&orgid=000000&purpose=00';
    final r = UpiRequest.tryParse(text)!;
    expect(r.payUri.toString(), text);
    expect(r.payUri.queryParameters.containsKey('am'), isFalse);
  });

  test('a signed billing QR is passed on exactly as scanned', () {
    const text =
        'upi://pay?pa=shop@hdfcbank&pn=Shop&am=499.00&tr=ORD123&sign=abc';
    final r = UpiRequest.tryParse(text)!;
    expect(r.amount, const Money(49900));
    expect(r.isFixed, isTrue);
    expect(r.payUri.toString(), text);
  });

  test('a QR with no name shows the UPI id', () {
    expect(UpiRequest.tryParse('upi://pay?pa=abc@upi')!.displayName, 'abc@upi');
  });

  test('anything else is not paid', () {
    for (final text in [
      'https://example.com',
      'upi://collect?pa=a@ybl',
      'upi://pay?pn=NoId',
      'upi://pay?pa=not-an-id',
      'upi://pay?pa=a@ybl&cu=USD',
      'hello',
    ]) {
      expect(UpiRequest.tryParse(text), isNull, reason: text);
    }
  });

  test('a bad or zero amount is left for the payer to type', () {
    expect(UpiRequest.tryParse('upi://pay?pa=a@ybl&am=abc')!.amount, isNull);
    expect(UpiRequest.tryParse('upi://pay?pa=a@ybl&am=0')!.amount, isNull);
  });
}
