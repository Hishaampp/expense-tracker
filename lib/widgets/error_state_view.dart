import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:flutter/material.dart';

/// A card shown when something could not load or no longer exists. Always
/// offers a way forward.
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
    return AppCard(
      padding: EdgeInsetsDirectional.all(metrics.spaceXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTile(
            icon: Icons.error_outline_rounded,
            color: CategoryColors.of(context).red,
            large: true,
          ),
          SizedBox(height: metrics.spaceLg),
          Semantics(
            liveRegion: true,
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: metrics.spaceXl),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
