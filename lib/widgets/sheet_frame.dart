import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';

/// The frame every bottom sheet uses: a heading, an optional line under it,
/// then [child]. Keeps sheet spacing the same everywhere.
class SheetFrame extends StatelessWidget {
  /// Creates the frame.
  const new({
    required this.title,
    required this.child,
    this.subtitle,
    this.spreadContent = false,
    super.key,
  });

  /// The sheet's heading.
  final String title;

  /// One supporting line under the heading.
  final String? subtitle;

  /// The sheet's content.
  final Widget child;

  /// Whether [child] lines up with the heading (grids) rather than sitting
  /// slightly wider so its rows' highlights reach the edge (lists).
  final bool spreadContent;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final subtitle = this.subtitle;
    final edge = spreadContent ? metrics.spaceXl : metrics.spaceSm;
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.only(bottom: metrics.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: metrics.spaceXl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: textTheme.titleMedium),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: metrics.spaceXs),
                    Text(subtitle, style: textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            SizedBox(height: metrics.spaceMd),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.symmetric(horizontal: edge),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens [sheet] as a bottom sheet that can grow to fit its content, and
/// returns what it pops (null when dismissed).
Future<T?> showAppSheet<T>(BuildContext context, Widget sheet) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (_) => sheet,
  );
}
