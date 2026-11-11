import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/category_total.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_offset.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:expense_tracker/core/spending_stats.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// A month the Stats picker offers.
typedef StatsMonthChoice = ({int offset, MonthPeriod period});

/// What the Stats tab shows for one month.
@immutable
final class StatsState {
  /// Creates the state.
  const new({
    required this.period,
    required this.today,
    required this.offset,
    required this.choices,
    required this.spent,
    required this.categories,
    required this.days,
    required this.daysCounted,
    required this.months,
  });

  /// How many months the trend chart covers, the shown one included.
  static const int trendMonths = 6;

  /// The month shown.
  final MonthPeriod period;

  /// Today's local date.
  final DateTime today;

  /// Months back from the current one (0 or less).
  final int offset;

  /// The months the picker offers, newest first.
  final List<StatsMonthChoice> choices;

  /// Spent in the month, Rooms included.
  final Money spent;

  /// Every category spent on, largest first, with its share.
  final List<CategoryTotal> categories;

  /// Spending on each day of the month.
  final List<DayTotal> days;

  /// Days of the month so far (all of them, for a past month).
  final int daysCounted;

  /// Spending in the [trendMonths] months up to the shown one, oldest
  /// first.
  final List<MonthTotal> months;

  /// Whether this is the month in progress.
  bool get isCurrent => offset == 0;

  /// Whether nothing was spent in the month.
  bool get isEmpty => !spent.isPositive;

  /// The day that cost the most, or null when nothing was spent.
  DayTotal? get highestDay {
    DayTotal? best;
    for (final day in days) {
      if (best == null || day.spent.compareTo(best.spent) > 0) best = day;
    }
    return best == null || !best.spent.isPositive ? null : best;
  }

  /// Average spending per day so far.
  Money get dailyAverage => spent.dividedRounded(daysCounted);

  /// Average monthly spending over the months that had any.
  Money get monthAverage {
    final spentMonths = [
      for (final m in months)
        if (m.spent.isPositive) m.spent,
    ];
    if (spentMonths.isEmpty) return Money.zero;
    return spentMonths
        .fold(Money.zero, (a, b) => a + b)
        .dividedRounded(spentMonths.length);
  }

  /// Index of today in [days], or null for another month.
  int? get todayIndex {
    if (!isCurrent) return null;
    final index = LocalDay.of(today).since(LocalDay.of(period.start));
    return index >= 0 && index < days.length ? index : null;
  }
}

/// Provides the month Stats is showing.
final NotifierProvider<MonthOffsetNotifier, int> statsMonthOffsetProvider =
    NotifierProvider.autoDispose<MonthOffsetNotifier, int>(
      MonthOffsetNotifier.new,
    );

/// The Stats view model, derived from live queries.
class StatsNotifier extends AsyncNotifier<StatsState> {
  @override
  Future<StatsState> build() async {
    final offset = ref.watch(statsMonthOffsetProvider);
    final startDay = await ref.watch(monthStartDayProvider.future);
    final now = ref.watch(clockProvider).now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final current = MonthPeriod.containing(today, startDay: startDay);
    final period = current.shifted(offset);
    final trend = [
      for (var i = StatsState.trendMonths - 1; i >= 0; i--) period.shifted(-i),
    ];
    final transactions = await ref.watch(
      rangeTransactionsProvider((
        start: trend.first.startUtcMs,
        end: period.endUtcMs,
      )).future,
    );
    final categories = await ref.watch(categoriesProvider.future);
    final inMonth = [
      for (final t in transactions)
        if (period.contains(t.occurredAt.toLocal())) t,
    ];
    final summary = MonthSummary.of(inMonth);
    return StatsState(
      period: period,
      today: today,
      offset: offset,
      choices: [
        for (var i = 0; i < MonthOffsetNotifier.pickerMonths; i++)
          (offset: -i, period: current.shifted(-i)),
      ],
      spent: summary.spent,
      categories: categoryTotals(summary.byCategory, categories, summary.spent),
      days: spendByDay(inMonth, period),
      daysCounted: period.daysElapsedOn(today),
      months: spendByMonth(transactions, trend),
    );
  }
}

/// Provides [StatsNotifier].
final AsyncNotifierProvider<StatsNotifier, StatsState> statsNotifierProvider =
    AsyncNotifierProvider.autoDispose<StatsNotifier, StatsState>(
      StatsNotifier.new,
    );
