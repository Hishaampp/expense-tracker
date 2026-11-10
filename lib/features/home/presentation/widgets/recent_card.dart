import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/formatting/transaction_row_text.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/transaction_row.dart';
import 'package:flutter/material.dart';

/// The newest transactions, with a link to Activity.
class RecentCard extends StatelessWidget {
  /// Creates the card for [items].
  const new({
    required this.items,
    required this.onSeeAll,
    required this.onOpenTransaction,
    super.key,
  });

  /// The transactions to show, newest first.
  final List<TransactionItem> items;

  /// Opens Activity.
  final VoidCallback onSeeAll;

  /// Called with a transaction id when its row is tapped.
  final ValueChanged<String> onOpenTransaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.homeRecent,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              TextButton(onPressed: onSeeAll, child: Text(l10n.homeSeeAll)),
            ],
          ),
          for (final item in items)
            // A row that appears after the card was built fades in.
            Entrance(
              key: ValueKey(item.transaction.id),
              child: TransactionRow(
                text: describeTransaction(item, l10n, locale),
                onTap: () => onOpenTransaction(item.transaction.id),
              ),
            ),
        ],
      ),
    );
  }
}
