import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// The month's income: an arrow, the "Money in" label and a signed amount.
class MoneyInTotal extends StatelessWidget {
  /// Creates the total.
  const new({
    required this.label,
    required this.amountText,
    required this.semanticLabel,
    super.key,
  });

  /// Caption, "Money in".
  final String label;

  /// The formatted amount, with its "+" sign.
  final String amountText;

  /// What a screen reader announces.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        // Wraps the amount onto its own line when the two do not fit.
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: metrics.spaceMd,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.south_west, color: colors.moneyIn),
                SizedBox(width: metrics.spaceSm),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            Text(
              amountText,
              style: AppTextStyles.of(context).amountLarge
                  .copyWith(color: colors.moneyIn),
            ),
          ],
        ),
      ),
    );
  }
}
