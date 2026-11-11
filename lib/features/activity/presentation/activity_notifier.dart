import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_offset.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:expense_tracker/core/transaction_filter.dart';
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
    this.filter = const TransactionFilter(),
    this.categories = const [],
    this.rooms = const [],
    this.accounts = const [],
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

  /// The search and filters applied.
  final TransactionFilter filter;

  /// Expense and income categories, for the category filter.
  final List<Category> categories;

  /// Every Room, for the Room filter.
  final List<Room> rooms;

  /// Every account, for the account filter.
  final List<Account> accounts;

  /// Whether nothing is shown.
  bool get isEmpty => days.isEmpty;

  /// How many transactions are shown.
  int get count => days.fold(0, (sum, d) => sum + d.items.length);
}

/// Activity's search and filters (spec §11 screen 4).
class ActivityFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  /// Replaces the filter.
  // A single write path keeps the filter one value.
  // ignore: use_setters_to_change_properties
  void set(TransactionFilter filter) => state = filter;
}

/// Provides Activity's filter.
final NotifierProvider<ActivityFilterNotifier, TransactionFilter>
activityFilterProvider =
    NotifierProvider.autoDispose<ActivityFilterNotifier, TransactionFilter>(
      ActivityFilterNotifier.new,
    );

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
    final filter = ref.watch(activityFilterProvider);
    // A search looks through the whole year the picker covers, not just
    // the month shown.
    final oldest = current.shifted(1 - MonthOffsetNotifier.pickerMonths);
    final transactions = filter.searches
        ? await ref.watch(
            rangeTransactionsProvider((
              start: oldest.startUtcMs,
              end: current.endUtcMs,
            )).future,
          )
        : await ref.watch(monthTransactionsProvider(period).future);
    final categories = await ref.watch(categoriesProvider.future);
    final accounts = await ref.watch(accountsProvider.future);
    final rooms = await ref.watch(roomsProvider.future);

    final items = joinTransactions(
      transactions.where((t) => !t.isHidden),
      categories,
      accounts,
    ).where(filter.matches);
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
      filter: filter,
      categories: [
        for (final c in categories)
          if (c.kind != CategoryKind.system && !c.isArchived) c,
      ],
      rooms: rooms,
      accounts: [
        for (final a in accounts)
          if (!a.isArchived) a,
      ],
    );
  }
}

/// Provides [ActivityNotifier].
final AsyncNotifierProvider<ActivityNotifier, ActivityState>
activityNotifierProvider = AsyncNotifierProvider.autoDispose(
  ActivityNotifier.new,
);
