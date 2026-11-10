import 'package:txn_parser/src/amount.dart';
import 'package:txn_parser/src/parsed_fields.dart';

/// The transaction amount in [text] (normalised), skipping amounts that
/// are a balance, a limit or a promotional ceiling. Null when none.
int? extractAmount(String text) {
  for (final match in amountPattern.allMatches(text)) {
    final before = text
        .substring(match.start < 30 ? 0 : match.start - 30, match.start)
        .toLowerCase();
    if (_notTheAmount.hasMatch(before)) continue;
    final paise = parsePaise(match.group(1)!);
    if (paise != null) return paise;
  }
  return null;
}

/// The balance quoted in [text], if any.
int? extractBalance(String text) {
  for (final match in amountPattern.allMatches(text)) {
    final before = text
        .substring(match.start < 30 ? 0 : match.start - 30, match.start)
        .toLowerCase();
    if (_balanceBefore.hasMatch(before)) return parsePaise(match.group(1)!);
  }
  return null;
}

/// Whether [text] contains any rupee amount at all.
bool hasAnyAmount(String text) => amountPattern.hasMatch(text);

// Words just before an amount that make it something other than the
// transaction amount.
final RegExp _notTheAmount = RegExp(
  '(?:bal(?:ance)?|limit|lmt|up ?to|upto|min(?:imum)?|total due|due)'
  r'[\s:.]*(?:is|of|:)?[\s:.]*$',
);

final RegExp _balanceBefore = RegExp(
  r'(?:avl|avbl|available|a/c|clr|closing)?\.? ?bal(?:ance)?[\s:.]*'
  r'(?:is|of|:)?[\s:.]*$',
);

/// How the payment was made, from keywords in [text].
ParsedInstrument extractInstrument(String text) {
  final t = text.toLowerCase();
  if (RegExp(r'\batm\b|cash withdrawal|withdrawn at').hasMatch(t)) {
    return ParsedInstrument.atm;
  }
  if (RegExp(r'\bupi\b|\bvpa\b|@[a-z]{2,}\b').hasMatch(t)) {
    return ParsedInstrument.upi;
  }
  if (RegExp(r'\bimps\b').hasMatch(t)) return ParsedInstrument.imps;
  if (RegExp(r'\bneft\b').hasMatch(t)) return ParsedInstrument.neft;
  if (RegExp(r'\brtgs\b').hasMatch(t)) return ParsedInstrument.rtgs;
  if (RegExp(r'\bcard\b').hasMatch(t)) return ParsedInstrument.card;
  if (RegExp(r'net ?banking|\bnb\b').hasMatch(t)) {
    return ParsedInstrument.netbanking;
  }
  if (RegExp(r'\bwallet\b').hasMatch(t)) return ParsedInstrument.wallet;
  return ParsedInstrument.unknown;
}

/// Whether the account in [text] is a credit card.
bool mentionsCreditCard(String text) =>
    RegExp(r'credit card|\bcc\b', caseSensitive: false).hasMatch(text);

/// The last 3–4 digits of the user's account or card, from forms such as
/// `A/c XX1234`, `a/c no. XXXXXX1234`, `Card ending 4321`, `A/c *1234`.
String? extractAccountHint(String text) {
  final match = _account.firstMatch(text);
  if (match == null) return null;
  final digits = match.group(1)!;
  return digits.length > 4 ? digits.substring(digits.length - 4) : digits;
}

final RegExp _account = RegExp(
  r'(?:\ba/?c\b|\bacct\b|\baccount\b|\bcard\b)'
  r'(?:\s*(?:no\.?|number|num))?'
  r'(?:\s*(?:ending(?:\s*(?:with|in))?|ends with))?'
  r'\s*[:.\-]?\s*(?:[x*•]+|\.{2,3})?\s*(\d{3,6})\b',
  caseSensitive: false,
);

/// A UPI id in [text], lower-cased: `name@okhdfcbank`, `98xxxxxx@ybl`.
/// Email addresses (with a dot in the domain) are not UPI ids.
String? extractVpa(String text) {
  final match = RegExp(
    r'([a-z0-9][a-z0-9._-]{1,}@[a-z][a-z0-9]{1,})(?!\w|\.\w)',
    caseSensitive: false,
  ).firstMatch(text);
  return match?.group(1)?.toLowerCase();
}

