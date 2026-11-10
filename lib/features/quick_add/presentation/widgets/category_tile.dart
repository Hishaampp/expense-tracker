import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// A large category tile with its name under it. When selected it grows a
/// little and its name turns accent and bold, with a tick for screen
/// readers.
class CategoryTile extends StatelessWidget {
  /// Creates the tile.
  const new({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.selectedLabel,
    super.key,
  });

  /// The glyph.
  final IconData icon;

  /// The tile's fill.
  final Color color;

  /// The category name.
  final String label;

  /// Called when tapped.
  final VoidCallback onTap;

  /// Whether this is the chosen category.
  final bool selected;

  /// Screen-reader word added when [selected], for example "selected".
  final String? selectedLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final motion = AppMotion.of(context);
    final textTheme = Theme.of(context).textTheme;
    final selectedLabel = this.selectedLabel;
    return Semantics(
      button: true,
      selected: selected,
      label: selected && selectedLabel != null
          ? '$label, $selectedLabel'
          : label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Pressable(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(metrics.radiusTileLarge),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: metrics.spaceXs),
            child: Column(
              children: [
                AnimatedScale(
                  scale: selected && !reducesMotion(context)
                      ? 1 / metrics.pressedScale
                      : 1,
                  duration: resolveMotion(context, motion.quick),
                  curve: motion.pop,
                  child: IconTile(icon: icon, color: color, large: true),
                ),
                SizedBox(height: metrics.spaceXs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium?.copyWith(
                    color: selected ? colors.accentText : colors.onSurface,
                    fontWeight: selected
                        ? textTheme.titleMedium?.fontWeight
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
