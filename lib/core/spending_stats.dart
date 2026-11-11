import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';

/// Spending on one local day.
typedef DayTotal = ({LocalDay day, Money spent});

/// Spending in one budgeting month.
typedef MonthTotal = ({MonthPeriod period, Money spent});

/// Spending on each day of [period], first day first; days with nothing
/// spent are zero. Rooms count; refunds reduce the day they arrive.
List<DayTotal> spendByDay(
  Iterable<MoneyTransaction> transactions,
  MonthPeriod period,
) {
  final first = LocalDay.of(period.start);
  final length = LocalDay.of(period.end).since(first);
  final buckets = List<List<MoneyTransaction>>.generate(length, (_) => []);
  for (final txn in transactions) {
    final index = LocalDay.of(txn.occurredAt).since(first);
    if (index >= 0 && index < length) buckets[index].add(txn);
  }
  return [
    for (var i = 0; i < length; i++)
      (day: first.plus(i), spent: _positive(MonthSummary.of(buckets[i]).spent)),
  ];
}

/// Spending in each of [periods], in the order given. [transactions] may
/// span them all.
List<MonthTotal> spendByMonth(
  Iterable<MoneyTransaction> transactions,
  List<MonthPeriod> periods,
) {
  final buckets = List<List<MoneyTransaction>>.generate(
    periods.length,
    (_) => [],
  );
  for (final txn in transactions) {
    final local = txn.occurredAt.toLocal();
    for (var i = 0; i < periods.length; i++) {
      if (periods[i].contains(local)) {
        buckets[i].add(txn);
        break;
      }
    }
  }
  return [
    for (var i = 0; i < periods.length; i++)
      (period: periods[i], spent: _positive(MonthSummary.of(buckets[i]).spent)),
  ];
}

// A day of refunds only shows as nothing spent, not a negative bar.
Money _positive(Money money) => money.isNegative ? Money.zero : money;
