import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// A white card with large rounded corners. Cards are separated by space,
/// never by lines.
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
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(metrics.radiusCard),
    );
    return Material(
      color: AppColors.of(context).surface,
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
    );
  }
}
