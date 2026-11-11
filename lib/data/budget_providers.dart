import 'package:expense_tracker/core/models/budget_plan.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:expense_tracker/core/safe_to_spend.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// The month in progress measured against its budgets (spec §10). Shared
/// by Home, Budgets and the alert check, so all three agree.
@immutable
final class BudgetSnapshot {
  /// Creates the snapshot.
  const new({
    required this.period,
    required this.today,
    required this.plan,
    required this.summary,
    required this.safe,
    required this.rooms,
    required this.roomSpentPaise,
    required this.categories,
  });

  /// The current budgeting month.
  final MonthPeriod period;

  /// Today's local date.
  final DateTime today;

  /// The budgets set.
  final BudgetPlan plan;

  /// The month's totals; `spentForBudget` leaves out Rooms that stay out.
  final MonthSummary summary;

  /// What is safe to spend today.
  final SafeToSpend safe;

  /// Every Room.
  final List<Room> rooms;

  /// Spending per Room in paise, by Room id.
  final Map<String, int> roomSpentPaise;

  /// Every category.
  final List<Category> categories;
}

/// The current month against its budgets. Live: recomputed after every
/// write to transactions, budgets or Rooms.
final FutureProvider<BudgetSnapshot> budgetSnapshotProvider =
    FutureProvider.autoDispose<BudgetSnapshot>((ref) async {
      final startDay = await ref.watch(monthStartDayProvider.future);
      final now = ref.watch(clockProvider).now().toLocal();
      final today = DateTime(now.year, now.month, now.day);
      final period = MonthPeriod.containing(today, startDay: startDay);
      final transactions = await ref.watch(
        monthTransactionsProvider(period).future,
      );
      final plan = await ref.watch(budgetPlanProvider.future);
      final rooms = await ref.watch(roomsProvider.future);
      final roomSpent = await ref.watch(roomSpentProvider.future);
      final categories = await ref.watch(categoriesProvider.future);
      final summary = MonthSummary.of(
        transactions,
        budgetRoomIds: {
          for (final r in rooms)
            if (r.countsTowardMonthlyBudget) r.id,
        },
      );
      return BudgetSnapshot(
        period: period,
        today: today,
        plan: plan,
        summary: summary,
        safe: SafeToSpend.of(
          budget: plan.monthly,
          spent: summary.spentForBudget,
          period: period,
          today: today,
        ),
        rooms: rooms,
        roomSpentPaise: roomSpent,
        categories: categories,
      );
    });
