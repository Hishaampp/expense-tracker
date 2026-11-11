import 'dart:async';

import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/core/safe_to_spend.dart';
import 'package:expense_tracker/features/budgets/presentation/budgets_notifier.dart';
import 'package:expense_tracker/features/budgets/presentation/widgets/budget_amount_sheet.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/category/all_categories_sheet.dart';
import 'package:expense_tracker/widgets/category_style.dart';
import 'package:expense_tracker/widgets/charts/ring_chart.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/growing_bar.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:expense_tracker/widgets/switch_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Budgets: the monthly budget, category budgets and the weekly review
/// switch (spec §10, §11 screen 8).
class BudgetsScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  Future<void> _report(
    BuildContext context,
    Future<Result<Money?, StoreFailure>> pending,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await pending;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(switch (result) {
            Ok(value: null) => l10n.budgetsRemoved,
            Ok() => l10n.budgetsSaved,
            Err(:final failure) => failureMessage(l10n, failure),
          }),
        ),
      );
  }

  Future<void> _editMonthly(
    BuildContext context,
    WidgetRef ref,
    Money? current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final edit = await showAppSheet<BudgetEdit>(
      context,
      BudgetAmountSheet(title: l10n.budgetsMonthly, current: current),
    );
    // Null means dismissed: nothing changes.
    if (edit == null || !context.mounted) return;
    await _report(
      context,
      ref.read(budgetsNotifierProvider.notifier).setMonthly(edit.amount),
    );
  }

  Future<void> _editCategory(
    BuildContext context,
    WidgetRef ref, {
    required String id,
    required String name,
    Money? current,
  }) async {
    final l10n = AppLocalizations.of(context);
    final edit = await showAppSheet<BudgetEdit>(
      context,
      BudgetAmountSheet(
        title: l10n.budgetsCategoryTitle(name),
        current: current,
      ),
    );
    if (edit == null || !context.mounted) return;
    await _report(
      context,
      ref.read(budgetsNotifierProvider.notifier).setCategory(id, edit.amount),
    );
  }

  Future<void> _addCategory(
    BuildContext context,
    WidgetRef ref,
    BudgetsState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppSheet<String>(
      context,
      AllCategoriesSheet(
        title: l10n.budgetsPickCategory,
        categories: state.unbudgeted,
        selectedId: null,
        selectedLabel: l10n.selected,
      ),
    );
    if (picked == null || !context.mounted) return;
    final category = state.unbudgeted.firstWhere((c) => c.id == picked);
    await _editCategory(context, ref, id: category.id, name: category.name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final tiles = CategoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final async = ref.watch(budgetsNotifierProvider);
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
        title: Text(l10n.budgetsTitle),
        leading: back,
        children: [
          if (async.hasError)
            ErrorStateView(
              message: l10n.failureLoad,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(budgetsNotifierProvider),
            )
          else
            PulsingPlaceholder(semanticLabel: l10n.loading),
        ],
      );
    }
    var index = 0;
    Widget enter(Widget child) => Entrance(index: index++, child: child);
    return LargeTitlePage(
      title: Text(l10n.budgetsTitle),
      leading: back,
      children: [
        enter(
          _MonthlyCard(
            state: state,
            onEdit: () => unawaited(_editMonthly(context, ref, state.monthly)),
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
                    l10n.budgetsCategories,
                    style: textTheme.titleMedium,
                  ),
                ),
                SizedBox(height: metrics.spaceXs),
                Text(l10n.budgetsCategoriesHelp, style: textTheme.bodyMedium),
                SizedBox(height: metrics.spaceSm),
                for (final line in state.lines)
                  _CategoryBudgetRow(
                    key: ValueKey(line.category.id),
                    line: line,
                    onTap: () => unawaited(
                      _editCategory(
                        context,
                        ref,
                        id: line.category.id,
                        name: line.category.name,
                        current: line.budget,
                      ),
                    ),
                  ),
                if (state.unbudgeted.isNotEmpty) ...[
                  SizedBox(height: metrics.spaceSm),
                  OutlinedButton.icon(
                    onPressed: () =>
                        unawaited(_addCategory(context, ref, state)),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.budgetsAddCategory),
                  ),
                ],
              ],
            ),
          ),
        ),
        enter(
          AppCard(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: metrics.spaceLg,
              vertical: metrics.spaceMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(l10n.budgetsAlerts, style: textTheme.titleMedium),
                ),
                SizedBox(height: metrics.spaceXs),
                Text(l10n.budgetsAlertsHelp, style: textTheme.bodyMedium),
                if (state.notificationsBlocked) ...[
                  SizedBox(height: metrics.spaceSm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notifications_off_rounded,
                        color: colors.danger,
                        size: metrics.iconSize,
                      ),
                      SizedBox(width: metrics.spaceSm),
                      Expanded(
                        child: Text(
                          l10n.budgetsNotificationsOff,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: metrics.spaceSm),
                SwitchRow(
                  leading: IconTile(
                    icon: Icons.event_repeat_rounded,
                    color: tiles.violet,
                  ),
                  title: l10n.budgetsWeeklyReview,
                  value: state.weeklyReviewOn,
                  onChanged: (on) => unawaited(
                    ref
                        .read(budgetsNotifierProvider.notifier)
                        .setWeeklyReview(on: on),
                  ),
                ),
                Text(l10n.budgetsWeeklyReviewHelp, style: textTheme.bodySmall),
                SizedBox(height: metrics.spaceSm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: () =>
                        unawaited(context.push(Routes.weeklyReview)),
                    child: Text(l10n.budgetsOpenWeek),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlyCard extends StatelessWidget {
  const new({required this.state, required this.onEdit});

  final BudgetsState state;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final styles = AppTextStyles.of(context);
    final textTheme = Theme.of(context).textTheme;
    final monthly = state.monthly;
    final (used, over) = switch (state.safe) {
      OnTrack(:final used) => (used, false),
      Overspent() => (1.0, true),
      NoBudget() => (0.0, false),
    };
    final percent = (used * 100).round();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.budgetsMonthly, style: textTheme.titleMedium),
          ),
          SizedBox(height: metrics.spaceMd),
          Row(
            children: [
              if (monthly != null) ...[
                Semantics(
                  container: true,
                  label: l10n.homeBudgetPercentSemantics(over ? 100 : percent),
                  child: RingChart(
                    segments: [
                      (
                        value: used,
                        color: over ? colors.danger : colors.accent,
                      ),
                    ],
                    total: 1,
                    size: metrics.ringSize,
                    stroke: metrics.ringStroke,
                    trackColor: colors.surfaceSunken,
                    center: ExcludeSemantics(
                      child: Text(
                        l10n.homeBudgetPercent(over ? 100 : percent),
                        style: textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: metrics.spaceLg),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monthly == null
                          ? l10n.budgetsNotSet
                          : formatMoney(monthly),
                      style: styles.statValue.copyWith(color: colors.onSurface),
                    ),
                    SizedBox(height: metrics.spaceXs),
                    Text(switch (state.safe) {
                      OnTrack(:final left, :final budget) =>
                        l10n.homeBudgetLeft(
                          formatMoney(left),
                          formatMoney(budget),
                        ),
                      Overspent(:final over) => l10n.homeBudgetOver(
                        formatMoney(over),
                      ),
                      NoBudget() => l10n.budgetsMonthlyHelp,
                    }, style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: metrics.spaceMd),
          if (monthly != null)
            Text(l10n.budgetsMonthlyHelp, style: textTheme.bodySmall),
          SizedBox(height: metrics.spaceSm),
          FilledButton.tonal(
            onPressed: onEdit,
            child: Text(
              monthly == null ? l10n.budgetsSetMonthly : l10n.budgetsChange,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBudgetRow extends StatelessWidget {
  const new({required this.line, required this.onTap, super.key});

  final CategoryBudgetLine line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final style = categoryStyle(context, line.category.iconKey);
    final spent = formatMoney(line.spent);
    final budget = formatMoney(line.budget);
    final full = line.spent.paise >= line.budget.paise;
    return Semantics(
      container: true,
      button: true,
      label: l10n.budgetsCategorySemantics(line.category.name, spent, budget),
      onTap: onTap,
      child: ExcludeSemantics(
        child: Pressable(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(metrics.radiusTileLarge),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: metrics.minTapTarget),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: metrics.spaceSm,
              ),
              child: Row(
                children: [
                  IconTile(icon: style.icon, color: style.color),
                  SizedBox(width: metrics.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                line.category.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            if (full)
                              Icon(
                                Icons.error_rounded,
                                color: colors.danger,
                                size: metrics.iconSize,
                              ),
                          ],
                        ),
                        SizedBox(height: metrics.spaceXs),
                        GrowingBar(
                          fraction: line.budget.paise <= 0
                              ? 0
                              : line.spent.paise / line.budget.paise,
                          color: full ? colors.danger : style.color,
                          trackColor: colors.surfaceSunken,
                        ),
                        SizedBox(height: metrics.spaceXs),
                        Text(
                          l10n.budgetsUsedOf(spent, budget),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
