import 'dart:math' as math;

import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// One slice of a [RingChart].
typedef RingSegment = ({double value, Color color});

/// A ring drawn clockwise from the top: one coloured arc per segment, in
/// order, over a track. Grows in when it appears (instantly under reduced
/// motion). Decorative: the screen beside it says the numbers, so it is
/// hidden from screen readers; wrap it to label it.
///
/// With a single segment and [total] set, it is a progress ring: the arc
/// covers value / total of the circle.
class RingChart extends StatelessWidget {
  /// Creates the ring.
  const new({
    required this.segments,
    required this.size,
    required this.stroke,
    required this.trackColor,
    this.total,
    this.center,
    super.key,
  });

  /// The arcs, in drawing order. Negative values count as zero.
  final List<RingSegment> segments;

  /// What a full circle stands for; defaults to the sum of [segments].
  final double? total;

  /// The ring's diameter.
  final double size;

  /// The ring's thickness.
  final double stroke;

  /// The empty part of the ring.
  final Color trackColor;

  /// Shown in the middle, for example a total.
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    // The centre content keeps clear of the ring by half a stroke.
    final inset = stroke * 1.5;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ExcludeSemantics(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: resolveMotion(context, motion.slow),
              curve: motion.enter,
              builder: (context, progress, _) => CustomPaint(
                size: Size.square(size),
                painter: _RingPainter(
                  segments: segments,
                  total: total,
                  stroke: stroke,
                  trackColor: trackColor,
                  progress: progress,
                ),
              ),
            ),
          ),
          if (center case final child?)
            Padding(padding: EdgeInsetsDirectional.all(inset), child: child),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  new({
    required this.segments,
    required this.total,
    required this.stroke,
    required this.trackColor,
    required this.progress,
  });

  final List<RingSegment> segments;
  final double? total;
  final double stroke;
  final Color trackColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, paint..color = trackColor);

    final values = [for (final s in segments) math.max(0, s.value).toDouble()];
    final sum = values.fold<double>(0, (a, b) => a + b);
    final whole = total ?? sum;
    if (whole <= 0) return;
    // A small gap between slices reads as separate pieces; none for a
    // single progress arc.
    final gap = segments.length > 1 ? stroke / (size.width / 2) * 0.35 : 0.0;
    var start = -math.pi / 2;
    final reach = math.pi * 2 * progress;
    for (var i = 0; i < segments.length; i++) {
      final sweep = math.min(values[i] / whole, 1) * math.pi * 2;
      final visible = math.min(sweep, reach - (start + math.pi / 2));
      if (visible <= 0) break;
      final drawn = math.max(0, visible - gap).toDouble();
      if (drawn > 0) {
        canvas.drawArc(
          arcRect,
          start + gap / 2,
          drawn,
          false,
          paint
            ..color = segments[i].color
            ..strokeCap = segments.length == 1
                ? StrokeCap.round
                : StrokeCap.butt,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.segments != segments ||
      old.total != total ||
      old.stroke != stroke ||
      old.trackColor != trackColor;
}
