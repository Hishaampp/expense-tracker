/// What kind of money movement a transaction is (spec §4).
enum TransactionKind {
  /// Money spent. Counts toward spending.
  expense,

  /// Money received. Shown as "Money in".
  income,

  /// Money moved between the user's own accounts. Not spending.
  transfer,

  /// Money returned for an earlier expense. Reduces spending.
  refund,
}

/// Whether the user has confirmed a transaction's details.
enum ReviewStatus {
  /// Entered or confirmed by the user.
  confirmed,

  /// Captured automatically and waiting in the review inbox.
  needsReview,
}

/// How a transaction entered the app.
enum TransactionOrigin {
  /// Typed in by the user.
  manual,

  /// Captured from a message or notification.
  auto,
}

/// How a payment was made.
enum Instrument {
  /// UPI.
  upi,

  /// Debit or credit card.
  card,

  /// Net banking.
  netbanking,

  /// IMPS transfer.
  imps,

  /// NEFT transfer.
  neft,

  /// RTGS transfer.
  rtgs,

  /// ATM withdrawal.
  atm,

  /// Wallet balance.
  wallet,

  /// Cash.
  cash,

  /// Not known.
  unknown,
}
