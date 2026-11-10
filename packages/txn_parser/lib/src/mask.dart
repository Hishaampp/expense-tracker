/// Hides personal details in [text] before it is kept as an unparsed sample
/// or exported (spec §7.8): UPI ids, account and card numbers, reference
/// numbers and phone numbers. Amounts and wording are kept, so the sample
/// still shows the message's format.
String maskSensitive(String text) {
  return text
      // UPI ids: keep the handle, hide the name.
      .replaceAllMapped(
        RegExp(
          r'[a-z0-9][a-z0-9._-]{1,}@([a-z][a-z0-9]{1,})(?!\w|\.\w)',
          caseSensitive: false,
        ),
        (m) => '***@${m.group(1)}',
      )
      // Masked account forms: XX1234, ****1234.
      .replaceAllMapped(
        RegExp(r'[xX*•]{2,}\d{2,6}\b'),
        (m) => 'X' * m.group(0)!.length,
      )
      // Any other run of 4+ digits that is not part of an amount.
      .replaceAllMapped(
        RegExp(r'(?<![₹\d,.])\d{4,}(?![\d,]*\.\d)(?!,\d)'),
        (m) => 'X' * m.group(0)!.length,
      );
}
