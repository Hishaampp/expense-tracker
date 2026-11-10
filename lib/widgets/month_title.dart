import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// A large title that names a month and opens the month picker when tapped.
class MonthTitle extends StatelessWidget {
  /// Creates the title.
  const new({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    super.key,
  });

  /// The month shown, for example "November".
  final String label;

  /// What a screen reader announces, for example "Change month, November".
  final String semanticLabel;

  /// Opens the month picker.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    return Semantics(
      button: true,
      header: true,
      label: semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Pressable(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(metrics.radiusTileLarge),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(label)),
              SizedBox(width: metrics.spaceXs),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.of(context).accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
