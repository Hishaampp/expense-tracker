import 'package:expense_tracker/core/money.dart';
import 'package:test/test.dart';

void main() {
  test('adds and subtracts in paise', () {
    expect(const Money(150) + const Money(275), const Money(425));
    expect(const Money(150) - const Money(275), const Money(-125));
  });

  test('splits into rupees and paise', () {
    const amount = Money(12345678);
    expect(amount.wholeRupees, 123456);
    expect(amount.paisePart, 78);
  });

  test('negative amounts keep a positive paise part', () {
    const amount = Money(-250);
    expect(amount.isNegative, isTrue);
    expect(amount.wholeRupees, -2);
    expect(amount.paisePart, 50);
  });

  test('unknown currency code is not parsed', () {
    expect(Currency.tryParse('INR'), Currency.inr);
    expect(Currency.tryParse('XYZ'), isNull);
  });
}
