import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// The amount being typed, with a hint or an error line beneath it.
class AmountDisplay extends StatelessWidget {
  /// Creates the display.
  const new({
    required this.amountText,
    required this.semanticLabel,
    this.helperText,
    this.errorText,
    super.key,
  });

  /// The formatted amount as typed.
  final String amountText;

  /// What a screen reader announces for the amount.
  final String semanticLabel;

  /// Guidance shown under the amount, or null for none.
  final String? helperText;

  /// A save failure; replaces [helperText] and is announced.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final errorText = this.errorText;
    final helperText = this.helperText;
    final metrics = AppMetrics.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: semanticLabel,
          liveRegion: true,
          child: ExcludeSemantics(
            child: Text(
              amountText,
              textAlign: TextAlign.center,
              style: AppTextStyles.of(context).amountHero
                  .copyWith(color: colors.onSurface),
            ),
          ),
        ),
        if (errorText != null)
          Semantics(
            liveRegion: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: colors.danger),
                SizedBox(width: metrics.spaceSm),
                Flexible(
                  child: Text(
                    errorText,
                    style: textTheme.bodySmall?.copyWith(color: colors.danger),
                  ),
                ),
              ],
            ),
          )
        else if (helperText != null)
          Text(
            helperText,
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
