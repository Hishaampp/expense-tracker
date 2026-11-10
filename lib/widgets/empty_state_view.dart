import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:flutter/material.dart';

/// A card shown when a screen or region has nothing yet. Offers the next
/// action when there is one.
class EmptyStateView extends StatelessWidget {
  /// Creates the view.
  const new({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Glyph of the tile at the top.
  final IconData icon;

  /// Fill of the tile, from `CategoryColors`.
  final Color iconColor;

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
    return AppCard(
      padding: EdgeInsetsDirectional.all(metrics.spaceXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTile(icon: icon, color: iconColor, large: true),
          SizedBox(height: metrics.spaceLg),
          Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
          if (body != null) ...[
            SizedBox(height: metrics.spaceSm),
            Text(body, style: textTheme.bodySmall, textAlign: TextAlign.center),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: metrics.spaceXl),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }
}
