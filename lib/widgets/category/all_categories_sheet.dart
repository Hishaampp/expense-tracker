import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/widgets/category/category_grid.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';

/// Every expense category. Pops with the chosen id, or null when dismissed.
class AllCategoriesSheet extends StatelessWidget {
  /// Creates the sheet.
  const new({
    required this.title,
    required this.categories,
    required this.selectedId,
    required this.selectedLabel,
    super.key,
  });

  /// Heading of the sheet.
  final String title;

  /// The categories, in the order to show.
  final List<Category> categories;

  /// The chosen category, or null.
  final String? selectedId;

  /// Screen-reader word for the chosen tile.
  final String selectedLabel;

  @override
  Widget build(BuildContext context) {
    return SheetFrame(
      title: title,
      spreadContent: true,
      child: CategoryGrid(
        categories: categories,
        selectedId: selectedId,
        selectedLabel: selectedLabel,
        onPick: (id) => Navigator.of(context).pop(id),
      ),
    );
  }
}
