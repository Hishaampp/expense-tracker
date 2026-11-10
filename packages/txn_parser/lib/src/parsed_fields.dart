import 'package:meta/meta.dart';

/// Which way money moved, seen from the user's account.
enum Direction {
  /// Out of the account.
  debit,

  /// Into the account.
  credit,
}

/// How a payment was made.
enum ParsedInstrument {
  /// UPI.
  upi,

  /// Debit or credit card.
  card,

  /// Net banking.
  netbanking,

  /// IMPS.
  imps,

  /// NEFT.
  neft,

  /// RTGS.
  rtgs,

  /// ATM withdrawal.
  atm,

  /// Wallet balance.
  wallet,

  /// Not stated.
  unknown,
}

/// A date and time as written in a message, with no time zone. The app
/// reads it in the device's local time.
typedef MessageDateTime = ({
  int year,
  int month,
  int day,
  int hour,
  int minute,
  int second,
  bool hasTime,
});

/// Everything read out of one message.
@immutable
final class ParsedFields {
  /// Creates the fields.
  const new({
    required this.amountPaise,
    required this.direction,
    this.instrument = ParsedInstrument.unknown,
    this.bankHint,
    this.accountHint,
    this.isCreditCard = false,
    this.payeeVpa,
    this.payeeName,
    this.refNo,
    this.occurredAt,
    this.availableBalancePaise,
  });

  /// The amount, in paise; always greater than zero.
  final int amountPaise;

  /// Which way the money moved.
  final Direction direction;

  /// How it was paid.
  final ParsedInstrument instrument;

  /// Bank code, such as `HDFC`, from the sender or the text.
  final String? bankHint;

  /// Last digits of the account or card, such as `1234`.
  final String? accountHint;

  /// Whether the account is a credit card.
  final bool isCreditCard;

  /// The other side's UPI id, lower-cased.
  final String? payeeVpa;

  /// The other side's name or the merchant, as written.
  final String? payeeName;

  /// Bank or UPI reference number.
  final String? refNo;

  /// When it happened, if the message says.
  final MessageDateTime? occurredAt;

  /// The balance quoted after the transaction. Never used for totals.
  final int? availableBalancePaise;

  @override
  bool operator ==(Object other) =>
      other is ParsedFields &&
      other.amountPaise == amountPaise &&
      other.direction == direction &&
      other.instrument == instrument &&
      other.bankHint == bankHint &&
      other.accountHint == accountHint &&
      other.isCreditCard == isCreditCard &&
      other.payeeVpa == payeeVpa &&
      other.payeeName == payeeName &&
      other.refNo == refNo &&
      other.occurredAt == occurredAt &&
      other.availableBalancePaise == availableBalancePaise;

  @override
  int get hashCode => Object.hash(
    amountPaise,
    direction,
    instrument,
    bankHint,
    accountHint,
    isCreditCard,
    payeeVpa,
    payeeName,
    refNo,
    occurredAt,
    availableBalancePaise,
  );
}
