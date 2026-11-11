import 'dart:async';

import 'package:expense_tracker/core/transaction_filter.dart';
import 'package:expense_tracker/features/activity/presentation/activity_notifier.dart';
import 'package:expense_tracker/features/activity/presentation/widgets/activity_search.dart';
import 'package:expense_tracker/features/activity/presentation/widgets/day_card.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/month_picker_sheet.dart';
import 'package:expense_tracker/widgets/month_title.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Activity: every transaction in a month, grouped by day.
class ActivityScreen extends ConsumerWidget {
  /// Creates the Activity screen.
  const new({super.key});

  Future<void> _pickMonth(
    BuildContext context,
    WidgetRef ref,
    ActivityState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final offset = ref.read(activityMonthOffsetProvider.notifier);
    final picked = await showMonthPickerSheet(
      context,
      title: l10n.pickMonthTitle,
      selectedOffset: state.offset,
      choices: [
        for (final choice in state.choices)
          (
            offset: choice.offset,
            label: formatPeriodTitle(choice.period, state.today, locale),
          ),
      ],
    );
    // Null means dismissed: keep the month.
    if (picked != null) offset.set(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(activityNotifierProvider);
    // Keep the last month on screen while the next one loads.
    final state = async.value;
    final add = RoundIconButton(
      icon: Icons.add_rounded,
      tooltip: l10n.addExpense,
      onPressed: () => unawaited(context.push(Routes.addExpense)),
    );

    if (state == null) {
      return LargeTitlePage(
        title: Text(l10n.activityTitle),
        actions: [add],
        children: [
          if (async.hasError)
            ErrorStateView(
              message: l10n.failureLoad,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(activityNotifierProvider),
            )
          else
            PulsingPlaceholder(semanticLabel: l10n.loading),
        ],
      );
    }
    final month = formatPeriodTitle(state.period, state.today, locale);
    return LargeTitlePage(
      title: MonthTitle(
        label: month,
        semanticLabel: l10n.changeMonth(month),
        onTap: () => unawaited(_pickMonth(context, ref, state)),
      ),
      actions: [add],
      children: [
        ActivitySearch(
          state: state,
          onChanged: ref.read(activityFilterProvider.notifier).set,
        ),
        if (state.filter.isActive)
          Semantics(
            liveRegion: true,
            child: Text(
              state.filter.searches
                  ? '${l10n.activityResults(state.count)} · '
                        '${l10n.activitySearchingAll}'
                  : l10n.activityResults(state.count),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        if (state.isEmpty && state.filter.isActive)
          Entrance(
            child: EmptyStateView(
              icon: Icons.search_off_rounded,
              iconColor: CategoryColors.of(context).grey,
              title: l10n.activityNoMatchTitle,
              body: l10n.activityNoMatchBody,
              actionLabel: l10n.activityClearFilters,
              onAction: () => ref
                  .read(activityFilterProvider.notifier)
                  .set(const TransactionFilter()),
            ),
          )
        else if (state.isEmpty)
          Entrance(
            child: EmptyStateView(
              icon: Icons.receipt_long_rounded,
              iconColor: CategoryColors.of(context).blue,
              title: l10n.activityEmptyTitle(month),
              body: l10n.activityEmptyBody,
              actionLabel: l10n.addExpense,
              onAction: () => unawaited(context.push(Routes.addExpense)),
            ),
          )
        else
          for (final (index, group) in state.days.indexed)
            Entrance(
              key: ValueKey(group.day),
              index: index,
              child: DayCard(
                group: group,
                onOpenTransaction: (id) =>
                    unawaited(context.push(Routes.transaction(id))),
              ),
            ),
      ],
    );
  }
}
