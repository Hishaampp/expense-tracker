import 'package:expense_tracker/features/quick_add/presentation/quick_add_notifier.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
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
    QuickAddNotice.notAPayment => l10n.noticeNotPayment(switch (droppedClass) {
      MessageClass.otp => l10n.reasonOtp,
      MessageClass.promo => l10n.reasonPromo,
      MessageClass.upcomingOrMandate => l10n.reasonUpcoming,
      MessageClass.collectRequest => l10n.reasonCollect,
      MessageClass.balanceInfo => l10n.reasonBalance,
      MessageClass.cardBillDue => l10n.reasonCardBill,
      MessageClass.statement => l10n.reasonStatement,
      MessageClass.failed => l10n.reasonFailed,
      MessageClass.debit ||
      MessageClass.credit ||
      MessageClass.reversalRefund ||
      MessageClass.unknown ||
      null => l10n.reasonOther,
    }),
  };
}
