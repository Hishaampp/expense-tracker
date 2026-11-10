import 'package:expense_tracker/theme/app_colors.dart';
import 'package:flutter/widgets.dart';

/// How an amount is coloured. Colour only reinforces the sign, icon and
/// label that already tell the states apart (docs/DESIGN.md).
enum MoneyTone {
  /// Money spent: plain ink.
  spent,

  /// Money received: the money-in colour.
  moneyIn,

  /// A transfer, which is not spending: muted.
  transfer;

  /// The colour for this tone in [colors].
  Color colorIn(AppColors colors) => switch (this) {
    MoneyTone.spent => colors.onSurface,
    MoneyTone.moneyIn => colors.moneyIn,
    MoneyTone.transfer => colors.onSurfaceMuted,
  };
}
