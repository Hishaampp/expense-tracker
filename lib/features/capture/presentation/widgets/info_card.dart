import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// A card with a heading, a paragraph or two, and optional buttons below.
class InfoCard extends StatelessWidget {
  /// Creates the card.
  const new({
    required this.title,
    required this.body,
    this.extra,
    this.actions = const [],
    super.key,
  });

  /// The heading.
  final String title;

  /// The main text.
  final String body;

  /// A second, quieter paragraph.
  final String? extra;

  /// Buttons, top to bottom.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final extra = this.extra;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: textTheme.titleMedium),
          ),
          SizedBox(height: metrics.spaceSm),
          Text(body, style: textTheme.bodyMedium),
          if (extra != null) ...[
            SizedBox(height: metrics.spaceSm),
            Text(extra, style: textTheme.bodySmall),
          ],
          for (final action in actions) ...[
            SizedBox(height: metrics.spaceMd),
            action,
          ],
        ],
      ),
    );
  }
}
