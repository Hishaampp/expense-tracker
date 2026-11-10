import 'package:expense_tracker/features/home/presentation/home_notifier.dart';
import 'package:expense_tracker/features/home/presentation/widgets/money_in_total.dart';
import 'package:expense_tracker/features/home/presentation/widgets/month_spend_header.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/formatting/transaction_row_text.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/category_icon.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/ledger_row.dart';
import 'package:expense_tracker/widgets/ledger_section.dart';
import 'package:flutter/material.dart';

/// The scrolling body of Home for one month: totals, top categories and
/// recent transactions, or the empty state.
class HomeMonthView extends StatelessWidget {
  /// Creates the view of [state].
  const new({
    required this.state,
    required this.onAddExpense,
    required this.onSeeAll,
    required this.onOpenTransaction,
    super.key,
  });

  /// The month to show.
  final HomeState state;

  /// Called from the empty state's action.
  final VoidCallback onAddExpense;

  /// Called from "See all".
  final VoidCallback onSeeAll;

  /// Called with a transaction id when its row is tapped.
  final ValueChanged<String> onOpenTransaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final locale = Localizations.localeOf(context).toString();
    final summary = state.summary;
    final spent = formatMoney(summary.spent);
    return ListView(
      children: [
        SizedBox(height: metrics.spaceSm),
        MonthSpendHeader(
          label: l10n.homeSpentLabel,
          amountText: spent,
          semanticLabel: l10n.homeSpentSemantics(spent),
          roomsNote: summary.spentInRooms.isPositive
              ? l10n.homeIncludesRooms(formatMoney(summary.spentInRooms))
              : null,
        ),
        if (summary.moneyIn.isPositive) ...[
          SizedBox(height: metrics.spaceLg),
          MoneyInTotal(
            label: l10n.homeMoneyIn,
            amountText: formatMoneyIn(summary.moneyIn),
            semanticLabel: l10n.homeMoneyInSemantics(
              formatMoney(summary.moneyIn),
            ),
          ),
        ],
        SizedBox(height: metrics.spaceXl),
        if (state.isEmpty)
          EmptyStateView(
            title: l10n.homeEmptyTitle,
            body: l10n.homeEmptyBody,
            actionLabel: l10n.addExpense,
            onAction: onAddExpense,
          )
        else ...[
          if (state.topCategories.isNotEmpty) ...[
            LedgerSection(
              title: l10n.homeTopCategories,
              rows: [
                for (final total in state.topCategories)
                  LedgerRow(
                    icon: categoryIcon(total.category?.iconKey),
                    title: total.category?.name ?? l10n.uncategorised,
                    amountText: formatMoney(total.spent),
                    semanticLabel: l10n.categorySpentSemantics(
                      formatMoney(total.spent),
                      total.category?.name ?? l10n.uncategorised,
                    ),
                  ),
              ],
            ),
            SizedBox(height: metrics.spaceXl),
          ],
          LedgerSection(
            title: l10n.homeRecent,
            trailing: TextButton(
              onPressed: onSeeAll,
              child: Text(l10n.homeSeeAll),
            ),
            rows: [
              for (final item in state.recent)
                _RecentRow(
                  key: ValueKey(item.transaction.id),
                  text: describeTransaction(item, l10n, locale),
                  onTap: () => onOpenTransaction(item.transaction.id),
                ),
            ],
          ),
        ],
        SizedBox(height: metrics.spaceLg),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
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
