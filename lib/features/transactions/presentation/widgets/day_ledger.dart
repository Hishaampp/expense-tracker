import 'package:expense_tracker/features/transactions/presentation/transactions_notifier.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/formatting/transaction_row_text.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/ledger_row.dart';
import 'package:expense_tracker/widgets/ledger_section.dart';
import 'package:flutter/material.dart';

/// One day's transactions as a ledger block headed by the date.
class DayLedger extends StatelessWidget {
  /// Creates the block for [group].
  const new({required this.group, required this.onOpenTransaction, super.key});

  /// The day and its transactions.
  final DayGroup group;

  /// Called with a transaction id when its row is tapped.
  final ValueChanged<String> onOpenTransaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: AppMetrics.of(context).spaceXl,
      ),
      child: LedgerSection(
        title: formatDayHeading(group.day, locale),
        trailing: group.spent.isPositive
            ? Text(
                l10n.daySpent(formatMoney(group.spent)),
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        rows: [
          for (final item in group.items)
            _DayRow(
              key: ValueKey(item.transaction.id),
              text: describeTransaction(item, l10n, locale),
              onTap: () => onOpenTransaction(item.transaction.id),
            ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const new({required this.text, required this.onTap, super.key});

  final TransactionRowText text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LedgerRow(
      icon: text.icon,
      title: text.title,
      subtitle: text.subtitle,
      amountText: text.amountText,
      tone: text.tone,
      semanticLabel: text.semanticLabel,
      onTap: onTap,
    );
  }
}
