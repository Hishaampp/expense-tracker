/// Matches a rupee amount in normalised text: `₹1,23,456.78`, `₹500`,
/// `₹0.5`. Group 1 is the number without the sign.
final RegExp amountPattern = RegExp(
  r'₹\s?(\d{1,3}(?:,\d{2,3})+(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)',
);

/// Converts the number part of an amount ("1,23,456.7") into paise without
/// any floating point. Returns null when it is not a valid amount or is 0.
int? parsePaise(String number) {
  final plain = number.replaceAll(',', '');
  final parts = plain.split('.');
  if (parts.length > 2 || parts.first.isEmpty) return null;
  final rupees = int.tryParse(parts.first);
  if (rupees == null) return null;
  var paise = 0;
  if (parts.length == 2) {
    final fraction = parts[1];
    if (fraction.isEmpty || fraction.length > 2) return null;
    paise = int.tryParse(fraction.padRight(2, '0')) ?? -1;
    if (paise < 0) return null;
  }
  final total = rupees * 100 + paise;
  return total > 0 ? total : null;
}
