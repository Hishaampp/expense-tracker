import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// A rounded progress bar that grows to [fraction] when it appears or
/// changes. Decorative: the row beside it says the number.
class GrowingBar extends StatelessWidget {
  /// Creates the bar.
  const new({
    required this.fraction,
    required this.color,
    required this.trackColor,
    super.key,
  });

  /// How full the bar is, 0–1 (values outside are clamped).
  final double fraction;

  /// The filled part.
  final Color color;

  /// The empty part.
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final motion = AppMotion.of(context);
    final radius = BorderRadius.circular(metrics.progressHeight);
    return ExcludeSemantics(
      child: SizedBox(
        height: metrics.progressHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(color: trackColor, borderRadius: radius),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: fraction.clamp(0, 1)),
            duration: resolveMotion(context, motion.slow),
            curve: motion.enter,
            builder: (context, value, _) => FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: value,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, borderRadius: radius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
