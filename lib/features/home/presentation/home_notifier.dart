import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_offset.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// Spending in one category and its share of the month.
typedef CategoryTotal = ({Category? category, Money spent, double share});

/// A month the picker offers.
typedef PeriodChoice = ({int offset, MonthPeriod period});

/// What Home shows for one month.
@immutable
final class HomeState {
  /// Creates the state.
  const new({
    required this.period,
    required this.today,
    required this.offset,
    required this.choices,
    required this.summary,
    required this.dailyAverage,
    required this.paymentCount,
    required this.topCategories,
    required this.recent,
  });

  /// How many top categories Home lists.
  static const int topCategoryCount = 4;

  /// How many recent transactions Home lists.
  static const int recentCount = 4;

  /// The month shown.
  final MonthPeriod period;

  /// Today's local date, for naming months relative to it.
  final DateTime today;

  /// Months back from the current one (0 or less).
  final int offset;

  /// The months the picker offers, newest first.
  final List<PeriodChoice> choices;

  /// Totals for the month.
  final MonthSummary summary;

  /// Spending per day so far (per day of the month, for a past month).
  final Money dailyAverage;

  /// Number of expenses in the month.
  final int paymentCount;

  /// The largest categories, at most [topCategoryCount].
  final List<CategoryTotal> topCategories;

  /// The newest transactions, at most [recentCount].
  final List<TransactionItem> recent;

  /// Whether this is the month in progress.
  bool get isCurrent => offset == 0;

  /// Whether the month has no transactions at all.
  bool get isEmpty => recent.isEmpty;
}

/// Provides the month Home is showing.
final NotifierProvider<MonthOffsetNotifier, int> homeMonthOffsetProvider =
    NotifierProvider.autoDispose<MonthOffsetNotifier, int>(
      MonthOffsetNotifier.new,
    );

/// Home's view model: derives [HomeState] from the live database queries,
/// so a committed write updates Home with no manual refresh.
class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final offset = ref.watch(homeMonthOffsetProvider);
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

    final summary = MonthSummary.of(transactions);
    final categoryById = {for (final c in categories) c.id: c};
    final visible = transactions.where((t) => !t.isHidden);
    final total = summary.spent.paise;
    return HomeState(
      period: period,
      today: today,
      offset: offset,
      choices: [
        for (var i = 0; i < MonthOffsetNotifier.pickerMonths; i++)
          (offset: -i, period: current.shifted(-i)),
      ],
      summary: summary,
      dailyAverage: summary.spent.dividedRounded(period.daysElapsedOn(today)),
      paymentCount: visible.length,
      topCategories: [
        for (final entry in summary.byCategory.take(HomeState.topCategoryCount))
          (
            category: categoryById[entry.categoryId],
            spent: entry.spent,
            share: total <= 0 ? 0 : entry.spent.paise / total,
          ),
      ],
      recent: joinTransactions(
        visible.take(HomeState.recentCount),
        categories,
        accounts,
      ),
    );
  }
}

/// Provides [HomeNotifier].
final AsyncNotifierProvider<HomeNotifier, HomeState> homeNotifierProvider =
    AsyncNotifierProvider.autoDispose<HomeNotifier, HomeState>(
      HomeNotifier.new,
    );
