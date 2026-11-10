import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';

/// Shown when a screen or region has nothing yet. Offers the next action.
class EmptyStateView extends StatelessWidget {
  /// Creates the view.
  const new({
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// What is missing, for example "No expenses yet".
  final String title;

  /// One supporting sentence.
  final String? body;

  /// Label of the action button.
  final String? actionLabel;

  /// Called when the action button is pressed.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final body = this.body;
    final actionLabel = this.actionLabel;
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: metrics.spaceXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
          if (body != null) ...[
            SizedBox(height: metrics.spaceSm),
            Text(body, style: textTheme.bodySmall, textAlign: TextAlign.center),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: metrics.spaceLg),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }
}
