import 'package:expense_tracker/core/merchant_categories.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/capture_draft.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:meta/meta.dart';

/// How an automatically captured message is saved.
@immutable
final class CapturePlan {
  /// Creates the plan.
  const new({
    required this.kind,
    required this.reviewStatus,
    this.categoryId,
    this.toAccountId,
    this.isHidden = false,
  });

  /// Expense, income, transfer or refund.
  final TransactionKind kind;

  /// Whether it waits in the review inbox.
  final ReviewStatus reviewStatus;

  /// The category, confirmed or suggested.
  final String? categoryId;

  /// For a transfer, where the money went.
  final String? toAccountId;

  /// Hidden from lists (a failed payment's reversal).
  final bool isHidden;
}

/// Decides how [draft] is saved (spec §5.4–5.7, §8). Total; pure.
///
/// - An ATM withdrawal is a transfer from the bank to Cash: not spending.
/// - A credit card bill payment is a transfer: the purchases already
///   counted.
/// - A reversal of a failed payment is hidden: the payment never happened.
/// - Everything else waits in the review inbox, with a suggested category
///   where the payee is a known merchant (or "salary" is mentioned).
CapturePlan planCapture(CaptureDraft draft) {
  final text = draft.capture.text.toLowerCase();
  if (draft.kind == TransactionKind.expense &&
      draft.instrument == Instrument.atm) {
    return const CapturePlan(
      kind: TransactionKind.transfer,
      reviewStatus: ReviewStatus.confirmed,
      categoryId: transferCategoryId,
      toAccountId: Account.cashId,
    );
  }
  if (_cardBill.hasMatch(text)) {
    return const CapturePlan(
      kind: TransactionKind.transfer,
      reviewStatus: ReviewStatus.confirmed,
      categoryId: transferCategoryId,
    );
  }
  switch (draft.kind) {
    case TransactionKind.refund:
      return CapturePlan(
        kind: TransactionKind.refund,
        reviewStatus: ReviewStatus.needsReview,
        isHidden: _failed.hasMatch(text),
      );
    case TransactionKind.income:
      return CapturePlan(
        kind: TransactionKind.income,
        reviewStatus: ReviewStatus.needsReview,
        categoryId: _salary.hasMatch(text) ? salaryCategoryId : null,
      );
    case TransactionKind.expense:
    case TransactionKind.transfer:
      return CapturePlan(
        kind: draft.kind,
        reviewStatus: ReviewStatus.needsReview,
        categoryId: suggestCategory(
          payeeKey: draft.payeeKey,
          payeeName: draft.payeeDisplay,
        ),
      );
  }
}

/// Id of the built-in Transfer category.
const String transferCategoryId = 'cat_transfer';

/// Id of the built-in Salary category.
const String salaryCategoryId = 'cat_salary';

final RegExp _cardBill = RegExp(
  r'credit card (?:bill|payment)|\bcc (?:bill|payment)|card bill|'
  'payment .{0,40}received .{0,40}credit card|towards (?:your )?credit card',
);

final RegExp _failed = RegExp(r'\bfailed\b|unsuccessful|declined');

final RegExp _salary = RegExp(r'\bsalary\b|\bsal\b');
