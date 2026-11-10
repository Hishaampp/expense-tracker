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
    required this.moneyIn,
    required this.byCategory,
  });

  /// Folds [transactions] into totals. Hidden transactions and transfers
  /// are ignored; a refund reduces spending (spec §5.4, §5.5).
  factory of(Iterable<MoneyTransaction> transactions) {
    var spent = 0;
    var inRooms = 0;
    var moneyIn = 0;
    final perCategory = <String?, int>{};
    for (final txn in transactions) {
      if (txn.isHidden) continue;
      final paise = txn.amount.paise;
      switch (txn.kind) {
        case TransactionKind.expense:
          spent += paise;
          if (txn.roomId != null) inRooms += paise;
          perCategory.update(
            txn.categoryId,
            (v) => v + paise,
            ifAbsent: () => paise,
          );
        case TransactionKind.refund:
          spent -= paise;
          if (txn.roomId != null) inRooms -= paise;
          perCategory.update(
            txn.categoryId,
            (v) => v - paise,
            ifAbsent: () => -paise,
          );
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
      moneyIn: Money(moneyIn),
      byCategory: List.unmodifiable(byCategory),
    );
  }

  /// Expenses minus refunds, including Rooms.
  final Money spent;

  /// The part of [spent] that belongs to a Room.
  final Money spentInRooms;

  /// Income received.
  final Money moneyIn;

  /// Spending per category, largest first. A null id is "uncategorised".
  final List<CategorySpend> byCategory;
}
