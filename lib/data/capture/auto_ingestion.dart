import 'package:expense_tracker/core/capture_plan.dart';
import 'package:expense_tracker/core/dedup.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/capture_draft.dart';
import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/capture/capture_ingestion.dart';
import 'package:expense_tracker/data/repositories/auto_capture_repository.dart';
import 'package:expense_tracker/data/repositories/transaction_repository.dart';

/// What automatic capture did with one message.
enum AutoOutcome {
  /// Saved as a new transaction.
  saved,

  /// Another report of a saved payment: linked to it.
  merged,

  /// Not a transaction, unreadable, or already seen: recorded or skipped.
  recorded,
}

/// Saves automatically captured messages (notifications, SMS) without the
/// user (spec §5.7): parse → de-duplicate → plan → save. Totals are always
/// current; the review inbox collects what needs a look.
class AutoIngestion {
  /// Creates the service.
  new(this._ingestion, this._auto, this._transactions);

  final CaptureIngestion _ingestion;
  final AutoCaptureRepository _auto;
  final TransactionRepository _transactions;

  /// Handles one captured message. Idempotent: the same capture twice is
  /// recorded once (content hash), and the same payment from two sources
  /// becomes one transaction (spec §7.6).
  Future<Result<AutoOutcome, StoreFailure>> ingest(RawCapture capture) async {
    final parsed = await _ingestion.ingest(capture, skipRefDuplicates: true);
    switch (parsed) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        if (value is! IngestedDraft) return const Ok(AutoOutcome.recorded);
        return await _save(value.draft);
    }
  }

  Future<Result<AutoOutcome, StoreFailure>> _save(CaptureDraft draft) async {
    final capture = draft.capture;
    final at = (draft.occurredAt ?? capture.receivedAt).toUtc();
    final report = PaymentReport(
      amount: draft.amount,
      kind: draft.kind,
      occurredAt: at,
      sourceKey: AutoCaptureRepository.sourceKey(
        capture.source.wireName,
        capture.origin,
      ),
      accountLast4: draft.accountLast4,
      refNo: draft.refNo,
      payeeKey: draft.payeeKey,
      payeeName: draft.payeeDisplay,
    );
    final known = await _auto.knownPaymentsNear(at, refNo: draft.refNo);
    final duplicateOf = findDuplicate(report, known);
    if (duplicateOf != null) {
      return switch (await _auto.mergeInto(duplicateOf, draft)) {
        Ok() => const Ok(AutoOutcome.merged),
        Err(:final failure) => Err(failure),
      };
    }

    final plan = planCapture(draft);
    var categoryId = plan.categoryId;
    var reviewStatus = plan.reviewStatus;
    String? linkedId;
    String? roomId;
    if (plan.kind == TransactionKind.refund) {
      final original = await _auto.findRefundOriginal(
        amount: draft.amount,
        beforeUtc: at,
        refNo: draft.refNo,
        payeeKey: draft.payeeKey,
      );
      if (original != null) {
        // A refund inherits the expense's category and Room (spec §5.5).
        linkedId = original.id;
        categoryId = original.categoryId;
        roomId = original.roomId;
        reviewStatus = ReviewStatus.confirmed;
      }
    }
    final saved = await _transactions.addFromCapture(
      draft: draft,
      amount: draft.amount,
      kind: plan.kind,
      categoryId: categoryId,
      reviewStatus: plan.isHidden ? ReviewStatus.confirmed : reviewStatus,
      toAccountId: plan.toAccountId,
      linkedTransactionId: linkedId,
      roomId: roomId,
      isHidden: plan.isHidden,
    );
    return switch (saved) {
      Ok() => const Ok(AutoOutcome.saved),
      Err(:final failure) => Err(failure),
    };
  }
}
