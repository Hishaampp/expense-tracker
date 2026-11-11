import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// One choice in a row of pills. The chosen pill is filled and shows a
/// tick, so it stands out by shape as well as colour.
class ChoicePill extends StatelessWidget {
  /// Creates the pill.
  const new({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.semanticLabel,
    super.key,
  });

  /// The visible text.
  final String label;

  /// Whether this is the current choice.
  final bool selected;

  /// Chooses it.
  final VoidCallback onTap;

  /// A glyph shown while not selected.
  final IconData? icon;

  /// What a screen reader says, when [label] is not enough.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final foreground = selected ? colors.onAccentFill : colors.onSurface;
    final glyph = selected ? Icons.check_rounded : icon;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: selected ? colors.accentFill : colors.surfaceSunken,
          shape: const StadiumBorder(),
          child: Pressable(
            onTap: onTap,
            shape: const StadiumBorder(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: metrics.minTapTarget,
                minWidth: metrics.minTapTarget,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: metrics.spaceMd,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (glyph != null) ...[
                      Icon(glyph, size: metrics.iconSize, color: foreground),
                      SizedBox(width: metrics.spaceSm),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: foreground),
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
