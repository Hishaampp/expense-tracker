import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/capture_draft.dart';
import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/repositories/capture_repository.dart';
import 'package:meta/meta.dart';
import 'package:txn_parser/txn_parser.dart';

/// What happened to a capture.
sealed class IngestionOutcome {
  const new();
}

/// A payment, receipt or refund, waiting for the user to pick a category.
@immutable
final class IngestedDraft extends IngestionOutcome {
  /// Creates the outcome.
  const new(this.draft);

  /// The proposed transaction.
  final CaptureDraft draft;
}

/// Not a transaction (an OTP, a promotion…); recorded with its reason.
@immutable
final class IngestedDropped extends IngestionOutcome {
  /// Creates the outcome.
  const new(this.messageClass);

  /// Why it was dropped.
  final MessageClass messageClass;
}

/// Had an amount but could not be read; saved to the Unparsed list.
@immutable
final class IngestedUnparsed extends IngestionOutcome {
  /// Creates the outcome.
  const new({this.amount});

  /// The amount found, if any.
  final Money? amount;
}

/// The same message, or the same reference number, was already recorded.
@immutable
final class IngestedDuplicate extends IngestionOutcome {
  /// Creates the outcome.
  const new();
}

/// No amount at all: nothing recorded.
@immutable
final class IngestedNoAmount extends IngestionOutcome {
  /// Creates the outcome.
  const new();
}

/// Turns a capture into an outcome (spec §6): parse, then record what is
/// not a transaction. A transaction itself is recorded only when the user
/// saves it, so a cancelled Quick Add leaves nothing behind.
class CaptureIngestion {
  /// Creates the service.
  new(this._parser, this._captures);

  final TxnParser _parser;
  final CaptureRepository _captures;

  /// Parses and, where needed, records [capture].
  Future<Result<IngestionOutcome, StoreFailure>> ingest(
    RawCapture capture,
  ) async {
    if (await _captures.isKnown(capture.contentHash)) {
      return const Ok(IngestedDuplicate());
    }
    final result = _parser.parse(capture.text, origin: capture.origin);
    switch (result) {
      case ParsedTransaction():
        final draft = _draftFrom(capture, result);
        final ref = draft.refNo;
        if (ref != null && await _captures.hasTransactionWithRef(ref)) {
          return const Ok(IngestedDuplicate());
        }
        return Ok(IngestedDraft(draft));
      case DroppedMessage(:final messageClass):
        return _recorded(
          await _captures.recordDropped(capture, messageClass.name),
          IngestedDropped(messageClass),
        );
      case UnparsedMessage(:final amountPaise):
        return _recorded(
          await _captures.recordUnparsed(capture, maskSensitive(capture.text)),
          IngestedUnparsed(
            amount: amountPaise == null ? null : Money(amountPaise),
          ),
        );
      case NoAmount():
        return const Ok(IngestedNoAmount());
    }
  }

  static Result<IngestionOutcome, StoreFailure> _recorded(
    Result<void, StoreFailure> write,
    IngestionOutcome outcome,
  ) {
    return switch (write) {
      Ok() => Ok(outcome),
      Err(:final failure) => Err(failure),
    };
  }

  static CaptureDraft _draftFrom(RawCapture capture, ParsedTransaction p) {
    final f = p.fields;
    final kind = switch (p.messageClass) {
      MessageClass.reversalRefund => TransactionKind.refund,
      _ =>
        f.direction == Direction.debit
            ? TransactionKind.expense
            : TransactionKind.income,
    };
    final name = f.payeeName;
    final vpa = f.payeeVpa;
    return CaptureDraft(
      capture: capture,
      kind: kind,
      amount: Money(f.amountPaise),
      occurredAt: _localTime(f.occurredAt, capture.receivedAt),
      instrument: _instrument(f.instrument),
      bankCode: f.bankHint,
      accountLast4: f.accountHint,
      isCreditCard: f.isCreditCard,
      payeeKey: vpa ?? (name == null ? null : payeeKeyForName(name)),
      payeeDisplay: name ?? vpa,
      refNo: f.refNo,
      templateId: p.templateId,
      confidence: p.confidence,
    );
  }

  /// The payee key for a name: upper-cased, single-spaced, prefixed.
  static String payeeKeyForName(String name) =>
      'name:${name.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ')}';

  // A date with no time is read as the time the message arrived, when that
  // is the same day, or midday otherwise.
  static DateTime? _localTime(MessageDateTime? at, DateTime receivedUtc) {
    if (at == null) return null;
    if (at.hasTime) {
      return DateTime(at.year, at.month, at.day, at.hour, at.minute, at.second);
    }
    final received = receivedUtc.toLocal();
    final sameDay =
        received.year == at.year &&
        received.month == at.month &&
        received.day == at.day;
    return sameDay ? received : DateTime(at.year, at.month, at.day, _midday);
  }

  static const int _midday = 12;

  static Instrument _instrument(ParsedInstrument i) => switch (i) {
    ParsedInstrument.upi => Instrument.upi,
    ParsedInstrument.card => Instrument.card,
    ParsedInstrument.netbanking => Instrument.netbanking,
    ParsedInstrument.imps => Instrument.imps,
    ParsedInstrument.neft => Instrument.neft,
    ParsedInstrument.rtgs => Instrument.rtgs,
    ParsedInstrument.atm => Instrument.atm,
    ParsedInstrument.wallet => Instrument.wallet,
    ParsedInstrument.unknown => Instrument.unknown,
  };
}
