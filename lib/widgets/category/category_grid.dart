import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/category/category_tile.dart';
import 'package:expense_tracker/widgets/category_style.dart';
import 'package:flutter/material.dart';

/// Category tiles in rows of four, optionally ending with a "More" tile.
class CategoryGrid extends StatelessWidget {
  /// Creates the grid.
  const new({
    required this.categories,
    required this.selectedId,
    required this.selectedLabel,
    required this.onPick,
    this.moreLabel,
    this.onMore,
    super.key,
  });

  /// Tiles per row.
  static const int columns = 4;

  /// The categories to show.
  final List<Category> categories;

  /// The chosen category, or null.
  final String? selectedId;

  /// Screen-reader word for the chosen tile.
  final String selectedLabel;

  /// Called with the id of the tile tapped.
  final ValueChanged<String> onPick;

  /// Label of the trailing "More" tile; null hides it.
  final String? moreLabel;

  /// Called when "More" is tapped.
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final moreLabel = this.moreLabel;
    final onMore = this.onMore;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth / columns;
        final more = categoryStyle(context, 'more');
        return Wrap(
          runSpacing: metrics.spaceSm,
          children: [
            for (final category in categories)
              SizedBox(
                key: ValueKey(category.id),
                width: width,
                child: Builder(
                  builder: (context) {
                    final style = categoryStyle(context, category.iconKey);
                    return CategoryTile(
                      icon: style.icon,
                      color: style.color,
                      label: category.name,
                      selected: category.id == selectedId,
                      selectedLabel: selectedLabel,
                      onTap: () => onPick(category.id),
                    );
                  },
                ),
              ),
            if (moreLabel != null && onMore != null)
              SizedBox(
                width: width,
                child: CategoryTile(
                  icon: more.icon,
                  color: more.color,
                  label: moreLabel,
                  onTap: onMore,
                ),
              ),
          ],
        );
      },
    );
  }
}