/// The other side's name or merchant: what follows "to", "at", "from" or
/// "paid to", up to the next keyword or punctuation.
String? extractPayeeName(String text, Direction direction) {
  final lead = direction == Direction.debit
      ? '(?:paid to|sent to|transferred to|trf to|towards|to|at|for)'
      : '(?:received from|transferred from|from|by)';
  final match = RegExp(
    "\\b$lead\\s+(?:vpa\\s+)?([A-Za-z0-9&'][A-Za-z0-9&'.@_\\- ]{1,40}?)"
    r'(?=\s+(?:on|via|ref|refno|rrn|utr|txn|upi|using|thru|through|at|avl|avbl|is|was|in|'
    r'from|to|for|info|dated|with|and|not|-)\b|[.,;:(]|\s*$)',
    caseSensitive: false,
  );
  for (final m in match.allMatches(text)) {
    final name = m.group(1)!.trim();
    if (_notAName.hasMatch(name)) continue;
    if (name.contains('@')) return null; // it is a UPI id, kept as the VPA
    return name;
  }
  return null;
}

final RegExp _notAName = RegExp(
  r'^(?:your|you|a/?c|ac|acct|account|card|xx|\d|₹|beneficiary|bank|'
  'the|this|self|mobile|registered)',
  caseSensitive: false,
);

/// A reference number: `UPI Ref No 512345678901`, `Ref: 1234567`,
/// `RRN 123456789012`, `UTR XXXX`, `Txn ID 9876`.
String? extractRefNo(String text) {
  final match = RegExp(
    r'(?:upi\s*)?(?:\bref(?:erence)?\.?\s*(?:no\.?|number|id|#)?|'
    r'\brrn\b|\butr\b(?:\s*no\.?)?|\btxn\s*(?:id|no\.?|ref)|'
    r'\btransaction\s*(?:id|ref(?:erence)?)(?:\s*no\.?)?)'
    r'\s*[:\-#.]?\s*([A-Za-z0-9]{6,22})\b',
    caseSensitive: false,
  ).firstMatch(text);
  final ref = match?.group(1);
  if (ref == null) return null;
  // A reference has digits; "Ref No yourname" is not one.
  return RegExp(r'\d{4,}').hasMatch(ref) ? ref.toUpperCase() : null;
}

const Map<String, int> _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6, //
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

/// When the transaction happened, if [text] says. Day-first dates
/// (India): `10-11-26`, `10/11/2026`, `10Nov26`, `10-Nov-2026`,
/// `2026-11-10`, with an optional `14:05`, `14:05:09` or `2:05 PM`.
MessageDateTime? extractDateTime(String text) {
  int? year;
  int? month;
  int? day;
  final iso = RegExp(r'\b(20\d{2})-(\d{1,2})-(\d{1,2})\b').firstMatch(text);
  final numeric = RegExp(r'\b(\d{1,2})[-/.](\d{1,2})[-/.](\d{2}|\d{4})\b')
      .firstMatch(text);
  final named = RegExp(
    r'\b(\d{1,2})[-/ ]?([A-Za-z]{3})[a-z]*[-/ ,]*(\d{2}|\d{4})\b',
  ).firstMatch(text);
  if (iso != null) {
    year = int.parse(iso.group(1)!);
    month = int.parse(iso.group(2)!);
    day = int.parse(iso.group(3)!);
  } else if (numeric != null) {
    day = int.parse(numeric.group(1)!);
    month = int.parse(numeric.group(2)!);
    year = _fullYear(numeric.group(3)!);
  } else if (named != null) {
    month = _months[named.group(2)!.toLowerCase()];
    day = int.parse(named.group(1)!);
    year = _fullYear(named.group(3)!);
  }
  if (year == null || month == null || day == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > _daysIn(year, month)) {
    return null;
  }
  final time = RegExp(
    r'\b(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([ap]\.?m\.?)?',
    caseSensitive: false,
  ).firstMatch(text);
  var hour = 0;
  var minute = 0;
  var second = 0;
  var hasTime = false;
  if (time != null) {
    hour = int.parse(time.group(1)!);
    minute = int.parse(time.group(2)!);
    second = int.tryParse(time.group(3) ?? '') ?? 0;
    final meridiem = time.group(4)?.toLowerCase().replaceAll('.', '');
    if (meridiem == 'pm' && hour < 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;
    hasTime = hour < 24 && minute < 60 && second < 60;
    if (!hasTime) {
      hour = 0;
      minute = 0;
      second = 0;
    }
  }
  return (
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
    second: second,
    hasTime: hasTime,
  );
}

int _fullYear(String digits) {
  final value = int.parse(digits);
  return digits.length == 2 ? 2000 + value : value;
}

int _daysIn(int year, int month) {
  const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  final leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  return month == 2 && leap ? 29 : days[month - 1];
}
