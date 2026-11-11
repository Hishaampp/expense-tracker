import 'package:expense_tracker/core/safe_to_spend.dart';
import 'package:expense_tracker/features/home/presentation/home_notifier.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/category_style.dart';
import 'package:expense_tracker/widgets/charts/ring_chart.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:flutter/material.dart';

/// Home's budget card (spec §10, §11 screen 2): a ring of the month's
/// budget used and what is safe to spend today; over budget, the overspend
/// in words with a warning icon. Without a budget, an invitation to set
/// one. The watched category sits at the bottom. Tapping opens Budgets.
class BudgetCard extends StatelessWidget {
  /// Creates the card.
  const new({
    required this.safe,
    required this.onOpen,
    this.watched,
    super.key,
  });

  /// The month against its budget.
  final SafeToSpend safe;

  /// The category being watched this week.
  final WatchedCategory? watched;

  /// Opens Budgets.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final watched = this.watched;
    final body = switch (safe) {
      NoBudget() => const _Invite(),
      final OnTrack s => _Status(
        used: s.used,
        over: false,
        label: l10n.homeBudgetSafe,
        amount: formatMoney(s.perDay),
        lines: [
          l10n.homeBudgetLeft(formatMoney(s.left), formatMoney(s.budget)),
          l10n.homeBudgetDays(s.daysLeft),
        ],
        semanticLabel: l10n.homeBudgetSafeSemantics(
          formatMoney(s.perDay),
          formatMoney(s.left),
          formatMoney(s.budget),
          s.daysLeft,
        ),
      ),
      final Overspent s => _Status(
        used: 1,
        over: true,
        label: l10n.homeBudgetOver(formatMoney(s.over)),
        amount: null,
        lines: [
          l10n.homeBudgetOverBody(formatMoney(s.spent), formatMoney(s.budget)),
        ],
        semanticLabel: l10n.homeBudgetOverSemantics(
          formatMoney(s.over),
          formatMoney(s.spent),
          formatMoney(s.budget),
        ),
      ),
    };
    final said = switch (body) {
      _Status(:final semanticLabel) => semanticLabel,
      _ => l10n.budgetCardSetSemantics,
    };
    // One node, one tap: the card says everything and opens Budgets.
    return Semantics(
      container: true,
      button: true,
      label: watched == null
          ? said
          : l10n.listPair(
              said,
              l10n.homeWatching(watched.name, formatMoney(watched.spent)),
            ),
      hint: l10n.homeBudgetOpen,
      onTap: onOpen,
      child: ExcludeSemantics(
        child: AppCard(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              body,
              if (watched != null) ...[
                SizedBox(height: metrics.spaceMd),
                _WatchedLine(watched: watched),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const new({
    required this.used,
    required this.over,
    required this.label,
    required this.amount,
    required this.lines,
    required this.semanticLabel,
  });

  final double used;
  final bool over;
  final String label;
  final String? amount;
  final List<String> lines;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final styles = AppTextStyles.of(context);
    final textTheme = Theme.of(context).textTheme;
    final percent = (used.clamp(0, 1) * 100).round();
    final amount = this.amount;
    return Semantics(
      container: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Row(
          children: [
            RingChart(
              segments: [
                (value: used, color: over ? colors.danger : colors.accent),
              ],
              total: 1,
              size: metrics.ringSize,
              stroke: metrics.ringStroke,
              trackColor: colors.surfaceSunken,
              center: over
                  ? Icon(
                      Icons.warning_amber_rounded,
                      color: colors.danger,
                      size: metrics.iconLargeSize,
                    )
                  : Text(
                      l10n.homeBudgetPercent(percent),
                      style: textTheme.titleMedium,
                    ),
            ),
            SizedBox(width: metrics.spaceLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: over
                        ? textTheme.titleMedium?.copyWith(color: colors.danger)
                        : textTheme.bodyMedium,
                  ),
                  if (amount != null)
                    Text(
                      amount,
                      style: styles.statValue.copyWith(color: colors.onSurface),
                    ),
                  SizedBox(height: metrics.spaceXs),
                  for (final line in lines)
                    Text(line, style: textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Invite extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        IconTile(
          icon: Icons.savings_rounded,
          color: CategoryColors.of(context).green,
        ),
        SizedBox(width: metrics.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.homeBudgetSetTitle, style: textTheme.titleMedium),
              Text(l10n.homeBudgetSetBody, style: textTheme.bodyMedium),
            ],
          ),
        ),
        SizedBox(width: metrics.spaceSm),
        // The whole card is the button; this only says what it does.
        Text(
          l10n.homeBudgetSetAction,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.of(context).accentText,
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: AppColors.of(context).onSurfaceMuted,
        ),
      ],
    );
  }
}

class _WatchedLine extends StatelessWidget {
  const new({required this.watched});

  final WatchedCategory watched;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final style = categoryStyle(context, watched.iconKey);
    return Row(
      children: [
        Icon(
          Icons.visibility_rounded,
          color: style.color,
          size: metrics.iconSize,
        ),
        SizedBox(width: metrics.spaceSm),
        Expanded(
          child: Text(
            l10n.homeWatching(watched.name, formatMoney(watched.spent)),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
