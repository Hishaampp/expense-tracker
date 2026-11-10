import 'package:expense_tracker/core/money.dart';
import 'package:meta/meta.dart';

/// The amount being typed on the Quick Add keypad.
///
/// Holds the digits as typed so "12." and "12.5" display exactly, and never
/// goes through a `double`.
@immutable
final class KeypadAmount {
  const new _(this._whole, this._fraction);

  /// The keypad state that shows [money] (for editing a saved amount).
  factory fromMoney(Money money) {
    final whole = money.wholeRupees == 0 ? '' : '${money.wholeRupees}';
    if (money.paisePart == 0) return KeypadAmount._(whole, null);
    return KeypadAmount._(whole, money.paisePart.toString().padLeft(2, '0'));
  }

  /// Nothing typed yet.
  static const KeypadAmount empty = KeypadAmount._('', null);

  /// Largest number of rupee digits accepted (₹99,99,99,999).
  static const int maxWholeDigits = 9;

  final String _whole;
  final String? _fraction; // null = no decimal point typed

  /// Rupee digits typed, without leading zeros. Empty when none.
  String get wholeDigits => _whole;

  /// Paise digits typed (0–2 characters), or null if no point was typed.
  String? get fractionDigits => _fraction;

  /// Whether nothing has been typed.
  bool get isEmpty => _whole.isEmpty && _fraction == null;

  /// The typed amount in paise.
  Money get money {
    final rupees = _whole.isEmpty ? 0 : int.parse(_whole);
    final fraction = (_fraction ?? '').padRight(2, '0');
    final paise = fraction.isEmpty ? 0 : int.parse(fraction);
    return Money(rupees * Currency.inr.minorPerMajor + paise);
  }

  /// Whether the amount can be saved (greater than zero).
  bool get isValid => money.paise > 0;

  /// The amount after typing [digit] (0–9). Ignores input past the limits.
  KeypadAmount appendDigit(int digit) {
    assert(digit >= 0 && digit <= 9, 'digit must be 0-9');
    final fraction = _fraction;
    if (fraction != null) {
      if (fraction.length >= 2) return this;
      return KeypadAmount._(_whole, '$fraction$digit');
    }
    if (_whole.isEmpty && digit == 0) return this;
    if (_whole.length >= maxWholeDigits) return this;
    return KeypadAmount._('$_whole$digit', null);
  }

  /// The amount after typing the decimal point. Ignored if already typed.
  KeypadAmount appendPoint() {
    if (_fraction != null) return this;
    return KeypadAmount._(_whole, '');
  }

  /// The amount after pressing backspace.
  KeypadAmount backspace() {
    final fraction = _fraction;
    if (fraction != null) {
      if (fraction.isEmpty) return KeypadAmount._(_whole, null);
      return KeypadAmount._(_whole, fraction.substring(0, fraction.length - 1));
    }
    if (_whole.isEmpty) return this;
    return KeypadAmount._(_whole.substring(0, _whole.length - 1), null);
  }

  @override
  bool operator ==(Object other) =>
      other is KeypadAmount &&
      other._whole == _whole &&
      other._fraction == _fraction;

  @override
  int get hashCode => Object.hash(_whole, _fraction);
}
