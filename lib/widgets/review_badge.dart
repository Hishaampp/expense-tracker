import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/floating_shadow.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// A floating pill saying how many payments wait for review, with an icon
/// and the words (not colour alone). Opens the review inbox.
class ReviewBadge extends StatelessWidget {
  /// Creates the badge.
  const new({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    super.key,
  });

  /// The visible words, for example "3 to review".
  final String label;

  /// What a screen reader announces.
  final String semanticLabel;

  /// Opens the review inbox.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Center(
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: colors.reviewContainer,
              shape: const StadiumBorder(),
              shadows: floatingShadow(context),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Pressable(
                onTap: onTap,
                shape: const StadiumBorder(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: metrics.minTapTarget),
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: metrics.spaceLg,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: metrics.iconSize,
                          color: colors.review,
                        ),
                        SizedBox(width: metrics.spaceSm),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: colors.review),
                        ),
                      ],
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
