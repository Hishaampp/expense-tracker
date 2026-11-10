import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// A small rounded pill with an icon and a label, such as "Today". Static
/// when [onTap] is null.
class PillButton extends StatelessWidget {
  /// Creates the pill.
  const new({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    this.onTap,
    super.key,
  });

  /// The glyph.
  final IconData icon;

  /// The visible text.
  final String label;

  /// What a screen reader announces.
  final String semanticLabel;

  /// Called when tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: colors.surfaceSunken,
          shape: const StadiumBorder(),
          child: Pressable(
            onTap: onTap,
            shape: const StadiumBorder(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: metrics.minTapTarget),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: metrics.spaceLg,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: metrics.iconSize, color: colors.accent),
                    SizedBox(width: metrics.spaceSm),
                    Flexible(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
