import 'dart:math';

import 'package:test/test.dart';
import 'package:txn_parser/txn_parser.dart';

/// Invariants that must hold for every input (spec §7.5): the parser never
/// throws; text with no currency token never yields an amount; amounts are
/// never zero or negative.
void main() {
  const parser = TxnParser();
  const alphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
      ' .,:;/-@*#()₹​\n\t';
  const words = [
    'Rs',
    'Rs.',
    'INR',
    '₹',
    'debited',
    'credited',
    'spent',
    'refund',
    'OTP',
    'A/c',
    'XX1234',
    'UPI',
    'Ref',
    'No',
    'to',
    'from',
    'at',
    'on',
    '10-11-26',
    '1,23,456.78',
    '0',
    '0.00',
    '99999999999',
    'card',
    'ATM',
    'failed',
    'reversed',
    'will be debited',
    'cashback up to',
    '@ybl',
  ];

  String randomText(Random random) {
    final buffer = StringBuffer();
    final length = random.nextInt(40);
    for (var i = 0; i < length; i++) {
      if (random.nextBool()) {
        buffer.write(words[random.nextInt(words.length)]);
      } else {
        buffer.write(alphabet[random.nextInt(alphabet.length)]);
      }
      if (random.nextInt(3) == 0) buffer.write(' ');
    }
    return buffer.toString();
  }

  test('never throws, and amounts are always positive', () {
    final random = Random(20261110);
    for (var i = 0; i < 20000; i++) {
      final text = randomText(random);
      final result = parser.parse(text, origin: 'AX-HDFCBK');
      switch (result) {
        case ParsedTransaction(:final fields):
          expect(fields.amountPaise, greaterThan(0), reason: text);
        case UnparsedMessage(:final amountPaise):
          if (amountPaise != null) {
            expect(amountPaise, greaterThan(0), reason: text);
          }
        case DroppedMessage():
        case NoAmount():
          break;
      }
    }
  });

  test('no currency token means no amount', () {
    final random = Random(7);
    for (var i = 0; i < 20000; i++) {
      final text = randomText(random)
          .replaceAll(RegExp('Rs|INR|₹', caseSensitive: false), '');
      final result = parser.parse(text);
      expect(result, isNot(isA<ParsedTransaction>()), reason: text);
      if (result case UnparsedMessage(:final amountPaise)) {
        expect(amountPaise, isNull, reason: text);
      }
    }
  });

  test('masking hides UPI ids, account and reference numbers', () {
    final masked = maskSensitive(
      'Rs.240.00 debited from A/c XX1234 to VPA swiggy@icici. '
      'UPI Ref No 631245678901. Call 18002586161',
    );
    expect(masked, contains('Rs.240.00'));
    expect(masked, contains('***@icici'));
    expect(masked, isNot(contains('1234')));
    expect(masked, isNot(contains('631245678901')));
    expect(masked, isNot(contains('swiggy')));
  });
}
