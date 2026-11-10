import 'package:expense_tracker/core/keypad_amount.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:test/test.dart';

KeypadAmount _type(String keys) {
  var amount = KeypadAmount.empty;
  for (final key in keys.split('')) {
    amount = switch (key) {
      '.' => amount.appendPoint(),
      '<' => amount.backspace(),
      _ => amount.appendDigit(int.parse(key)),
    };
  }
  return amount;
}

void main() {
  test('whole rupees', () {
    expect(_type('240').money, const Money(24000));
  });

  test('rupees and paise', () {
    expect(_type('12.5').money, const Money(1250));
    expect(_type('12.05').money, const Money(1205));
    expect(_type('.5').money, const Money(50));
  });

  test('ignores a third paise digit and a second point', () {
    expect(_type('1.234').money, const Money(123));
    expect(_type('1.2.3').money, const Money(123));
  });

  test('ignores leading zeros', () {
    expect(_type('007').money, const Money(700));
  });

  test('stops at nine rupee digits', () {
    expect(_type('1234567890').money, const Money(12345678900));
  });

  test('backspace removes paise, then the point, then rupees', () {
    expect(_type('12.5<').fractionDigits, '');
    expect(_type('12.5<<').fractionDigits, isNull);
    expect(_type('12.5<<<').money, const Money(100));
    expect(_type('<').isEmpty, isTrue);
  });

  test('zero is not valid; any positive amount is', () {
    expect(KeypadAmount.empty.isValid, isFalse);
    expect(_type('0.00').isValid, isFalse);
    expect(_type('0.01').isValid, isTrue);
  });
}
