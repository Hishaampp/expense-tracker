import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// Spending in one category, joined with the category itself.
typedef CategoryTotal = ({Category? category, Money spent});

/// What Home shows for one month.
@immutable
final class HomeState {
  /// Creates the state.
  const new({
    required this.period,
    required this.canGoNext,
    required this.summary,
    required this.topCategories,
    required this.recent,
  });

  /// How many top categories and recent transactions Home lists.
  static const int listLength = 5;

  /// The month shown.
  final MonthPeriod period;

  /// Whether a later month exists to step to (never past the current one).
  final bool canGoNext;

  /// Totals for the month.
  final MonthSummary summary;

  /// The largest categories, at most [listLength].
  final List<CategoryTotal> topCategories;

  /// The newest transactions, at most [listLength].
  final List<TransactionItem> recent;

  /// Whether the month has no transactions at all.
  bool get isEmpty => recent.isEmpty;
}

/// How many months back from the current one Home is showing (0 or less).
class HomeMonthOffsetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Steps one month back.
  void previous() => state = state - 1;

  /// Steps one month forward, stopping at the current month.
  void next() {
    if (state < 0) state = state + 1;
  }
}

/// Provides [HomeMonthOffsetNotifier].
final NotifierProvider<HomeMonthOffsetNotifier, int> homeMonthOffsetProvider =
    NotifierProvider.autoDispose<HomeMonthOffsetNotifier, int>(
      HomeMonthOffsetNotifier.new,
    );

/// Home's view model: derives [HomeState] from the live database queries,
/// so a committed write updates Home with no manual refresh.
class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final offset = ref.watch(homeMonthOffsetProvider);
    final startDay = await ref.watch(monthStartDayProvider.future);
    final today = ref.watch(clockProvider).now().toLocal();
    final period = MonthPeriod.containing(
      today,
      startDay: startDay,
    ).shifted(offset);
    final transactions = await ref.watch(
      monthTransactionsProvider(period).future,
    );
    final categories = await ref.watch(categoriesProvider.future);
    final accounts = await ref.watch(accountsProvider.future);

    final summary = MonthSummary.of(transactions);
    final categoryById = {for (final c in categories) c.id: c};
    final visible = transactions.where((t) => !t.isHidden);
    return HomeState(
      period: period,
      canGoNext: offset < 0,
      summary: summary,
      topCategories: [
        for (final entry in summary.byCategory.take(HomeState.listLength))
          (category: categoryById[entry.categoryId], spent: entry.spent),
      ],
      recent: joinTransactions(
        visible.take(HomeState.listLength),
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
