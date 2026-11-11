import 'package:expense_tracker/core/models/category_total.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/category_style.dart';
import 'package:expense_tracker/widgets/charts/ring_chart.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:flutter/material.dart';

/// "Where it went": a donut of the month's categories with the total in
/// the middle, and every category listed under it with its amount and
/// share, so nothing depends on telling colours apart.
class CategoryDonutCard extends StatelessWidget {
  /// Creates the card.
  const new({required this.total, required this.categories, super.key});

  /// Spent in the month.
  final Money total;

  /// Categories, largest first.
  final List<CategoryTotal> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final styles = AppTextStyles.of(context);
    final textTheme = Theme.of(context).textTheme;
    final totalText = Text(
      formatMoney(total),
      textAlign: TextAlign.center,
      style: styles.statValue.copyWith(color: colors.onSurface),
    );
    // Large text would not fit inside the ring: it moves under it.
    final inside =
        MediaQuery.textScalerOf(context).scale(1) <= metrics.stackedTextScale;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.statsWhereItWent, style: textTheme.titleMedium),
          ),
          SizedBox(height: metrics.spaceLg),
          Center(
            child: Semantics(
              container: true,
              label: l10n.statsDonutSemantics(formatMoney(total)),
              child: RingChart(
                segments: [
                  for (final c in categories)
                    (
                      value: c.spent.paise.toDouble(),
                      color: categoryStyle(context, c.category?.iconKey).color,
                    ),
                ],
                size: metrics.donutSize,
                stroke: metrics.donutStroke,
                trackColor: colors.surfaceSunken,
                center: inside ? ExcludeSemantics(child: totalText) : null,
              ),
            ),
          ),
          if (!inside) ...[
            SizedBox(height: metrics.spaceSm),
            ExcludeSemantics(child: totalText),
          ],
          SizedBox(height: metrics.spaceLg),
          for (final c in categories)
            _LegendRow(
              key: ValueKey(c.category?.id),
              total: c,
              name: c.category?.name ?? l10n.uncategorised,
            ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const new({required this.total, required this.name, super.key});

  final CategoryTotal total;
  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final style = categoryStyle(context, total.category?.iconKey);
    final amount = formatMoney(total.spent);
    final percent = (total.share * 100).round();
    final textTheme = Theme.of(context).textTheme;
    // Large text: the share and amount move under the name, never cut.
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) >= metrics.stackedTextScale;
    final share = Text(l10n.statsShare(percent), style: textTheme.bodySmall);
    final money = Text(
      amount,
      style: AppTextStyles.of(context).amountRow
          .copyWith(color: colors.onSurface),
    );
    return Semantics(
      container: true,
      label: l10n.statsCategorySemantics(name, amount, percent),
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: metrics.spaceXs),
          child: Row(
            children: [
              IconTile(icon: style.icon, color: style.color),
              SizedBox(width: metrics.spaceMd),
              Expanded(
                child: stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: textTheme.bodyLarge),
                          money,
                          share,
                        ],
                      )
                    : Text(name, style: textTheme.bodyLarge),
              ),
              if (!stacked) ...[
                SizedBox(width: metrics.spaceSm),
                share,
                SizedBox(width: metrics.spaceMd),
                money,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
