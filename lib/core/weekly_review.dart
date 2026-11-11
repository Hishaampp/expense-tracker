import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:meta/meta.dart';

/// Spending with one payee in a week.
typedef PayeeSpend = ({String name, Money spent, int count});

/// A Monday-to-Sunday week of local days.
@immutable
final class LocalWeek {
  const new _(this.start);

  /// The week that contains [day].
  factory containing(LocalDay day) {
    // 1 Jan 1970 was a Thursday: day 0 is weekday 4 (Monday = 1).
    final weekday = (day.value + 3) % 7 + 1;
    return LocalWeek._(day.plus(1 - weekday));
  }

  /// The week the weekly review covers on [today] (spec §10): this week
  /// on Sunday, when the review arrives; the last full week on other days.
  factory reviewedOn(LocalDay today) {
    final week = LocalWeek.containing(today);
    return today == week.end ? week : week.previous;
  }

  /// Monday.
  final LocalDay start;

  /// Sunday.
  LocalDay get end => start.plus(6);

  /// The week before.
  LocalWeek get previous => LocalWeek._(start.plus(-7));

  /// Whether [day] is in this week.
  bool contains(LocalDay day) => !day.isBefore(start) && !day.isAfter(end);

  /// Monday's local midnight as UTC epoch milliseconds (inclusive).
  int get startUtcMs => start.date.toUtc().millisecondsSinceEpoch;

  /// The next Monday's local midnight as UTC epoch milliseconds
  /// (exclusive).
  int get endUtcMs => start.plus(7).date.toUtc().millisecondsSinceEpoch;

  @override
  bool operator ==(Object other) => other is LocalWeek && other.start == start;

  @override
  int get hashCode => start.hashCode;
}

/// The Sunday-evening look back (spec §10): this week against last week,
/// where the money went and who was paid most.
@immutable
final class WeeklyReview {
  const new _({
    required this.week,
    required this.spent,
    required this.lastWeekSpent,
    required this.topCategories,
    required this.topPayees,
  });

  /// Builds the review of [week] from [transactions], which should cover
  /// [week] and the week before; anything else is ignored. Rooms count:
  /// this is all spending, like Home's "Spent".
  factory of(Iterable<MoneyTransaction> transactions, LocalWeek week) {
    final previous = week.previous;
    final thisWeek = <MoneyTransaction>[];
    final lastWeek = <MoneyTransaction>[];
    for (final txn in transactions) {
      final day = LocalDay.of(txn.occurredAt);
      if (week.contains(day)) {
        thisWeek.add(txn);
      } else if (previous.contains(day)) {
        lastWeek.add(txn);
      }
    }
    final summary = MonthSummary.of(thisWeek);
    return WeeklyReview._(
      week: week,
      spent: summary.spent,
      lastWeekSpent: MonthSummary.of(lastWeek).spent,
      topCategories: summary.byCategory
          .take(topCategoryCount)
          .toList(growable: false),
      topPayees: _payees(thisWeek),
    );
  }

  /// How many categories the review lists.
  static const int topCategoryCount = 3;

  /// How many payees the review lists.
  static const int topPayeeCount = 5;

  /// The week reviewed.
  final LocalWeek week;

  /// Spent in [week]: expenses minus refunds.
  final Money spent;

  /// Spent in the week before.
  final Money lastWeekSpent;

  /// The largest categories, at most [topCategoryCount].
  final List<CategorySpend> topCategories;

  /// The payees paid most, at most [topPayeeCount].
  final List<PayeeSpend> topPayees;

  /// [spent] minus [lastWeekSpent]: positive when this week cost more.
  Money get change => spent - lastWeekSpent;

  static List<PayeeSpend> _payees(List<MoneyTransaction> transactions) {
    final paise = <String, int>{};
    final counts = <String, int>{};
    final names = <String, String>{};
    for (final txn in transactions) {
      if (txn.isHidden || txn.kind != TransactionKind.expense) continue;
      final name = txn.payeeDisplay?.trim();
      if (name == null || name.isEmpty) continue;
      final key = txn.payeeKey ?? name.toLowerCase();
      paise.update(
        key,
        (v) => v + txn.amount.paise,
        ifAbsent: () => txn.amount.paise,
      );
      counts.update(key, (v) => v + 1, ifAbsent: () => 1);
      names.putIfAbsent(key, () => name);
    }
    final list = [
      for (final key in paise.keys)
        (name: names[key]!, spent: Money(paise[key]!), count: counts[key]!),
    ]..sort((a, b) => b.spent.compareTo(a.spent));
    return list.take(topPayeeCount).toList(growable: false);
  }
}
