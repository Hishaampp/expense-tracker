import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// A labelled group of settings rows in one card.
class SettingsGroup extends StatelessWidget {
  /// Creates the group.
  const new({required this.label, required this.rows, super.key});

  /// The group's name, above the card.
  final String label;

  /// The rows, top to bottom.
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: metrics.spaceXs,
            vertical: metrics.spaceSm,
          ),
          child: Semantics(
            header: true,
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        AppCard(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: metrics.spaceLg,
            vertical: metrics.spaceSm,
          ),
          child: Column(
            children: [
              for (final (index, row) in rows.indexed) ...[
                if (index > 0) const Divider(),
                row,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
