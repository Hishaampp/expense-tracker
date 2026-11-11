import 'package:expense_tracker/features/quick_add/presentation/quick_add_notifier.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/not_payment_reason.dart';
import 'package:txn_parser/txn_parser.dart';

/// The words for [notice]; [droppedClass] says why a message was not a
/// payment.
String noticeText(
  AppLocalizations l10n,
  QuickAddNotice notice,
  MessageClass? droppedClass,
) {
  return switch (notice) {
    QuickAddNotice.clipboardEmpty => l10n.noticeClipboardEmpty,
    QuickAddNotice.noAmount => l10n.noticeNoAmount,
    QuickAddNotice.duplicate => l10n.noticeDuplicate,
    QuickAddNotice.unparsed => l10n.noticeUnparsed,
    QuickAddNotice.notAPayment => l10n.noticeNotPayment(
      notPaymentReason(l10n, droppedClass),
    ),
  };
}
