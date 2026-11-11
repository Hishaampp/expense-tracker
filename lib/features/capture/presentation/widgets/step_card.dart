import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// One numbered setup step: the number in a circle, a heading, the
/// instruction, and optional content below (a button, a test field).
class StepCard extends StatelessWidget {
  /// Creates the step.
  const new({
    required this.number,
    required this.numberLabel,
    required this.title,
    required this.body,
    this.child,
    super.key,
  });

  /// The step's position (the steps are a real sequence).
  final int number;

  /// What a screen reader says for the number, for example "Step 1".
  final String numberLabel;

  /// The heading.
  final String title;

  /// The instruction.
  final String body;

  /// Optional content under the instruction.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final child = this.child;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            container: true,
            label: numberLabel,
            child: ExcludeSemantics(
              child: SizedBox.square(
                dimension: metrics.iconTileSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accentFill,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.onAccentFill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: metrics.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: textTheme.titleMedium),
                ),
                SizedBox(height: metrics.spaceXs),
                Text(body, style: textTheme.bodyMedium),
                if (child != null) ...[
                  SizedBox(height: metrics.spaceMd),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
