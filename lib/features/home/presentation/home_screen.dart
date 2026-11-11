import 'dart:async';

import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/features/home/presentation/home_notifier.dart';
import 'package:expense_tracker/features/home/presentation/widgets/capture_health_card.dart';
import 'package:expense_tracker/features/home/presentation/widgets/hero_summary.dart';
import 'package:expense_tracker/features/home/presentation/widgets/recent_card.dart';
import 'package:expense_tracker/features/home/presentation/widgets/top_categories_card.dart';
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
import 'package:expense_tracker/widgets/review_badge.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home: the month at a glance.
class HomeScreen extends ConsumerWidget {
  /// Creates the Home screen.
  const new({super.key});

  Future<void> _pickMonth(
    BuildContext context,
    WidgetRef ref,
    HomeState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final offset = ref.read(homeMonthOffsetProvider.notifier);
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
    final async = ref.watch(homeNotifierProvider);
    // Keep the last month on screen while the next one loads.
    final state = async.value;
    final reviewCount = ref.watch(reviewCountProvider).value ?? 0;
    final review = reviewCount == 0
        ? null
        : ReviewBadge(
            label: l10n.reviewBadge(reviewCount),
            semanticLabel: l10n.reviewBadgeSemantics(reviewCount),
            onTap: () => unawaited(context.push(Routes.review)),
          );
    final add = RoundIconButton(
      icon: Icons.add_rounded,
      tooltip: l10n.addExpense,
      onPressed: () => unawaited(context.push(Routes.addExpense)),
    );

    if (state == null) {
      return LargeTitlePage(
        title: Text(l10n.navHome),
        actions: [?review, add],
        children: [
          if (async.hasError)
            ErrorStateView(
              message: l10n.failureLoad,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(homeNotifierProvider),
            )
          else
            PulsingPlaceholder(semanticLabel: l10n.loading),
        ],
      );
    }
    final month = formatPeriodTitle(state.period, state.today, locale);
    void seeAll() => context.go(Routes.activity);
    // Cards enter one after another, in the order they appear.
    var index = 0;
    Widget enter(Widget child) => Entrance(index: index++, child: child);
    return LargeTitlePage(
      title: MonthTitle(
        label: month,
        semanticLabel: l10n.changeMonth(month),
        onTap: () => unawaited(_pickMonth(context, ref, state)),
      ),
      actions: [?review, add],
      children: [
        enter(HeroSummary(state: state, onSeeAll: seeAll)),
        if (state.captureMayBeOff)
          enter(
            CaptureHealthCard(
              onCheck: () => unawaited(context.push(Routes.iphoneSetup)),
            ),
          ),
        if (state.isEmpty)
          enter(
            EmptyStateView(
              icon: Icons.receipt_long_rounded,
              iconColor: CategoryColors.of(context).orange,
              title: l10n.homeEmptyTitle,
              body: l10n.homeEmptyBody,
              actionLabel: l10n.addExpense,
              onAction: () => unawaited(context.push(Routes.addExpense)),
            ),
          )
        else ...[
          if (state.topCategories.isNotEmpty)
            enter(TopCategoriesCard(totals: state.topCategories)),
          enter(
            RecentCard(
              items: state.recent,
              onSeeAll: seeAll,
              onOpenTransaction: (id) =>
                  unawaited(context.push(Routes.transaction(id))),
            ),
          ),
        ],
      ],
    );
  }
}
