/// How long the original message text is kept after a payment is read
/// (spec §13). Amounts and payees stay either way; only the raw text goes.
enum RawTextRetention {
  /// Removed as soon as the payment is saved.
  never,

  /// Kept 30 days, for re-reading if the parser improves. The default.
  days30,

  /// Kept until the user deletes the payment.
  forever;

  /// [value] as stored, or the default when unknown.
  static RawTextRetention parse(String? value) => switch (value) {
    'never' => never,
    'forever' => forever,
    _ => days30,
  };

  /// The cutoff before which text is removed, seen from [nowUtc]; null to
  /// keep everything.
  DateTime? cutoff(DateTime nowUtc) => switch (this) {
    never => nowUtc.add(const Duration(minutes: 1)),
    days30 => nowUtc.subtract(const Duration(days: 30)),
    forever => null,
  };
}
