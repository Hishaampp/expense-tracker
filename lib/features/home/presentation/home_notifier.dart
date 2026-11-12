import 'package:expense_tracker/core/capture_health.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/category_total.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_offset.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/core/safe_to_spend.dart';
import 'package:expense_tracker/core/weekly_review.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// The category watched this week and what it has cost so far.
typedef WatchedCategory = ({String name, String? iconKey, Money spent});

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
    this.activeRooms = const [],
    this.captureMayBeOff = false,
    this.safe = const NoBudget(),
    this.watched,
    this.carried = Money.zero,
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

  /// Active Rooms, newest first.
  final List<Room> activeRooms;

  /// Whether iPhone auto-capture seems to have stopped (spec §6.3).
  final bool captureMayBeOff;

  /// The month against its budget (spec §10).
  final SafeToSpend safe;

  /// The category the user chose to watch, for the current month only.
  final WatchedCategory? watched;

  /// What carried into the month from earlier months: money in minus
  /// money spent since the month of the first income (Phase 10).
  final Money carried;

  /// What is left: [carried] plus this month's money in, minus what it
  /// spent.
  Money get balance => carried + summary.result;

  /// What the month had to spend: [carried] (when positive) plus its money
  /// in.
  Money get available =>
      (carried.isPositive ? carried : Money.zero) + summary.moneyIn;

  /// Whether to lead with the balance: once any income is recorded, this
  /// month or before. Someone tracking only spending keeps the spending
  /// view.
  bool get showsBalance => summary.moneyIn.isPositive || carried != Money.zero;

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

    final rooms = await ref.watch(roomsProvider.future);
    final summary = MonthSummary.of(
      transactions,
      budgetRoomIds: {
        for (final r in rooms)
          if (r.countsTowardMonthlyBudget) r.id,
      },
    );
    final visible = transactions.where((t) => !t.isHidden);
    // The balance starts with the month of the first income, so months of
    // spending tracked before any income do not count against it.
    final firstIncomeAt = await ref.watch(firstIncomeAtProvider.future);
    final balanceStart = firstIncomeAt == null
        ? null
        : MonthPeriod.containing(
            DateTime.fromMillisecondsSinceEpoch(firstIncomeAt),
            startDay: startDay,
          ).startUtcMs;
    final carried = balanceStart == null || balanceStart >= period.startUtcMs
        ? Money.zero
        : await ref.watch(
            netBetweenProvider((start: balanceStart, end: period.startUtcMs))
                .future,
          );
    final plan = await ref.watch(budgetPlanProvider.future);
    final watchedId = await ref.watch(watchedCategoryProvider.future);
    WatchedCategory? watched;
    if (offset == 0 && watchedId != null) {
      final category = categories.where((c) => c.id == watchedId).firstOrNull;
      if (category != null) {
        final week = LocalWeek.containing(LocalDay.of(now));
        final weekTransactions = await ref.watch(
          rangeTransactionsProvider((
            start: week.startUtcMs,
            end: week.endUtcMs,
          )).future,
        );
        final spent = MonthSummary.of(
          weekTransactions.where((t) => t.categoryId == watchedId),
        ).spent;
        watched = (
          name: category.name,
          iconKey: category.iconKey,
          spent: spent.isNegative ? Money.zero : spent,
        );
      }
    }
    return HomeState(
      carried: carried,
      safe: offset == 0
          ? SafeToSpend.of(
              budget: plan.monthly,
              spent: summary.spentForBudget,
              period: period,
              today: today,
            )
          : const NoBudget(),
      watched: watched,
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
      topCategories: categoryTotals(
        summary.byCategory,
        categories,
        summary.spent,
        limit: HomeState.topCategoryCount,
      ),
      activeRooms: [
        for (final r in rooms)
          if (r.isActive) r,
      ],
      captureMayBeOff: captureMayBeOff(
        setupAt: ref.watch(iosShortcutSetupAtProvider).value,
        lastCaptureAt: ref.watch(lastShortcutCaptureAtProvider).value,
        now: now.toUtc(),
      ),
      recent: joinTransactions(
        visible.take(HomeState.recentCount),
        categories,
        accounts,
      ),
    );
  }

  /// Starts a trip named [name] today.
  Future<Result<Room, StoreFailure>> startTrip(String name) async {
    final result = await ref.read(roomRepositoryProvider).startTrip(name);
    if (result is Ok) ref.read(hapticsProvider).commit();
    return result;
  }
}

/// Provides [HomeNotifier].
final AsyncNotifierProvider<HomeNotifier, HomeState> homeNotifierProvider =
    AsyncNotifierProvider.autoDispose<HomeNotifier, HomeState>(
      HomeNotifier.new,
    );
