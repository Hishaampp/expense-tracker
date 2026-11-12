import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:meta/meta.dart';

/// Spending in one category within a period.
typedef CategorySpend = ({String? categoryId, Money spent});

/// Totals for a set of transactions (one month), derived on read and never
/// stored (spec §5.1).
@immutable
final class MonthSummary {
  const new _({
    required this.spent,
    required this.spentInRooms,
    required this.spentForBudget,
    required this.moneyIn,
    required this.byCategory,
    required this.budgetByCategory,
  });

  /// Folds [transactions] into totals. Hidden transactions and transfers
  /// are ignored; a refund reduces spending (spec §5.4, §5.5).
  ///
  /// [budgetRoomIds] are the Rooms whose spending counts toward the monthly
  /// budget; every other Room's spending is left out of [spentForBudget]
  /// (spec §5.2).
  factory of(
    Iterable<MoneyTransaction> transactions, {
    Set<String> budgetRoomIds = const {},
  }) {
    var spent = 0;
    var inRooms = 0;
    var outsideBudget = 0;
    var moneyIn = 0;
    final perCategory = <String?, int>{};
    final budgetCategory = <String?, int>{};
    void count(MoneyTransaction txn, int signed) {
      final room = txn.roomId;
      if (room != null && !budgetRoomIds.contains(room)) return;
      budgetCategory.update(
        txn.categoryId,
        (v) => v + signed,
        ifAbsent: () => signed,
      );
    }

    for (final txn in transactions) {
      if (txn.isHidden) continue;
      final paise = txn.amount.paise;
      switch (txn.kind) {
        case TransactionKind.expense:
          spent += paise;
          if (txn.roomId case final room?) {
            inRooms += paise;
            if (!budgetRoomIds.contains(room)) outsideBudget += paise;
          }
          perCategory.update(
            txn.categoryId,
            (v) => v + paise,
            ifAbsent: () => paise,
          );
          count(txn, paise);
        case TransactionKind.refund:
          spent -= paise;
          if (txn.roomId case final room?) {
            inRooms -= paise;
            if (!budgetRoomIds.contains(room)) outsideBudget -= paise;
          }
          perCategory.update(
            txn.categoryId,
            (v) => v - paise,
            ifAbsent: () => -paise,
          );
          count(txn, -paise);
        case TransactionKind.income:
          moneyIn += paise;
        case TransactionKind.transfer:
          break;
      }
    }
    final byCategory = <CategorySpend>[
      for (final entry in perCategory.entries)
        if (entry.value > 0) (categoryId: entry.key, spent: Money(entry.value)),
    ]..sort((a, b) => b.spent.compareTo(a.spent));
    return MonthSummary._(
      spent: Money(spent),
      spentInRooms: Money(inRooms),
      spentForBudget: Money(spent - outsideBudget),
      moneyIn: Money(moneyIn),
      byCategory: List.unmodifiable(byCategory),
      budgetByCategory: Map.unmodifiable({
        for (final entry in budgetCategory.entries)
          entry.key: Money(entry.value),
      }),
    );
  }

  /// Expenses minus refunds, including Rooms.
  final Money spent;

  /// The part of [spent] that belongs to a Room.
  final Money spentInRooms;

  /// The part of [spent] the monthly budget counts: everything except
  /// Rooms that stay out of it (spec §5.2).
  final Money spentForBudget;

  /// Income received.
  final Money moneyIn;

  /// What the month itself left: money in minus money spent. Negative
  /// when more went out than came in (Phase 10).
  Money get result => moneyIn - spent;

  /// Spending per category, largest first. A null id is "uncategorised".
  final List<CategorySpend> byCategory;

  /// Budget-counted spending per category (Rooms outside the budget left
  /// out), for category budgets. A null key is "uncategorised".
  final Map<String?, Money> budgetByCategory;
}
