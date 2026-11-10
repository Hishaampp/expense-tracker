import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/widgets/money_tone.dart';
import 'package:flutter/material.dart';

/// One ruled passbook row: icon, title and supporting line on the start
/// side, the amount in a right-hand column.
class LedgerRow extends StatelessWidget {
  /// Creates a row. [semanticLabel] is the whole row as a screen reader
  /// should say it, for example "₹340 spent at Swiggy, Food".
  const new({
    required this.icon,
    required this.title,
    required this.amountText,
    required this.semanticLabel,
    this.subtitle,
    this.tone = MoneyTone.spent,
    this.onTap,
    super.key,
  });

  /// Leading icon; its shape differs per state.
  final IconData icon;

  /// Main line, for example the payee or category.
  final String title;

  /// Supporting line under [title].
  final String? subtitle;

  /// The formatted amount.
  final String amountText;

  /// Colour reinforcement for [amountText].
  final MoneyTone tone;

  /// What a screen reader announces for the row.
  final String semanticLabel;

  /// Called when the row is tapped; null makes the row static.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final toneColor = tone.colorIn(colors);
    final subtitle = this.subtitle;
    // At large text sizes the amount moves under the title, so neither is
    // squeezed or cut off.
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) >= metrics.stackedTextScale;
    final titleStyle = textTheme.bodyLarge?.copyWith(
      color: tone == MoneyTone.transfer ? toneColor : colors.onSurface,
    );
    final amount = Text(
      amountText,
      textAlign: TextAlign.end,
      style: AppTextStyles.of(context).amountRow.copyWith(color: toneColor),
    );
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: metrics.minTapTarget),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: metrics.spaceSm,
              ),
              child: Row(
                crossAxisAlignment: stacked
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: toneColor),
                  SizedBox(width: metrics.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: titleStyle),
                        if (subtitle != null)
                          Text(subtitle, style: textTheme.bodySmall),
                        if (stacked)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: amount,
                          ),
                      ],
                    ),
                  ),
                  if (!stacked) ...[SizedBox(width: metrics.spaceMd), amount],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
