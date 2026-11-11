import 'dart:math' as math;

import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/theme/chart_style.dart';
import 'package:flutter/material.dart';

/// Vertical bars, one per value, scaled to the largest, growing up from a
/// baseline when they appear (instantly under reduced motion). The bar at
/// [highlight] uses [highlightColor]; the rest use [color]. An optional
/// [guide] draws a dashed line at that value, for example an average.
///
/// Decorative: hidden from screen readers. The caller labels it with a
/// summary and shows the key numbers as text.
class BarChart extends StatelessWidget {
  /// Creates the chart.
  const new({
    required this.values,
    required this.color,
    required this.highlightColor,
    required this.guideColor,
    this.highlight,
    this.guide,
    this.labels,
    super.key,
  });

  /// One value per bar. Negative values draw as zero.
  final List<double> values;

  /// Ordinary bars.
  final Color color;

  /// The highlighted bar.
  final Color highlightColor;

  /// The guide line.
  final Color guideColor;

  /// Index of the highlighted bar, if any.
  final int? highlight;

  /// Where the dashed guide line sits, in the same units as [values].
  final double? guide;

  /// Optional text under each bar (same length as [values]).
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final motion = AppMotion.of(context);
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final names = labels;
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: metrics.chartHeight,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: resolveMotion(context, motion.slow),
              curve: motion.enter,
              builder: (context, progress, _) => CustomPaint(
                painter: _BarPainter(
                  values: values,
                  color: color,
                  highlightColor: highlightColor,
                  guideColor: guideColor,
                  highlight: highlight,
                  guide: guide,
                  radius: metrics.chartBarRadius,
                  gapRatio: values.length > ChartStyle.denseBarCount
                      ? ChartStyle.denseBarGap
                      : ChartStyle.barGap,
                  hairline: metrics.hairlineWidth,
                  progress: progress,
                ),
              ),
            ),
          ),
          if (names != null && names.length == values.length) ...[
            SizedBox(height: metrics.spaceXs),
            Row(
              children: [
                for (var i = 0; i < names.length; i++)
                  Expanded(
                    child: Text(
                      names[i],
                      textAlign: TextAlign.center,
                      style: labelStyle?.copyWith(
                        fontWeight: i == highlight
                            ? ChartStyle.highlightWeight
                            : labelStyle.fontWeight,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  new({
    required this.values,
    required this.color,
    required this.highlightColor,
    required this.guideColor,
    required this.highlight,
    required this.guide,
    required this.radius,
    required this.gapRatio,
    required this.hairline,
    required this.progress,
  });

  final List<double> values;
  final Color color;
  final Color highlightColor;
  final Color guideColor;
  final int? highlight;
  final double? guide;
  final double radius;
  final double gapRatio;
  final double hairline;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final top = values.fold<double>(0, math.max);
    final peak = math.max(top, guide ?? 0);
    final slot = size.width / values.length;
    final barWidth = slot * (1 - gapRatio);
    final paint = Paint();
    for (var i = 0; i < values.length; i++) {
      final value = math.max(0, values[i]).toDouble();
      final height = peak <= 0 ? 0.0 : size.height * value / peak * progress;
      // Even an empty day leaves a sliver, so the row of days stays legible.
      final drawn = math.max(height, hairline * 2);
      final left = slot * i + (slot - barWidth) / 2;
      final rect = Rect.fromLTWH(left, size.height - drawn, barWidth, drawn);
      paint.color = i == highlight ? highlightColor : color;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
        paint,
      );
    }
    if (guide case final g? when peak > 0 && g > 0) {
      final y = size.height - size.height * g / peak * progress;
      final line = Paint()
        ..color = guideColor
        ..strokeWidth = hairline;
      final dash = hairline * ChartStyle.dashHairlines;
      for (var x = 0.0; x < size.width; x += dash * 2) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + dash, size.width), y),
          line,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.progress != progress ||
      old.values != values ||
      old.highlight != highlight ||
      old.guide != guide ||
      old.color != color ||
      old.highlightColor != highlightColor;
}
