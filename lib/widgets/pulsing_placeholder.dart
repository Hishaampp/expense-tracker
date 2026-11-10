import 'dart:async';

import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Placeholder blocks shown while a screen loads: a hero-sized block and a
/// card. Stays blank briefly so a fast load does not flash, then pulses
/// softly (static under reduced motion; stops when off screen).
class PulsingPlaceholder extends StatefulWidget {
  /// Creates the placeholder, announced as [semanticLabel].
  const new({required this.semanticLabel, super.key});

  /// What a screen reader says, for example "Loading".
  final String semanticLabel;

  @override
  State<PulsingPlaceholder> createState() => _PulsingPlaceholderState();
}

class _PulsingPlaceholderState extends State<PulsingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this);
  Timer? _delay;
  bool _visible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = AppMotion.of(context);
    _delay ??= Timer(motion.medium, () {
      if (!mounted) return;
      setState(() => _visible = true);
      if (reducesMotion(context)) {
        _pulse.value = 1;
      } else {
        _pulse
          ..duration = motion.pulse
          ..repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final radius = BorderRadius.circular(metrics.radiusCard);
    Widget block(double height) => SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: radius,
        ),
      ),
    );
    return Semantics(
      label: widget.semanticLabel,
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.55, end: 1).animate(_pulse),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              block(metrics.iconTileLargeSize * 3),
              SizedBox(height: metrics.spaceMd),
              block(metrics.iconTileLargeSize * 2),
            ],
          ),
        ),
      ),
    );
  }
}
