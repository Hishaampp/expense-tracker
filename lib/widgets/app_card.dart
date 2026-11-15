import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// A white card (brand `surface-raised`): rounded corners, a fine `line`
/// border and a soft shadow, so it stands apart on a white page.
class AppCard extends StatelessWidget {
  /// Creates a card around [child].
  const new({required this.child, this.onTap, this.padding, super.key});

  /// The card's content.
  final Widget child;

  /// Makes the whole card tappable.
  final VoidCallback? onTap;

  /// Inner padding; defaults to the standard card padding.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(metrics.radiusGroup);
    // Brand: white cards on white, set apart by a line and a soft shadow.
    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: BorderSide(color: colors.hairline, width: metrics.hairlineWidth),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            offset: Offset(0, metrics.hairlineWidth),
            blurRadius: metrics.cardShadowNearBlur,
          ),
          BoxShadow(
            color: colors.cardShadowFar,
            offset: Offset(0, metrics.cardShadowOffset),
            blurRadius: metrics.cardShadowBlur,
          ),
        ],
      ),
      child: Material(
        color: colors.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: Pressable(
          onTap: onTap,
          shape: shape,
          child: Padding(
            padding: padding ?? EdgeInsetsDirectional.all(metrics.spaceLg),
            child: child,
          ),
        ),
      ),
    );
  }
}
