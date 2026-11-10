/// What kind of message a capture is (spec §7.2).
enum MessageClass {
  /// Money left the user's account.
  debit,

  /// Money entered the user's account.
  credit,

  /// A payment that did not go through.
  failed,

  /// A refund or the reversal of an earlier payment.
  reversalRefund,

  /// A one-time password.
  otp,

  /// Marketing that may mention an amount ("cashback up to ₹500").
  promo,

  /// A future debit: "will be debited", "autopay scheduled", "due on".
  upcomingOrMandate,

  /// Someone asking the user for money.
  collectRequest,

  /// A balance alert with no movement.
  balanceInfo,

  /// A credit card bill reminder.
  cardBillDue,

  /// A statement notice.
  statement,

  /// None of the above.
  unknown;

  /// Whether a message of this class becomes a transaction.
  bool get createsTransaction => switch (this) {
    MessageClass.debit ||
    MessageClass.credit ||
    MessageClass.reversalRefund => true,
    MessageClass.failed ||
    MessageClass.otp ||
    MessageClass.promo ||
    MessageClass.upcomingOrMandate ||
    MessageClass.collectRequest ||
    MessageClass.balanceInfo ||
    MessageClass.cardBillDue ||
    MessageClass.statement ||
    MessageClass.unknown => false,
  };
}
