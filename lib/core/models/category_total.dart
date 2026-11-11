import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_summary.dart';

/// Spending in one category and its share of the whole.
typedef CategoryTotal = ({Category? category, Money spent, double share});

/// Joins [spends] (largest first) with [categories], each with its share
/// of [total]. Keeps at most [limit] when given.
List<CategoryTotal> categoryTotals(
  Iterable<CategorySpend> spends,
  Iterable<Category> categories,
  Money total, {
  int? limit,
}) {
  final byId = {for (final c in categories) c.id: c};
  final picked = limit == null ? spends : spends.take(limit);
  return [
    for (final entry in picked)
      (
        category: byId[entry.categoryId],
        spent: entry.spent,
        share: total.paise <= 0 ? 0 : entry.spent.paise / total.paise,
      ),
  ];
}
