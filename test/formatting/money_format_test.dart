import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Indian grouping', () {
    expect(formatMoney(const Money(12345600)), '₹1,23,456');
    expect(formatMoney(const Money(1234567800)), '₹1,23,45,678');
    expect(formatMoney(const Money(99900)), '₹999');
    expect(formatMoney(Money.zero), '₹0');
  });

  test('paise are shown only when present', () {
    expect(formatMoney(const Money(12345678)), '₹1,23,456.78');
    expect(formatMoney(const Money(1205)), '₹12.05');
    expect(formatMoney(const Money(50)), '₹0.50');
    expect(formatMoney(const Money(24000), alwaysShowPaise: true), '₹240.00');
  });

  test('negative amounts', () {
    expect(formatMoney(const Money(-125050)), '-₹1,250.50');
  });

  test('typed amounts keep a trailing point and partial paise', () {
    expect(formatTypedAmount('', null), '₹0');
    expect(formatTypedAmount('123456', null), '₹1,23,456');
    expect(formatTypedAmount('12', ''), '₹12.');
    expect(formatTypedAmount('12', '5'), '₹12.5');
    expect(formatTypedAmount('', '05'), '₹0.05');
  });
}
