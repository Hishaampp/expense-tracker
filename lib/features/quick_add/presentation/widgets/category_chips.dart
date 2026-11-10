import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/category_icon.dart';
import 'package:flutter/material.dart';

/// The category picker: a wrapping set of chips.
class CategoryChips extends StatelessWidget {
  /// Creates the chips for [categories].
  const new({
    required this.categories,
    required this.selectedId,
    required this.onPick,
    super.key,
  });

  /// The categories to offer.
  final List<Category> categories;

  /// The selected category id, or null. Marked with a tick, not colour only.
  final String? selectedId;

  /// Called with the id of the chip tapped.
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    return Wrap(
      spacing: metrics.spaceSm,
      children: [
        for (final category in categories)
          ChoiceChip(
            key: ValueKey(category.id),
            avatar: category.id == selectedId
                ? null
                : Icon(categoryIcon(category.iconKey)),
            label: Text(category.name),
            selected: category.id == selectedId,
            onSelected: (_) => onPick(category.id),
          ),
      ],
    );
  }
}
