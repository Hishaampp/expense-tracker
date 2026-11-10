import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// One local day of transactions.
typedef DayGroup = ({DateTime day, Money spent, List<TransactionItem> items});

/// What the Transactions screen shows for one month.
@immutable
final class TransactionsState {
  /// Creates the state.
  const new({
    required this.period,
    required this.canGoNext,
    required this.days,
  });

  /// The month shown.
  final MonthPeriod period;

  /// Whether a later month exists to step to.
  final bool canGoNext;

  /// The month's transactions grouped by local day, newest day first.
  final List<DayGroup> days;

  /// Whether the month has no transactions.
  bool get isEmpty => days.isEmpty;
}

/// How many months back the Transactions screen is showing (0 or less).
class TransactionsMonthOffsetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Steps one month back.
  void previous() => state = state - 1;

  /// Steps one month forward, stopping at the current month.
  void next() {
    if (state < 0) state = state + 1;
  }
}

/// Provides [TransactionsMonthOffsetNotifier].
final NotifierProvider<TransactionsMonthOffsetNotifier, int>
transactionsMonthOffsetProvider =
    NotifierProvider.autoDispose<TransactionsMonthOffsetNotifier, int>(
      TransactionsMonthOffsetNotifier.new,
    );

/// The Transactions view model, derived from the live database queries.
class TransactionsNotifier extends AsyncNotifier<TransactionsState> {
  @override
  Future<TransactionsState> build() async {
    final offset = ref.watch(transactionsMonthOffsetProvider);
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
    return TransactionsState(
      period: period,
      canGoNext: offset < 0,
      days: [
        for (final entry in byDay.entries)
          (
            day: entry.key,
            spent: MonthSummary.of(entry.value.map((i) => i.transaction)).spent,
            items: entry.value,
          ),
      ],
    );
  }
}

/// Provides [TransactionsNotifier].
final AsyncNotifierProvider<TransactionsNotifier, TransactionsState>
transactionsNotifierProvider =
    AsyncNotifierProvider.autoDispose<TransactionsNotifier, TransactionsState>(
      TransactionsNotifier.new,
    );
