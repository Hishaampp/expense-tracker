import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:meta/meta.dart';

/// What the duplicate check needs to know about one payment report.
@immutable
final class PaymentReport {
  /// Creates the report.
  const new({
    required this.amount,
    required this.kind,
    required this.occurredAt,
    required this.sourceKey,
    this.accountLast4,
    this.refNo,
    this.payeeKey,
    this.payeeName,
  });

  /// The amount.
  final Money amount;

  /// Expense, income, transfer or refund.
  final TransactionKind kind;

  /// When it happened (UTC).
  final DateTime occurredAt;

  /// Where the report came from: source and app/sender together, such as
  /// `android_notification:com.phonepe.app`. Two reports from the same
  /// source key are never weak-matched (two real chais in a row).
  final String sourceKey;

  /// Last digits of the account, if known.
  final String? accountLast4;

  /// Reference number, if any.
  final String? refNo;

  /// Payee key (UPI id or `name:…`), if any.
  final String? payeeKey;

  /// Payee as written, if any.
  final String? payeeName;
}

/// A saved transaction as the duplicate check sees it.
typedef KnownPayment = ({
  String id,
  PaymentReport report,
  Set<String> sourceKeys,
});

/// How close in time two reports of one payment can be (spec §7.6).
const Duration duplicateWindow = Duration(minutes: 10);

/// The saved payment that [incoming] reports again, or null (spec §7.6).
///
/// - Same reference number: the same payment.
/// - Different reference numbers: never the same.
/// - Otherwise the same if amount and kind match, they are at most 10
///   minutes apart, the accounts agree (or one is unknown), the payees
///   agree (or one is unknown), and they came from different sources.
String? findDuplicate(PaymentReport incoming, Iterable<KnownPayment> known) {
  final ref = _clean(incoming.refNo);
  if (ref != null) {
    for (final k in known) {
      if (_clean(k.report.refNo) == ref) return k.id;
    }
  }
  for (final k in known) {
    final r = k.report;
    final otherRef = _clean(r.refNo);
    if (ref != null && otherRef != null) continue; // both known, different
    if (r.amount != incoming.amount || r.kind != incoming.kind) continue;
    if (r.occurredAt.difference(incoming.occurredAt).abs() > duplicateWindow) {
      continue;
    }
    if (!_compatible(r.accountLast4, incoming.accountLast4)) continue;
    if (!_samePayee(r, incoming)) continue;
    if (k.sourceKeys.contains(incoming.sourceKey)) continue;
    return k.id;
  }
  return null;
}

String? _clean(String? ref) {
  final value = ref?.trim().toUpperCase();
  return value == null || value.isEmpty ? null : value;
}

bool _compatible(String? a, String? b) => a == null || b == null || a == b;

bool _samePayee(PaymentReport a, PaymentReport b) {
  final aKey = a.payeeKey;
  final bKey = b.payeeKey;
  if (aKey != null && aKey == bKey) return true;
  final aWords = _words(a);
  final bWords = _words(b);
  // A report that names no payee (an ATM message, a bare bank alert) does
  // not rule out a match.
  if (aWords.isEmpty || bWords.isEmpty) return true;
  return aWords.any(bWords.contains) ||
      aWords.any((w) => bWords.any((v) => v.contains(w) || w.contains(v)));
}

// Words of three or more letters from the payee: the UPI id's name part
// ("swiggy" from "swiggy@icici") and the written name.
Set<String> _words(PaymentReport r) {
  final source = [
    r.payeeName ?? '',
    (r.payeeKey ?? '').replaceFirst('name:', '').split('@').first,
  ].join(' ').toLowerCase();
  return {
    for (final word in source.split(RegExp('[^a-z]+')))
      if (word.length >= 3) word,
  };
}
