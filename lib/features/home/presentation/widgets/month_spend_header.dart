import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// The month's spend as the one big number on Home.
class MonthSpendHeader extends StatelessWidget {
  /// Creates the header.
  const new({
    required this.label,
    required this.amountText,
    required this.semanticLabel,
    this.roomsNote,
    super.key,
  });

  /// Caption above the amount, "Spent this month".
  final String label;

  /// The formatted amount.
  final String amountText;

  /// "includes ₹X in Rooms", or null when no Room spending.
  final String? roomsNote;

  /// What a screen reader announces for the amount.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final roomsNote = this.roomsNote;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: Text(label, style: textTheme.bodySmall)),
        Semantics(
          label: semanticLabel,
          child: ExcludeSemantics(
            child: Text(
              amountText,
              style: AppTextStyles.of(context).amountHero
                  .copyWith(color: AppColors.of(context).onSurface),
            ),
          ),
        ),
        if (roomsNote != null) Text(roomsNote, style: textTheme.bodySmall),
      ],
    );
  }
}
