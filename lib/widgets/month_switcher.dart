import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';

/// Steps between months: ‹ November 2026 ›.
class MonthSwitcher extends StatelessWidget {
  /// Creates the switcher.
  const new({
    required this.label,
    required this.previousLabel,
    required this.nextLabel,
    required this.onPrevious,
    required this.onNext,
    this.trailing,
    super.key,
  });

  /// The month shown, for example "November 2026".
  final String label;

  /// Screen-reader label of the back arrow.
  final String previousLabel;

  /// Screen-reader label of the forward arrow.
  final String nextLabel;

  /// Called to go one month back.
  final VoidCallback onPrevious;

  /// Called to go one month forward; null disables the arrow.
  final VoidCallback? onNext;

  /// Optional control at the end, such as the review badge.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final trailing = this.trailing;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: metrics.minTapTarget),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            tooltip: previousLabel,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            tooltip: nextLabel,
            icon: const Icon(Icons.chevron_right),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
