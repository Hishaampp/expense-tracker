import 'package:expense_tracker/core/money.dart';
import 'package:meta/meta.dart';

/// The user's spending limits (spec §10): one for the whole month and,
/// optionally, one per category. Every limit repeats each month.
@immutable
final class BudgetPlan {
  /// Creates a plan.
  const new({this.monthly, this.byCategory = const {}});

  /// No limits set.
  static const BudgetPlan none = BudgetPlan();

  /// The monthly limit, or null when none is set.
  final Money? monthly;

  /// Category limits, by category id.
  final Map<String, Money> byCategory;

  /// Whether no limit at all is set.
  bool get isEmpty => monthly == null && byCategory.isEmpty;

  @override
  bool operator ==(Object other) {
    if (other is! BudgetPlan || other.monthly != monthly) return false;
    if (other.byCategory.length != byCategory.length) return false;
    for (final entry in byCategory.entries) {
      if (other.byCategory[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    monthly,
    Object.hashAllUnordered(
      byCategory.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}
