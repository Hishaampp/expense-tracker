import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/formatting/room_text.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/growing_bar.dart';
import 'package:expense_tracker/widgets/room_tile.dart';
import 'package:flutter/material.dart';

/// One Room in the list: tile, name, type and dates, what was spent, and
/// its budget bar when it has one.
class RoomCard extends StatelessWidget {
  /// Creates the card.
  const new({
    required this.room,
    required this.spent,
    required this.onTap,
    super.key,
  });

  /// The Room.
  final Room room;

  /// What has been spent in it.
  final Money spent;

  /// Opens the Room.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final subtitle = roomSubtitle(l10n, room, locale);
    final amount = formatMoney(spent);
    final budget = room.budget;
    final budgetLine = budget == null ? null : _budgetLine(l10n, budget);
    final label = l10n.roomCardSemantics(room.name, subtitle, amount);
    return AppCard(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: budgetLine == null ? label : l10n.listPair(label, budgetLine),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  RoomTile(type: room.type, emoji: room.emoji),
                  SizedBox(width: metrics.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room.name, style: textTheme.bodyLarge),
                        Text(subtitle, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  SizedBox(width: metrics.spaceMd),
                  Text(
                    amount,
                    style: AppTextStyles.of(context).amountRow
                        .copyWith(color: colors.onSurface),
                  ),
                ],
              ),
              if (budget != null && budgetLine != null) ...[
                SizedBox(height: metrics.spaceMd),
                GrowingBar(
                  fraction: budget.paise == 0
                      ? 1
                      : (spent.paise / budget.paise).clamp(0, 1),
                  color: spent.paise > budget.paise
                      ? colors.danger
                      : roomStyle(context, room.type).color,
                  trackColor: colors.surfaceSunken,
                ),
                SizedBox(height: metrics.spaceXs),
                _BudgetLine(text: budgetLine, over: spent.paise > budget.paise),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _budgetLine(AppLocalizations l10n, Money budget) {
    final left = budget - spent;
    return left.isNegative
        ? l10n.roomOver(formatMoney(Money(-left.paise)))
        : l10n.roomLeft(formatMoney(left), formatMoney(budget));
  }
}

/// "₹X left of ₹Y", or "Over by ₹X" with a warning glyph.
class _BudgetLine extends StatelessWidget {
  const new({required this.text, required this.over});

  final String text;
  final bool over;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final style = Theme.of(context).textTheme.bodySmall;
    if (!over) return Text(text, style: style);
    return Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          size: metrics.iconSize,
          color: colors.danger,
        ),
        SizedBox(width: metrics.spaceXs),
        Flexible(
          child: Text(text, style: style?.copyWith(color: colors.danger)),
        ),
      ],
    );
  }
}
