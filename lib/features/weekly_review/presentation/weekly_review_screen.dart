import 'dart:async';

import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/core/weekly_review.dart';
import 'package:expense_tracker/features/weekly_review/presentation/weekly_review_notifier.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/category/all_categories_sheet.dart';
import 'package:expense_tracker/widgets/category_totals_card.dart';
import 'package:expense_tracker/widgets/choice_pill.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/hero_card.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The weekly review (spec §10, §11 screen 9): this week against last
/// week, the top categories and payees, the review inbox, and one category
/// to watch next week.
class WeeklyReviewScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  Future<void> _watch(
    BuildContext context,
    WidgetRef ref,
    String? id,
    String? name,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(weeklyReviewNotifierProvider.notifier)
        .watch(id);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(switch (result) {
            Ok() when name != null => l10n.weeklyWatchSaved(name),
            Ok() => l10n.weeklyWatchCleared,
            Err(:final failure) => failureMessage(l10n, failure),
          }),
        ),
      );
  }

  Future<void> _more(
    BuildContext context,
    WidgetRef ref,
    WeeklyReviewState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppSheet<String>(
      context,
      AllCategoriesSheet(
        title: l10n.weeklyWatchTitle,
        categories: state.expenseCategories,
        selectedId: state.watchedId,
        selectedLabel: l10n.selected,
      ),
    );
    if (picked == null || !context.mounted) return;
    final name = state.expenseCategories.firstWhere((c) => c.id == picked).name;
    await _watch(context, ref, picked, name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(weeklyReviewNotifierProvider);
    final state = async.value;
    final back = RoundIconButton(
      icon: Icons.arrow_back_rounded,
      tooltip: l10n.back,
      floating: false,
      color: colors.onSurface,
      onPressed: context.pop,
    );
    if (state == null) {
      return LargeTitlePage(
        title: Text(l10n.weeklyTitle),
        leading: back,
        children: [
          if (async.hasError)
            ErrorStateView(
              message: l10n.failureLoad,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(weeklyReviewNotifierProvider),
            )
          else
            PulsingPlaceholder(semanticLabel: l10n.loading),
        ],
      );
    }
    final review = state.review;
    var index = 0;
    Widget enter(Widget child) => Entrance(index: index++, child: child);
    return LargeTitlePage(
      title: Text(l10n.weeklyTitle),
      leading: back,
      children: [
        enter(
          _WeekHero(
            review: review,
            range: l10n.weeklyRange(
              formatDayMonth(review.week.start.date, locale),
              formatDayMonth(review.week.end.date, locale),
            ),
          ),
        ),
        if (state.topCategories.isNotEmpty)
          enter(
            CategoryTotalsCard(
              title: l10n.weeklyTopCategories,
              totals: state.topCategories,
            ),
          ),
        if (review.topPayees.isNotEmpty)
          enter(_PayeesCard(payees: review.topPayees)),
        enter(
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.weeklyInbox(state.reviewCount),
                  style: textTheme.bodyLarge,
                ),
                if (state.reviewCount > 0) ...[
                  SizedBox(height: metrics.spaceSm),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton(
                      onPressed: () => unawaited(context.push(Routes.review)),
                      child: Text(l10n.weeklyOpenReview),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        enter(
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.weeklyWatchTitle,
                    style: textTheme.titleMedium,
                  ),
                ),
                SizedBox(height: metrics.spaceXs),
                Text(l10n.weeklyWatchHelp, style: textTheme.bodyMedium),
                SizedBox(height: metrics.spaceMd),
                Wrap(
                  spacing: metrics.spaceSm,
                  runSpacing: metrics.spaceSm,
                  children: [
                    for (final c in state.watchOptions)
                      ChoicePill(
                        key: ValueKey(c.id),
                        label: c.name,
                        selected: c.id == state.watchedId,
                        onTap: () =>
                            unawaited(_watch(context, ref, c.id, c.name)),
                      ),
                    ChoicePill(
                      label: l10n.quickAddMore,
                      icon: Icons.more_horiz_rounded,
                      selected: false,
                      onTap: () => unawaited(_more(context, ref, state)),
                    ),
                    ChoicePill(
                      label: l10n.weeklyWatchNone,
                      selected: state.watchedId == null,
                      onTap: () => unawaited(_watch(context, ref, null, null)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekHero extends StatelessWidget {
  const new({required this.review, required this.range});

  final WeeklyReview review;
  final String range;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final styles = AppTextStyles.of(context);
    final change = review.change;
    final (icon, compare) = switch (change.paise) {
      > 0 => (Icons.trending_up_rounded, l10n.weeklyMore(formatMoney(change))),
      < 0 => (
        Icons.trending_down_rounded,
        l10n.weeklyLess(formatMoney(review.lastWeekSpent - review.spent)),
      ),
      _ => (Icons.trending_flat_rounded, l10n.weeklySame),
    };
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            range,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onHeroMuted),
          ),
          SizedBox(height: metrics.spaceSm),
          Text(
            review.spent.isPositive
                ? l10n.weeklySpent(formatMoney(review.spent))
                : l10n.weeklyEmpty,
            style: styles.heroSentence.copyWith(color: colors.onHero),
          ),
          SizedBox(height: metrics.spaceLg),
          Row(
            children: [
              Icon(icon, color: colors.onHero, size: metrics.iconLargeSize),
              SizedBox(width: metrics.spaceSm),
              Expanded(
                child: Text(
                  compare,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: colors.onHero),
                ),
              ),
            ],
          ),
          SizedBox(height: metrics.spaceXs),
          Text(
            l10n.weeklyLastWeek(formatMoney(review.lastWeekSpent)),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.onHeroMuted),
          ),
        ],
      ),
    );
  }
}

class _PayeesCard extends StatelessWidget {
  const new({required this.payees});

  final List<PayeeSpend> payees;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.weeklyTopPayees, style: textTheme.titleMedium),
          ),
          SizedBox(height: metrics.spaceSm),
          for (final payee in payees)
            Semantics(
              container: true,
              label: l10n.weeklyPayeeSemantics(
                formatMoney(payee.spent),
                payee.name,
                payee.count,
              ),
              child: ExcludeSemantics(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    vertical: metrics.spaceSm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(payee.name, style: textTheme.bodyLarge),
                            Text(
                              l10n.weeklyPayeeCount(payee.count),
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: metrics.spaceMd),
                      Text(
                        formatMoney(payee.spent),
                        style: AppTextStyles.of(context).amountRow
                            .copyWith(color: colors.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
