import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/widgets/money_tone.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// One row inside a card: a leading tile, a title with an optional
/// supporting line, and a trailing amount or value. At large text sizes the
/// trailing text moves under the title so nothing is cut off.
class InfoRow extends StatelessWidget {
  /// Creates a row. [semanticLabel] is the whole row as a screen reader
  /// should say it, for example "₹340 spent, Swiggy, Food".
  const new({
    required this.leading,
    required this.title,
    required this.semanticLabel,
    this.subtitle,
    this.trailingText,
    this.trailingIsAmount = true,
    this.tone = MoneyTone.spent,
    this.showChevron = false,
    this.onTap,
    super.key,
  });

  /// Leading tile.
  final Widget leading;

  /// Main line.
  final String title;

  /// Supporting line under [title].
  final String? subtitle;

  /// Trailing amount or value.
  final String? trailingText;

  /// Whether [trailingText] is money (bold, tabular) or a setting value.
  final bool trailingIsAmount;

  /// Colour reinforcement for a money [trailingText].
  final MoneyTone tone;

  /// Shows a chevron, for rows that open another screen or sheet.
  final bool showChevron;

  /// What a screen reader announces for the row.
  final String semanticLabel;

  /// Called when the row is tapped; null makes it static.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) >= metrics.stackedTextScale;
    final subtitle = this.subtitle;
    final trailingText = this.trailingText;
    final Widget? trailing = trailingText == null
        ? null
        : Text(
            trailingText,
            textAlign: TextAlign.end,
            style: trailingIsAmount
                ? AppTextStyles.of(context).amountRow
                      .copyWith(color: tone.colorIn(colors))
                : textTheme.bodyLarge?.copyWith(color: colors.accentText),
          );
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
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
                  leading,
                  SizedBox(width: metrics.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: textTheme.bodyLarge),
                        if (subtitle != null)
                          Text(subtitle, style: textTheme.bodySmall),
                        if (stacked && trailing != null)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: trailing,
                          ),
                      ],
                    ),
                  ),
                  if (!stacked && trailing != null) ...[
                    SizedBox(width: metrics.spaceMd),
                    trailing,
                  ],
                  if (showChevron) ...[
                    SizedBox(width: metrics.spaceXs),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.onSurfaceMuted,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
