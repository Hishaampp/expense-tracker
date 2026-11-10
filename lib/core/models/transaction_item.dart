import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:meta/meta.dart';

/// A transaction joined with its category and account, ready to list.
@immutable
final class TransactionItem {
  /// Creates the item.
  const new({required this.transaction, this.category, this.account});

  /// The transaction.
  final MoneyTransaction transaction;

  /// Its category, or null when uncategorised.
  final Category? category;

  /// The account it was paid from, or null if that account is gone.
  final Account? account;

  @override
  bool operator ==(Object other) =>
      other is TransactionItem &&
      other.transaction == transaction &&
      other.category == category &&
      other.account == account;

  @override
  int get hashCode => Object.hash(transaction, category, account);
}

/// Joins [transactions] with [categories] and [accounts] by id.
List<TransactionItem> joinTransactions(
  Iterable<MoneyTransaction> transactions,
  Iterable<Category> categories,
  Iterable<Account> accounts,
) {
  final categoryById = {for (final c in categories) c.id: c};
  final accountById = {for (final a in accounts) a.id: a};
  return [
    for (final txn in transactions)
      TransactionItem(
        transaction: txn,
        category: categoryById[txn.categoryId],
        account: accountById[txn.accountId],
      ),
  ];
}
