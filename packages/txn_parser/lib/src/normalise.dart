/// Cleans [text] so the rules below can match it: zero-width characters
/// removed, Indian-script and full-width digits turned into ASCII, every
/// rupee spelling (`Rs`, `Rs.`, `INR`, `₹`) turned into `₹`, and runs of
/// whitespace collapsed. The original text is kept by the caller.
String normalise(String text) {
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    if (_zeroWidth.contains(rune)) continue;
    buffer.write(_asciiDigit(rune) ?? String.fromCharCode(rune));
  }
  return buffer
      .toString()
      .replaceAllMapped(_rupee, (_) => '₹')
      .replaceAll(_spaces, ' ')
      .trim();
}

const Set<int> _zeroWidth = {0x200B, 0x200C, 0x200D, 0x2060, 0xFEFF, 0x00AD};

// Zero code point of each digit block that can appear in Indian SMS.
const List<int> _digitZeros = [
  0x0660, // Arabic-Indic
  0x06F0, // Extended Arabic-Indic
  0x0966, // Devanagari
  0x09E6, // Bengali
  0x0A66, // Gurmukhi
  0x0AE6, // Gujarati
  0x0B66, // Odia
  0x0BE6, // Tamil
  0x0C66, // Telugu
  0x0CE6, // Kannada
  0x0D66, // Malayalam
  0xFF10, // Full-width
];

String? _asciiDigit(int rune) {
  for (final zero in _digitZeros) {
    if (rune >= zero && rune <= zero + 9) {
      return String.fromCharCode(0x30 + rune - zero);
    }
  }
  return null;
}

// "Rs", "Rs.", "INR" or "₹", optionally followed by spaces, before a digit.
final RegExp _rupee = RegExp(
  r'(?:\bINR\b|\bRs\b\.?|₹)\s*(?=\d)',
  caseSensitive: false,
);

final RegExp _spaces = RegExp(r'[\s   ]+');
