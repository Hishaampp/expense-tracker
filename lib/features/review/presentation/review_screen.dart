import 'dart:async';

import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/features/review/presentation/review_notifier.dart';
import 'package:expense_tracker/features/review/presentation/widgets/review_card.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/category/all_categories_sheet.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The review inbox (spec §11.3): payments captured automatically, waiting
/// for a category. Tapping a category confirms; Undo puts it back.
class ReviewScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  Future<void> _show(
    BuildContext context,
    WidgetRef ref,
    ReviewDone done,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context)..clearSnackBars();
    final motion = AppMotion.of(context);
    final window = MediaQuery.accessibleNavigationOf(context)
        ? motion.undoWindowAccessible
        : motion.undoWindow;
    final notifier = ref.read(reviewNotifierProvider.notifier);
    final (String text, VoidCallback? undo) = switch (done) {
      ReviewConfirmed(:final transaction, :final category) => (
        l10n.reviewConfirmed(category.name),
        () => unawaited(_undo(messenger, l10n, notifier, transaction)),
      ),
      ReviewTransferred(:final transaction) => (
        l10n.reviewMarkedTransfer,
        () => unawaited(_undo(messenger, l10n, notifier, transaction)),
      ),
      ReviewAddedToRoom(:final transaction, :final room) => (
        l10n.reviewAddedToRoom(room.name),
        () => unawaited(_undo(messenger, l10n, notifier, transaction)),
      ),
      ReviewConfirmedAll(:final count) => (
        l10n.reviewConfirmedAll(count),
        null,
      ),
      ReviewFailed(:final failure) => (failureMessage(l10n, failure), null),
    };
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: window,
        action: undo == null
            ? null
            : SnackBarAction(label: l10n.undo, onPressed: undo),
      ),
    );
  }

  // A failed Undo says so; the payment then stays confirmed.
  static Future<void> _undo(
    ScaffoldMessengerState messenger,
    AppLocalizations l10n,
    ReviewNotifier notifier,
    MoneyTransaction transaction,
  ) async {
    final failure = await notifier.undo(transaction);
    if (failure == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
  }

  Future<void> _more(
    BuildContext context,
    WidgetRef ref,
    ReviewItem item,
    List<Category> all,
  ) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(reviewNotifierProvider.notifier);
    final picked = await showAppSheet<String>(
      context,
      AllCategoriesSheet(
        title: l10n.quickAddAllCategories,
        categories: all,
        selectedId: item.suggested?.id,
        selectedLabel: l10n.reviewSuggested,
      ),
    );
    // Null means dismissed: nothing changes.
    if (picked == null || !context.mounted) return;
    final category = all.firstWhere((c) => c.id == picked);
    final done = await notifier.confirm(item, category);
    if (context.mounted) await _show(context, ref, done);
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<ReviewDone> Function() action,
  ) async {
    final done = await action();
    if (context.mounted) await _show(context, ref, done);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(reviewNotifierProvider);
    final notifier = ref.read(reviewNotifierProvider.notifier);
    final state = async.value;

    final List<Widget> children;
    if (state == null) {
      children = [
        if (async.hasError)
          ErrorStateView(
            message: l10n.failureLoad,
            actionLabel: l10n.tryAgain,
            onAction: () => ref.invalidate(reviewNotifierProvider),
          )
        else
          PulsingPlaceholder(semanticLabel: l10n.loading),
      ];
    } else if (state.items.isEmpty) {
      // No action: there is nothing to do when nothing is waiting.
      children = [
        Entrance(
          child: EmptyStateView(
            icon: Icons.task_alt_rounded,
            iconColor: CategoryColors.of(context).green,
            title: l10n.reviewEmptyTitle,
            body: l10n.reviewEmptyBody,
          ),
        ),
      ];
    } else {
      children = [
        Entrance(
          child: Text(
            l10n.reviewHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (state.suggestedCount > 0)
          Entrance(
            index: 1,
            child: FilledButton(
              onPressed: () =>
                  unawaited(_run(context, ref, notifier.confirmAllSuggested)),
              child: Text(l10n.reviewConfirmAll(state.suggestedCount)),
            ),
          ),
        for (final (index, item) in state.items.indexed)
          Entrance(
            key: ValueKey(item.transaction.id),
            index: index + 2,
            child: ReviewCard(
              item: item,
              onPick: (category) => unawaited(
                _run(context, ref, () => notifier.confirm(item, category)),
              ),
              onMore: () =>
                  unawaited(_more(context, ref, item, state.allCategories)),
              onTransfer: () => unawaited(
                _run(context, ref, () => notifier.markTransfer(item)),
              ),
              onAddToRoom: (room) => unawaited(
                _run(context, ref, () => notifier.addToRoom(item, room)),
              ),
            ),
          ),
      ];
    }
    return LargeTitlePage(
      title: Text(l10n.reviewTitle),
      leading: RoundIconButton(
        icon: Icons.arrow_back_rounded,
        tooltip: l10n.back,
        floating: false,
        color: AppColors.of(context).onSurface,
        onPressed: context.pop,
      ),
      children: children,
    );
  }
}
