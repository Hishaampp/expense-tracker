import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/floating_shadow.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// A round white button with an accent glyph that floats over content, such
/// as Add in the top corner.
class RoundIconButton extends StatelessWidget {
  /// Creates the button.
  const new({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.floating = true,
    this.color,
    this.badgeCount = 0,
    super.key,
  });

  /// The glyph.
  final IconData icon;

  /// Shown on long press and read by screen readers.
  final String tooltip;

  /// Called when pressed; null shows the button disabled.
  final VoidCallback? onPressed;

  /// Whether it floats (white with a shadow) or sits flat on a sheet.
  final bool floating;

  /// The glyph colour; defaults to the accent.
  final Color? color;

  /// A count shown on the button, for example unread notifications; hidden
  /// at zero. Say it in [tooltip] too: the badge is not announced.
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        onTap: onPressed,
        child: ExcludeSemantics(
          child: SizedBox.square(
            dimension: metrics.minTapTarget,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: floating ? colors.surface : colors.surfaceSunken,
                  shape: BoxShape.circle,
                  boxShadow: floating ? floatingShadow(context) : null,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Pressable(
                    onTap: onPressed,
                    shape: const CircleBorder(),
                    child: SizedBox.square(
                      dimension: metrics.roundButtonSize,
                      child: Badge.count(
                        count: badgeCount,
                        isLabelVisible: badgeCount > 0,
                        backgroundColor: colors.accent,
                        textColor: colors.onAccentFill,
                        child: Icon(
                          icon,
                          size: metrics.iconLargeSize,
                          color: enabled
                              ? (color ?? colors.accent)
                              : colors.onSurfaceMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
