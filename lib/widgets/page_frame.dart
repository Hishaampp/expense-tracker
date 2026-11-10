import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/widgets.dart';

/// Insets page content from the system bars and screen edges, and caps its
/// width on tablets and foldables.
class PageFrame extends StatelessWidget {
  /// Frames [child].
  const new({required this.child, super.key});

  /// The page content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: metrics.readableWidth),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: metrics.spaceLg,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
