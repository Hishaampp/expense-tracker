import 'package:expense_tracker/core/money.dart';

/// Most digits a whole-rupee budget may have (₹99,99,99,999).
const int maxBudgetDigits = 9;

/// Parses a whole-rupee budget; null when empty, zero or not a number.
Money? parseBudget(String text) {
  final rupees = int.tryParse(text.trim());
  if (rupees == null || rupees <= 0) return null;
  return Money(rupees * Currency.inr.minorPerMajor);
}
