import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/widgets/money_tone.dart';

/// Everything a ledger row shows for one transaction, already localized.
typedef TransactionRowText = ({
  String iconKey,
  String title,
  String subtitle,
  String amountText,
  MoneyTone tone,
  String semanticLabel,
});

/// Describes [item] for a ledger row. Each kind differs by sign, icon and
/// label, not by colour alone (docs/DESIGN.md, "Money states").
TransactionRowText describeTransaction(
  TransactionItem item,
  AppLocalizations l10n,
  String locale,
) {
  final txn = item.transaction;
  final amount = formatMoney(txn.amount);
  final categoryName = item.category?.name ?? l10n.uncategorised;
  final title = txn.payeeDisplay ?? txn.note ?? categoryName;
  final time = formatTime(txn.occurredAt.toLocal(), locale);
  String withTime(String label) => label == title ? time : '$label, $time';

  return switch (txn.kind) {
    TransactionKind.expense => (
      iconKey: item.category?.iconKey ?? 'other',
      title: title,
      subtitle: withTime(categoryName),
      amountText: amount,
      tone: MoneyTone.spent,
      semanticLabel: l10n.rowSpentSemantics(amount, '$title, $categoryName'),
    ),
    TransactionKind.income => (
      iconKey: 'income',
      title: title,
      subtitle: withTime(l10n.moneyIn),
      amountText: formatMoneyIn(txn.amount),
      tone: MoneyTone.moneyIn,
      semanticLabel: l10n.rowMoneyInSemantics(amount, title),
    ),
    TransactionKind.transfer => (
      iconKey: 'transfer',
      title: title,
      subtitle: withTime(l10n.transfer),
      amountText: amount,
      tone: MoneyTone.transfer,
      semanticLabel: l10n.rowTransferSemantics(amount, title),
    ),
    TransactionKind.refund => (
      iconKey: 'refund',
      title: title,
      subtitle: withTime(l10n.refund),
      amountText: formatMoneyIn(txn.amount),
      tone: MoneyTone.moneyIn,
      semanticLabel: l10n.rowRefundSemantics(amount, title),
    ),
  };
}
