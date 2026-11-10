import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/widgets/shake.dart';
import 'package:flutter/material.dart';

/// The amount being typed, large. Each change slides the new amount up into
/// place; a rejected save shakes it.
class AmountDisplay extends StatelessWidget {
  /// Creates the display.
  const new({
    required this.amountText,
    required this.semanticLabel,
    required this.rejectCount,
    super.key,
  });

  /// The formatted amount as typed.
  final String amountText;

  /// What a screen reader announces for the amount.
  final String semanticLabel;

  /// Bumped on each rejected save; each bump shakes once.
  final int rejectCount;

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    final offset = AppMetrics.of(context).entranceOffset;
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Shake(
          trigger: rejectCount,
          child: AnimatedSwitcher(
            duration: resolveMotion(context, motion.quick),
            switchInCurve: motion.enter,
            switchOutCurve: motion.exit,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, offset * (1 - animation.value)),
                  child: child,
                ),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.center,
              children: [...previous, ?current],
            ),
            child: Text(
              amountText,
              key: ValueKey(amountText),
              textAlign: TextAlign.center,
              style: AppTextStyles.of(context).amountDisplay
                  .copyWith(color: AppColors.of(context).onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
