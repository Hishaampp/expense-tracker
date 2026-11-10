/// Works out which bank a message is from: first from its sender ID
/// (`AX-HDFCBK`, `VM-SBIINB-S`), then from the bank's name in the text.
/// Returns a short code such as `HDFC`, or null.
String? bankHintFor(String? origin, String normalised) {
  final header = _senderHeader(origin);
  if (header != null) {
    for (final (code, pattern) in _headerRules) {
      if (pattern.hasMatch(header)) return code;
    }
  }
  // A UPI id's handle ("swiggy@icici") names the payee's bank, not the
  // user's, so UPI ids are removed before looking for bank names.
  final withoutVpas = normalised.replaceAll(RegExp(r'\S+@\S+'), ' ');
  for (final (code, pattern) in _textRules) {
    if (pattern.hasMatch(withoutVpas)) return code;
  }
  return null;
}

// Indian commercial SMS headers: two letters, a hyphen, the header, and
// optionally a one-letter category suffix (-S, -T, -P, -G).
String? _senderHeader(String? origin) {
  if (origin == null) return null;
  final match = RegExp(r'^[A-Z]{2}-([A-Z0-9]{3,9})(?:-[A-Z])?$')
      .firstMatch(origin.trim().toUpperCase());
  return match?.group(1);
}

final List<(String, RegExp)> _headerRules = [
  ('HDFC', RegExp('HDFC')),
  ('SBI', RegExp('^SBI|SBIINB|SBIUPI|SBMSMS|ATMSBI|CBSSBI')),
  ('ICICI', RegExp('ICICI')),
  ('AXIS', RegExp('AXIS')),
  ('KOTAK', RegExp('KOTAK')),
  ('PNB', RegExp('^PNB|PUNBN')),
  ('BOB', RegExp('^BOB|BARODA')),
  ('CANARA', RegExp('CANBNK|CANARA')),
  ('UNION', RegExp('UNIONB|^UBI')),
  ('IDFC', RegExp('IDFC')),
];

final List<(String, RegExp)> _textRules = [
  ('HDFC', RegExp(r'\bHDFC\b', caseSensitive: false)),
  ('SBI', RegExp(r'\bSBI\b|State Bank of India', caseSensitive: false)),
  ('ICICI', RegExp(r'\bICICI\b', caseSensitive: false)),
  ('AXIS', RegExp(r'\bAxis Bank\b', caseSensitive: false)),
  ('KOTAK', RegExp(r'\bKotak\b', caseSensitive: false)),
  ('PNB', RegExp(r'\bPNB\b|Punjab National Bank', caseSensitive: false)),
  ('BOB', RegExp(r'Bank of Baroda|\bBoB\b', caseSensitive: false)),
  ('CANARA', RegExp(r'\bCanara Bank\b', caseSensitive: false)),
  ('UNION', RegExp(r'\bUnion Bank\b', caseSensitive: false)),
  ('IDFC', RegExp(r'\bIDFC\b', caseSensitive: false)),
];
