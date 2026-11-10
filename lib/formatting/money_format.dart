import 'package:expense_tracker/core/money.dart';
import 'package:intl/intl.dart';

final NumberFormat _indianGrouping = NumberFormat('#,##,##0', 'en_IN');

/// Formats [money] with the rupee sign and Indian grouping, for example
/// `₹1,23,456` or `₹1,23,456.78`. Paise are shown only when not zero, or
/// always when [alwaysShowPaise] is set.
String formatMoney(Money money, {bool alwaysShowPaise = false}) {
  final rupees = _indianGrouping.format(money.wholeRupees.abs());
  final sign = money.isNegative ? '-' : '';
  if (money.paisePart == 0 && !alwaysShowPaise) return '$sign₹$rupees';
  final paise = money.paisePart.toString().padLeft(2, '0');
  return '$sign₹$rupees.$paise';
}

/// Formats money received with a leading plus, for example `+ ₹52,000`.
String formatMoneyIn(Money money) => '+ ${formatMoney(money)}';

/// Formats rupee digits typed on the keypad, keeping a trailing point and
/// partial paise exactly as typed (`₹1,234.` or `₹1,234.5`).
String formatTypedAmount(String wholeDigits, String? fractionDigits) {
  final whole = wholeDigits.isEmpty ? 0 : int.parse(wholeDigits);
  final rupees = _indianGrouping.format(whole);
  if (fractionDigits == null) return '₹$rupees';
  return '₹$rupees.$fractionDigits';
}
