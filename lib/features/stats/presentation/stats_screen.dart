import 'dart:async';

import 'package:expense_tracker/features/stats/presentation/stats_notifier.dart';
import 'package:expense_tracker/features/stats/presentation/widgets/bars_card.dart';
import 'package:expense_tracker/features/stats/presentation/widgets/category_donut_card.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/month_picker_sheet.dart';
import 'package:expense_tracker/widgets/month_title.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Stats: where the month's money went, day by day, and the last six
/// months, as charts with the key numbers written out.
class StatsScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  Future<void> _pickMonth(
    BuildContext context,
    WidgetRef ref,
    StatsState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final offset = ref.read(statsMonthOffsetProvider.notifier);
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
    final async = ref.watch(statsNotifierProvider);
    final state = async.value;
    if (state == null) {
      return LargeTitlePage(
        title: Text(l10n.statsTitle),
        children: [
          if (async.hasError)
            ErrorStateView(
              message: l10n.failureLoad,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(statsNotifierProvider),
            )
          else
            PulsingPlaceholder(semanticLabel: l10n.loading),
        ],
      );
    }
    final month = formatPeriodTitle(state.period, state.today, locale);
    var index = 0;
    Widget enter(Widget child) => Entrance(index: index++, child: child);
    final highest = state.highestDay;
    final dayAverage = formatMoney(state.dailyAverage);
    final monthAverage = state.monthAverage;
    return LargeTitlePage(
      title: MonthTitle(
        label: month,
        semanticLabel: l10n.changeMonth(month),
        onTap: () => unawaited(_pickMonth(context, ref, state)),
      ),
      children: [
        if (state.isEmpty)
          enter(
            EmptyStateView(
              icon: Icons.donut_large_rounded,
              iconColor: CategoryColors.of(context).violet,
              title: l10n.statsEmptyTitle,
              body: l10n.statsEmptyBody,
              actionLabel: l10n.addExpense,
              onAction: () => unawaited(context.push(Routes.addExpense)),
            ),
          )
        else ...[
          enter(
            CategoryDonutCard(total: state.spent, categories: state.categories),
          ),
          if (highest != null)
            enter(
              BarsCard(
                title: l10n.statsByDay,
                values: [for (final d in state.days) d.spent.paise.toDouble()],
                highlight: state.todayIndex,
                guide: state.dailyAverage.paise.toDouble(),
                semanticLabel: l10n.statsByDaySemantics(
                  formatMoney(highest.spent),
                  formatDayMonth(highest.day.date, locale),
                  dayAverage,
                ),
                lines: [
                  l10n.statsHighestDay(
                    formatMoney(highest.spent),
                    formatDayMonth(highest.day.date, locale),
                  ),
                  l10n.statsDailyAverage(dayAverage),
                ],
              ),
            ),
        ],
        if (monthAverage.isPositive)
          enter(
            BarsCard(
              title: l10n.statsByMonth,
              values: [for (final m in state.months) m.spent.paise.toDouble()],
              highlight: state.months.length - 1,
              guide: monthAverage.paise.toDouble(),
              labels: [
                for (final m in state.months)
                  formatMonthShort(m.period, locale),
              ],
              semanticLabel: [
                for (final m in state.months)
                  l10n.statsMonthBar(
                    formatPeriodTitle(m.period, state.today, locale),
                    formatMoney(m.spent),
                  ),
              ].join('. '),
              lines: [l10n.statsMonthAverage(formatMoney(monthAverage))],
            ),
          ),
        enter(
          _WeekLink(onTap: () => unawaited(context.push(Routes.weeklyReview))),
        ),
      ],
    );
  }
}

class _WeekLink extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      button: true,
      label: '${l10n.statsWeekTitle}. ${l10n.statsWeekBody}',
      onTap: onTap,
      child: ExcludeSemantics(
        child: AppCard(
          onTap: onTap,
          child: Row(
            children: [
              IconTile(
                icon: Icons.event_repeat_rounded,
                color: CategoryColors.of(context).violet,
              ),
              SizedBox(width: metrics.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.statsWeekTitle, style: textTheme.titleMedium),
                    SizedBox(height: metrics.spaceXs),
                    Text(l10n.statsWeekBody, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
