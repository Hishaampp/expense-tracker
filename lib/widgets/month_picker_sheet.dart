import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';

/// A month the picker offers: how many months back, and its name.
typedef MonthChoice = ({int offset, String label});

/// Lists recent months, newest first. Pops with the chosen offset, or null
/// when dismissed.
class MonthPickerSheet extends StatelessWidget {
  /// Creates the sheet.
  const new({
    required this.title,
    required this.choices,
    required this.selectedOffset,
    super.key,
  });

  /// Heading of the sheet.
  final String title;

  /// The months to offer.
  final List<MonthChoice> choices;

  /// The month shown now; marked with a tick.
  final int selectedOffset;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SheetFrame(
      title: title,
      child: Column(
        children: [
          for (final choice in choices)
            Semantics(
              button: true,
              selected: choice.offset == selectedOffset,
              label: choice.label,
              onTap: () => Navigator.of(context).pop(choice.offset),
              child: ExcludeSemantics(
                child: Pressable(
                  onTap: () => Navigator.of(context).pop(choice.offset),
                  shape: const StadiumBorder(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: metrics.minTapTarget,
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: metrics.spaceLg,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              choice.label,
                              style: textTheme.bodyLarge,
                            ),
                          ),
                          if (choice.offset == selectedOffset)
                            Icon(Icons.check_rounded, color: colors.accent),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Opens the month picker and returns the chosen offset, or null when the
/// sheet is dismissed.
Future<int?> showMonthPickerSheet(
  BuildContext context, {
  required String title,
  required List<MonthChoice> choices,
  required int selectedOffset,
}) {
  return showAppSheet<int>(
    context,
    MonthPickerSheet(
      title: title,
      choices: choices,
      selectedOffset: selectedOffset,
    ),
  );
}
