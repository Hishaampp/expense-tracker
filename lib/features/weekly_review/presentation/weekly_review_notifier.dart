import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/category_total.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/core/weekly_review.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// What the weekly review screen shows.
@immutable
final class WeeklyReviewState {
  /// Creates the state.
  const new({
    required this.review,
    required this.topCategories,
    required this.reviewCount,
    required this.watchOptions,
    required this.expenseCategories,
    required this.watchedId,
  });

  /// The week's numbers.
  final WeeklyReview review;

  /// The week's top categories, with their share of the week.
  final List<CategoryTotal> topCategories;

  /// Payments waiting in the review inbox.
  final int reviewCount;

  /// Categories offered as pills for "one thing to watch": the week's top
  /// ones, then the watched one if it is not among them.
  final List<Category> watchOptions;

  /// Every expense category, for "More".
  final List<Category> expenseCategories;

  /// The category being watched, or null.
  final String? watchedId;
}

/// The weekly review's view model (spec §10).
class WeeklyReviewNotifier extends AsyncNotifier<WeeklyReviewState> {
  @override
  Future<WeeklyReviewState> build() async {
    final now = ref.watch(clockProvider).now();
    final week = LocalWeek.reviewedOn(LocalDay.of(now));
    final transactions = await ref.watch(
      rangeTransactionsProvider((
        start: week.previous.startUtcMs,
        end: week.endUtcMs,
      )).future,
    );
    final categories = await ref.watch(categoriesProvider.future);
    final reviewCount = await ref.watch(reviewCountProvider.future);
    final watchedId = await ref.watch(watchedCategoryProvider.future);
    final review = WeeklyReview.of(transactions, week);
    final top = categoryTotals(review.topCategories, categories, review.spent);
    final byId = {for (final c in categories) c.id: c};
    final options = [
      for (final t in top)
        if (t.category case final c? when c.kind == CategoryKind.expense) c,
    ];
    if (byId[watchedId] case final watched?
        when !options.any((c) => c.id == watched.id)) {
      options.add(watched);
    }
    return WeeklyReviewState(
      review: review,
      topCategories: top,
      reviewCount: reviewCount,
      watchOptions: options,
      expenseCategories: [
        for (final c in categories)
          if (c.kind == CategoryKind.expense && !c.isArchived) c,
      ],
      watchedId: byId.containsKey(watchedId) ? watchedId : null,
    );
  }

  /// Watches [categoryId] next week, or nothing with null.
  Future<Result<String?, StoreFailure>> watch(String? categoryId) async {
    final result = await ref
        .read(settingsRepositoryProvider)
        .setWatchedCategory(categoryId);
    if (result is Ok) ref.read(hapticsProvider).select();
    return result;
  }
}

/// Provides [WeeklyReviewNotifier].
final AsyncNotifierProvider<WeeklyReviewNotifier, WeeklyReviewState>
weeklyReviewNotifierProvider =
    AsyncNotifierProvider.autoDispose<WeeklyReviewNotifier, WeeklyReviewState>(
      WeeklyReviewNotifier.new,
    );
