import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:meta/meta.dart';

/// One money movement. The only place an amount is stored (spec §5.1).
///
/// Named `MoneyTransaction` because `Transaction` clashes with the
/// database's own type.
@immutable
final class MoneyTransaction {
  /// Creates a transaction.
  const new({
    required this.id,
    required this.kind,
    required this.amount,
    required this.occurredAt,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    this.toAccountId,
    this.categoryId,
    this.roomId,
    this.payeeKey,
    this.payeeDisplay,
    this.instrument = Instrument.unknown,
    this.refNo,
    this.note,
    this.reviewStatus = ReviewStatus.confirmed,
    this.isHidden = false,
    this.linkedTransactionId,
    this.origin = TransactionOrigin.manual,
  });

  /// Longest note the user can type.
  static const int noteMaxLength = 120;

  /// Stable unique id.
  final String id;

  /// What kind of movement this is; gives [amount] its direction.
  final TransactionKind kind;

  /// The amount, always greater than zero.
  final Money amount;

  /// When the money moved, as a UTC instant.
  final DateTime occurredAt;

  /// The account the money left (or, for income, entered).
  final String accountId;

  /// For a transfer, the account the money entered.
  final String? toAccountId;

  /// What the money was for. Null means uncategorised.
  final String? categoryId;

  /// The Room this belongs to, if any.
  final String? roomId;

  /// Normalised id of who was paid (UPI id, merchant, card descriptor).
  final String? payeeKey;

  /// Who was paid, as shown to the user.
  final String? payeeDisplay;

  /// How the payment was made.
  final Instrument instrument;

  /// Bank or UPI reference number.
  final String? refNo;

  /// The user's note.
  final String? note;

  /// Whether the user has confirmed the details.
  final ReviewStatus reviewStatus;

  /// Hidden from lists by default (a failed payment and its reversal).
  final bool isHidden;

  /// For a refund, the expense it reverses.
  final String? linkedTransactionId;

  /// How the transaction entered the app.
  final TransactionOrigin origin;

  /// When the record was created, as a UTC instant.
  final DateTime createdAt;

  /// When the record was last changed, as a UTC instant.
  final DateTime updatedAt;

  /// A copy with the user-editable fields replaced.
  MoneyTransaction edited({
    required Money amount,
    required DateTime occurredAt,
    required String accountId,
    required String? categoryId,
    required String? note,
    required String? roomId,
    required DateTime updatedAt,
  }) {
    return MoneyTransaction(
      id: id,
      kind: kind,
      amount: amount,
      occurredAt: occurredAt,
      accountId: accountId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      toAccountId: toAccountId,
      categoryId: categoryId,
      roomId: roomId,
      payeeKey: payeeKey,
      payeeDisplay: payeeDisplay,
      instrument: instrument,
      refNo: refNo,
      note: note,
      reviewStatus: reviewStatus,
      isHidden: isHidden,
      linkedTransactionId: linkedTransactionId,
      origin: origin,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MoneyTransaction &&
      other.id == id &&
      other.kind == kind &&
      other.amount == amount &&
      other.occurredAt == occurredAt &&
      other.accountId == accountId &&
      other.toAccountId == toAccountId &&
      other.categoryId == categoryId &&
      other.roomId == roomId &&
      other.payeeKey == payeeKey &&
      other.payeeDisplay == payeeDisplay &&
      other.instrument == instrument &&
      other.refNo == refNo &&
      other.note == note &&
      other.reviewStatus == reviewStatus &&
      other.isHidden == isHidden &&
      other.linkedTransactionId == linkedTransactionId &&
      other.origin == origin &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    amount,
    occurredAt,
    accountId,
    toAccountId,
    categoryId,
    roomId,
    payeeKey,
    payeeDisplay,
    instrument,
    refNo,
    note,
    reviewStatus,
    isHidden,
    linkedTransactionId,
    origin,
    createdAt,
    updatedAt,
  );
}
