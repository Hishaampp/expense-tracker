import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:flutter/material.dart';

/// A small coloured square holding a white glyph. Decorative: the row or
/// button around it carries the words.
class IconTile extends StatelessWidget {
  /// Creates a tile showing [icon] on [color].
  const new({
    required this.icon,
    required this.color,
    this.large = false,
    super.key,
  });

  /// The glyph.
  final IconData icon;

  /// The tile's fill, from `CategoryColors`.
  final Color color;

  /// The large size used for Quick Add categories.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final side = large ? metrics.iconTileLargeSize : metrics.iconTileSize;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: side,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
              large ? metrics.radiusTileLarge : metrics.radiusTile,
            ),
          ),
          child: Icon(
            icon,
            size: large ? metrics.iconLargeSize : metrics.iconSize,
            color: CategoryColors.of(context).onTile,
          ),
        ),
      ),
    );
  }
}
