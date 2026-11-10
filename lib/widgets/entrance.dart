import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Fades [child] in and lets it rise into place the first time it is built.
/// Items with a higher [index] start a little later, so a screen's cards
/// arrive one after another. Plays once per mount; nothing under reduced
/// motion.
class Entrance extends StatefulWidget {
  /// Creates the entrance for the item at [index] in its group.
  const new({required this.child, this.index = 0, super.key});

  /// Position in the staggered group; capped so late items do not wait.
  final int index;

  /// The content.
  final Widget child;

  /// Items after this many enter together with the last staggered one.
  static const int maxStagger = 6;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  late Animation<double> _progress;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final motion = AppMotion.of(context);
    if (reducesMotion(context)) {
      _controller.value = 1;
      _progress = _controller;
      return;
    }
    final steps = widget.index.clamp(0, Entrance.maxStagger);
    final delay = motion.stagger * steps;
    final total = delay + motion.slow;
    _controller.duration = total;
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: motion.enter,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offset = AppMetrics.of(context).entranceOffset;
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) => Opacity(
        opacity: _progress.value,
        child: Transform.translate(
          offset: Offset(0, offset * (1 - _progress.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
