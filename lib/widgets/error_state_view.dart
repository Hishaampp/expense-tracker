import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';

/// Shown when a screen could not load. Always offers a way forward.
class ErrorStateView extends StatelessWidget {
  /// Creates the view.
  const new({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  /// What went wrong, already localized.
  final String message;

  /// Label of the action button, for example "Try again".
  final String actionLabel;

  /// Called when the action button is pressed.
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: metrics.spaceXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: AppColors.of(context).danger),
          SizedBox(height: metrics.spaceSm),
          Semantics(
            liveRegion: true,
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: metrics.spaceLg),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
