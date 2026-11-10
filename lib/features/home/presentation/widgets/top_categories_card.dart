import 'package:expense_tracker/features/home/presentation/home_notifier.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/category_style.dart';
import 'package:expense_tracker/widgets/growing_bar.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:flutter/material.dart';

/// The month's largest categories, each with a bar for its share.
class TopCategoriesCard extends StatelessWidget {
  /// Creates the card for [totals].
  const new({required this.totals, super.key});

  /// The categories to show, largest first.
  final List<CategoryTotal> totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.homeTopCategories,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(height: metrics.spaceSm),
          for (final total in totals)
            _CategoryLine(
              key: ValueKey(total.category?.id),
              total: total,
              name: total.category?.name ?? l10n.uncategorised,
            ),
        ],
      ),
    );
  }
}

class _CategoryLine extends StatelessWidget {
  const new({required this.total, required this.name, super.key});

  final CategoryTotal total;
  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final style = categoryStyle(context, total.category?.iconKey);
    final amount = formatMoney(total.spent);
    return Semantics(
      container: true,
      label: l10n.categorySpentSemantics(amount, name),
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: metrics.spaceSm),
          child: Row(
            children: [
              IconTile(icon: style.icon, color: style.color),
              SizedBox(width: metrics.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: metrics.spaceXs),
                    GrowingBar(
                      fraction: total.share,
                      color: style.color,
                      trackColor: colors.surfaceSunken,
                    ),
                  ],
                ),
              ),
              SizedBox(width: metrics.spaceMd),
              Text(
                amount,
                style: AppTextStyles.of(context).amountRow
                    .copyWith(color: colors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
