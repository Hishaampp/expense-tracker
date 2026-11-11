import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';

/// One choice in an [OptionSheet]. A null value means "any".
typedef SheetOption = ({String? value, String label, IconData? icon});

/// What an [OptionSheet] pops: the value chosen (null for "any"). The
/// sheet pops null itself when dismissed.
typedef OptionPick = ({String? value});

/// A list of choices, the current one ticked.
class OptionSheet extends StatelessWidget {
  /// Creates the sheet.
  const new({
    required this.title,
    required this.options,
    required this.selected,
    this.subtitle,
    super.key,
  });

  /// One supporting line under the heading.
  final String? subtitle;

  /// The sheet's heading.
  final String title;

  /// The choices, in order.
  final List<SheetOption> options;

  /// The value chosen now.
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    return SheetFrame(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: [
          for (final option in options)
            Semantics(
              button: true,
              selected: option.value == selected,
              label: option.label,
              onTap: () =>
                  Navigator.of(context).pop<OptionPick>((value: option.value)),
              child: ExcludeSemantics(
                child: Pressable(
                  onTap: () =>
                      Navigator.of(context)
                          .pop<OptionPick>((value: option.value)),
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
                          if (option.icon case final icon?) ...[
                            Icon(icon, color: colors.onSurfaceMuted),
                            SizedBox(width: metrics.spaceMd),
                          ],
                          Expanded(
                            child: Text(
                              option.label,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          if (option.value == selected)
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
