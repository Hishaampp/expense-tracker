import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:txn_parser/txn_parser.dart';

/// Why a message is not a payment, in words ("it's a one-time password").
String notPaymentReason(AppLocalizations l10n, MessageClass? messageClass) {
  return switch (messageClass) {
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
  };
}
