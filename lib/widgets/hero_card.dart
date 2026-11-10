import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';

/// The one dark card that opens a screen and states its key number.
class HeroCard extends StatelessWidget {
  /// Creates the card around [child].
  const new({required this.child, super.key});

  /// The card's content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    return Material(
      color: colors.hero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(metrics.radiusCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.onHero),
        child: IconTheme.merge(
          data: IconThemeData(color: colors.onHero),
          child: Padding(
            padding: EdgeInsetsDirectional.all(metrics.spaceXl),
            child: child,
          ),
        ),
      ),
    );
  }
}
