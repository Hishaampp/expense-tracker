import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:meta/meta.dart';

/// What a parsed message proposes, before the user picks a category.
@immutable
final class CaptureDraft {
  /// Creates the draft.
  const new({
    required this.capture,
    required this.kind,
    required this.amount,
    required this.instrument,
    required this.templateId,
    required this.confidence,
    this.occurredAt,
    this.bankCode,
    this.accountLast4,
    this.isCreditCard = false,
    this.payeeKey,
    this.payeeDisplay,
    this.refNo,
  });

  /// The capture it came from.
  final RawCapture capture;

  /// Expense, income or refund.
  final TransactionKind kind;

  /// The amount.
  final Money amount;

  /// When it happened (local time), or null to use when it was received.
  final DateTime? occurredAt;

  /// How it was paid.
  final Instrument instrument;

  /// Bank code, such as `HDFC`.
  final String? bankCode;

  /// Last digits of the account or card.
  final String? accountLast4;

  /// Whether the account is a credit card.
  final bool isCreditCard;

  /// Normalised payee id: the UPI id, or `name:` and the upper-cased name.
  final String? payeeKey;

  /// Payee as shown.
  final String? payeeDisplay;

  /// Reference number.
  final String? refNo;

  /// The parser template that read it.
  final String templateId;

  /// The parser's confidence, 0–1.
  final double confidence;

  /// The account name to show or create, such as "HDFC ••1234", or null
  /// when the message names no account (it then goes to Cash).
  String? get accountLabel {
    final last4 = accountLast4;
    if (last4 == null) return null;
    return '${bankCode ?? 'A/c'} ••$last4';
  }
}
