import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';

/// A titled block of rows: the title, a heavy rule, then [rows] separated
/// by hairlines.
class LedgerSection extends StatelessWidget {
  /// Creates a section titled [title] holding [rows].
  const new({
    required this.title,
    required this.rows,
    this.trailing,
    super.key,
  });

  /// Section heading.
  final String title;

  /// The rows, top to bottom.
  final List<Widget> rows;

  /// Optional control at the end of the heading line, such as "See all".
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final trailing = this.trailing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        SizedBox(height: metrics.spaceXs),
        SizedBox(
          height: metrics.ruleWidth,
          child: ColoredBox(color: colors.rule),
        ),
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) const Divider(),
          row,
        ],
        const Divider(),
      ],
    );
  }
}
