import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_offset.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// One local day of transactions. `daysAgo` is 0 for today, 1 for
/// yesterday.
typedef DayGroup = ({
  DateTime day,
  int daysAgo,
  Money spent,
  List<TransactionItem> items,
});

/// A month the picker offers.
typedef ActivityPeriodChoice = ({int offset, MonthPeriod period});

/// What Activity shows for one month.
@immutable
final class ActivityState {
  /// Creates the state.
  const new({
    required this.period,
    required this.today,
    required this.offset,
    required this.choices,
    required this.days,
  });

  /// The month shown.
  final MonthPeriod period;

  /// Today's local date, for "Today" and "Yesterday" headings.
  final DateTime today;

  /// Months back from the current one (0 or less).
  final int offset;

  /// The months the picker offers, newest first.
  final List<ActivityPeriodChoice> choices;

  /// The month's transactions grouped by local day, newest day first.
  final List<DayGroup> days;

  /// Whether the month has no transactions.
  bool get isEmpty => days.isEmpty;
}

/// Provides the month Activity is showing.
final NotifierProvider<MonthOffsetNotifier, int> activityMonthOffsetProvider =
    NotifierProvider.autoDispose<MonthOffsetNotifier, int>(
      MonthOffsetNotifier.new,
    );

/// Activity's view model, derived from the live database queries.
class ActivityNotifier extends AsyncNotifier<ActivityState> {
  @override
  Future<ActivityState> build() async {
    final offset = ref.watch(activityMonthOffsetProvider);
    final startDay = await ref.watch(monthStartDayProvider.future);
    final now = ref.watch(clockProvider).now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final current = MonthPeriod.containing(today, startDay: startDay);
    final period = current.shifted(offset);
    final transactions = await ref.watch(
      monthTransactionsProvider(period).future,
    );
    final categories = await ref.watch(categoriesProvider.future);
    final accounts = await ref.watch(accountsProvider.future);

    final items = joinTransactions(
      transactions.where((t) => !t.isHidden),
      categories,
      accounts,
    );
    final byDay = <DateTime, List<TransactionItem>>{};
    for (final item in items) {
      final at = item.transaction.occurredAt.toLocal();
      byDay
          .putIfAbsent(DateTime(at.year, at.month, at.day), () => [])
          .add(item);
    }
    return ActivityState(
      period: period,
      today: today,
      offset: offset,
      choices: [
        for (var i = 0; i < MonthOffsetNotifier.pickerMonths; i++)
          (offset: -i, period: current.shifted(-i)),
      ],
      days: [
        for (final entry in byDay.entries)
          (
            day: entry.key,
            daysAgo: DateTime.utc(today.year, today.month, today.day)
                .difference(
                  DateTime.utc(entry.key.year, entry.key.month, entry.key.day),
                )
                .inDays,
            spent: MonthSummary.of(entry.value.map((i) => i.transaction)).spent,
            items: entry.value,
          ),
      ],
    );
  }
}

/// Provides [ActivityNotifier].
final AsyncNotifierProvider<ActivityNotifier, ActivityState>
activityNotifierProvider = AsyncNotifierProvider.autoDispose(
  ActivityNotifier.new,
);
