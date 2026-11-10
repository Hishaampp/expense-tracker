import 'dart:math' as math;

import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Shakes [child] sideways once each time [trigger] changes, to show that
/// input was not accepted. Does nothing under reduced motion; the caller
/// always shows a message as well.
class Shake extends StatefulWidget {
  /// Creates the wrapper.
  const new({required this.trigger, required this.child, super.key});

  /// Change this value to shake once.
  final int trigger;

  /// The content.
  final Widget child;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void didUpdateWidget(Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger == widget.trigger || reducesMotion(context)) return;
    _controller
      ..duration = AppMotion.of(context).medium
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distance = AppMetrics.of(context).shakeDistance;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Three swings that die away.
        final dx = math.sin(t * math.pi * 6) * distance * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
