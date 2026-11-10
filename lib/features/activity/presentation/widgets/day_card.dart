import 'package:expense_tracker/features/activity/presentation/activity_notifier.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/formatting/transaction_row_text.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/transaction_row.dart';
import 'package:flutter/material.dart';

/// One day: a heading with the day's total, then its transactions in a card.
class DayCard extends StatelessWidget {
  /// Creates the card for [group].
  const new({required this.group, required this.onOpenTransaction, super.key});

  /// The day and its transactions.
  final DayGroup group;

  /// Called with a transaction id when its row is tapped.
  final ValueChanged<String> onOpenTransaction;

  String _heading(AppLocalizations l10n, String locale) {
    return switch (group.daysAgo) {
      0 => l10n.today,
      1 => l10n.yesterday,
      _ => formatDayHeading(group.day, locale),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: metrics.spaceXs,
            vertical: metrics.spaceSm,
          ),
          // Wraps the total under the day when both do not fit (large text).
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: metrics.spaceMd,
            children: [
              Semantics(
                header: true,
                child: Text(
                  _heading(l10n, locale),
                  style: textTheme.titleMedium,
                ),
              ),
              if (group.spent.isPositive)
                Text(
                  l10n.daySpent(formatMoney(group.spent)),
                  style: textTheme.bodySmall,
                ),
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: metrics.spaceLg,
            vertical: metrics.spaceSm,
          ),
          child: Column(
            children: [
              for (final item in group.items)
                Entrance(
                  key: ValueKey(item.transaction.id),
                  child: TransactionRow(
                    text: describeTransaction(item, l10n, locale),
                    onTap: () => onOpenTransaction(item.transaction.id),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
