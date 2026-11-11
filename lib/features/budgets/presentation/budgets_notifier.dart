import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/core/safe_to_spend.dart';
import 'package:expense_tracker/data/budget_providers.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// One category budget and what has been spent against it.
typedef CategoryBudgetLine = ({Category category, Money budget, Money spent});

/// What the Budgets screen shows.
@immutable
final class BudgetsState {
  /// Creates the state.
  const new({
    required this.monthly,
    required this.safe,
    required this.lines,
    required this.unbudgeted,
    required this.weeklyReviewOn,
    this.notificationsBlocked = false,
  });

  /// The monthly budget, or null.
  final Money? monthly;

  /// How the month stands against it.
  final SafeToSpend safe;

  /// Category budgets, in category order.
  final List<CategoryBudgetLine> lines;

  /// Expense categories without a budget, for "Add category budget".
  final List<Category> unbudgeted;

  /// Whether the weekly review notification is on.
  final bool weeklyReviewOn;

  /// Whether the phone refused notifications when asked.
  final bool notificationsBlocked;
}

/// The Budgets view model. Every change is written through the budget
/// repository; the screen follows the database.
class BudgetsNotifier extends AsyncNotifier<BudgetsState> {
  @override
  Future<BudgetsState> build() async {
    final snapshot = await ref.watch(budgetSnapshotProvider.future);
    final weekly = await ref.watch(weeklyReviewOnProvider.future);
    final plan = snapshot.plan;
    final expense = [
      for (final c in snapshot.categories)
        if (c.kind == CategoryKind.expense && !c.isArchived) c,
    ];
    return BudgetsState(
      monthly: plan.monthly,
      safe: snapshot.safe,
      lines: [
        for (final c in snapshot.categories)
          if (plan.byCategory[c.id] case final budget?)
            (
              category: c,
              budget: budget,
              spent: snapshot.summary.budgetByCategory[c.id] ?? Money.zero,
            ),
      ],
      unbudgeted: [
        for (final c in expense)
          if (!plan.byCategory.containsKey(c.id)) c,
      ],
      weeklyReviewOn: weekly,
      notificationsBlocked: ref.watch(_notificationsBlockedProvider),
    );
  }

  /// Sets the monthly budget, or removes it with null.
  Future<Result<Money?, StoreFailure>> setMonthly(Money? amount) async {
    final result = await ref.read(budgetRepositoryProvider).setMonthly(amount);
    await _afterSave(result, amount);
    return result;
  }

  /// Sets category [categoryId]'s budget, or removes it with null.
  Future<Result<Money?, StoreFailure>> setCategory(
    String categoryId,
    Money? amount,
  ) async {
    final result = await ref
        .read(budgetRepositoryProvider)
        .setCategory(categoryId, amount);
    await _afterSave(result, amount);
    return result;
  }

  /// Turns the weekly review notification on or off.
  Future<Result<bool, StoreFailure>> setWeeklyReview({required bool on}) async {
    final result = await ref
        .read(settingsRepositoryProvider)
        .setWeeklyReview(on: on);
    if (result is Ok && on) await _askForNotifications();
    return result;
  }

  Future<void> _afterSave(
    Result<Money?, StoreFailure> result,
    Money? amount,
  ) async {
    if (result is! Ok) return;
    ref.read(hapticsProvider).commit();
    // A new budget is the moment alerts start to matter: ask then.
    if (amount != null) await _askForNotifications();
  }

  Future<void> _askForNotifications() async {
    final allowed = await ref
        .read(notificationServiceProvider)
        .requestPermission();
    ref.read(_notificationsBlockedProvider.notifier).blocked = !allowed;
  }
}

class _BlockedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  // A setter keeps the intent a single write.
  // ignore: avoid_setters_without_getters
  set blocked(bool value) => state = value;
}

// Whether the phone refused notifications when last asked.
final NotifierProvider<_BlockedNotifier, bool> _notificationsBlockedProvider =
    NotifierProvider.autoDispose<_BlockedNotifier, bool>(_BlockedNotifier.new);

/// Provides [BudgetsNotifier].
final AsyncNotifierProvider<BudgetsNotifier, BudgetsState>
budgetsNotifierProvider =
    AsyncNotifierProvider.autoDispose<BudgetsNotifier, BudgetsState>(
      BudgetsNotifier.new,
    );
