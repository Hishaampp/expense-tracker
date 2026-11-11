import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:meta/meta.dart';

/// How the month stands against its budget (spec §10).
sealed class SafeToSpend {
  const new();

  /// Works out what is safe to spend each day for the rest of [period].
  ///
  /// Safe to spend today = (budget − budget-counted spending so far) ÷
  /// days left in the month including today. [spent] must already leave
  /// out Rooms that stay out of the budget (`MonthSummary.spentForBudget`).
  /// A [today] outside [period] counts as one day left, so a past month
  /// shows what was left at its end.
  factory of({
    required Money? budget,
    required Money spent,
    required MonthPeriod period,
    required DateTime today,
  }) {
    if (budget == null || !budget.isPositive) return const NoBudget();
    final left = budget - spent;
    if (left.isNegative) {
      return Overspent(budget: budget, spent: spent, over: spent - budget);
    }
    final days = period.daysLeftIncluding(today);
    final daysLeft = days < 1 ? 1 : days;
    return OnTrack(
      budget: budget,
      spent: spent,
      left: left,
      daysLeft: daysLeft,
      perDay: _perDayFloor(left, daysLeft),
    );
  }

  // Rounded down, so following it every day never ends over budget.
  static Money _perDayFloor(Money left, int days) =>
      Money(left.paise ~/ days, left.currency);
}

/// No monthly budget is set.
@immutable
final class NoBudget extends SafeToSpend {
  /// Creates the value.
  const new();

  @override
  bool operator ==(Object other) => other is NoBudget;

  @override
  int get hashCode => (NoBudget).hashCode;
}

/// A budget with something left.
@immutable
final class OnTrack extends SafeToSpend {
  /// Creates the value.
  const new({
    required this.budget,
    required this.spent,
    required this.left,
    required this.daysLeft,
    required this.perDay,
  });

  /// The monthly budget.
  final Money budget;

  /// Budget-counted spending so far.
  final Money spent;

  /// What remains of the budget.
  final Money left;

  /// Days left in the month, today included (at least 1).
  final int daysLeft;

  /// What can be spent each day from today, rounded down.
  final Money perDay;

  /// How much of the budget is used, 0–1.
  double get used => spent.paise <= 0 ? 0 : spent.paise / budget.paise;

  @override
  bool operator ==(Object other) =>
      other is OnTrack &&
      other.budget == budget &&
      other.spent == spent &&
      other.left == left &&
      other.daysLeft == daysLeft &&
      other.perDay == perDay;

  @override
  int get hashCode => Object.hash(budget, spent, left, daysLeft, perDay);
}

/// More spent than the budget allows.
@immutable
final class Overspent extends SafeToSpend {
  /// Creates the value.
  const new({required this.budget, required this.spent, required this.over});

  /// The monthly budget.
  final Money budget;

  /// Budget-counted spending so far.
  final Money spent;

  /// How far over the budget.
  final Money over;

  @override
  bool operator ==(Object other) =>
      other is Overspent &&
      other.budget == budget &&
      other.spent == spent &&
      other.over == over;

  @override
  int get hashCode => Object.hash(budget, spent, over);
}
