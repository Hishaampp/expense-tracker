import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/room_summary.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/count_up_money.dart';
import 'package:expense_tracker/widgets/growing_bar.dart';
import 'package:expense_tracker/widgets/hero_card.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:flutter/material.dart';

/// The Room's dark summary card: what was spent as a sentence, the budget
/// bar and what is left, and per-day spend for dated Rooms.
class RoomHero extends StatelessWidget {
  /// Creates the card for [summary].
  const new({required this.summary, super.key});

  /// The Room's totals.
  final RoomSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final tiles = CategoryColors.of(context);
    final styles = AppTextStyles.of(context);
    final room = summary.room;
    final budget = room.budget;
    final remaining = summary.remaining;
    final over = remaining != null && remaining.isNegative;
    final perDay = summary.perDay;
    final days = summary.days;
    String sentence(Money m) => l10n.roomHeroSpent(formatMoney(m), room.name);
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            label: sentence(summary.spent),
            child: ExcludeSemantics(
              child: CountUpMoney(
                money: summary.spent,
                builder: (context, shown) => Text(
                  sentence(shown),
                  style: styles.heroSentence.copyWith(color: colors.onHero),
                ),
              ),
            ),
          ),
          if (budget != null && remaining != null) ...[
            SizedBox(height: metrics.spaceLg),
            GrowingBar(
              fraction: (summary.progress ?? 1).clamp(0, 1),
              color: over ? colors.danger : colors.accent,
              trackColor: colors.onHeroMuted,
            ),
            SizedBox(height: metrics.spaceSm),
            Row(
              children: [
                if (over) ...[
                  Icon(
                    Icons.warning_amber_rounded,
                    size: metrics.iconSize,
                    color: colors.onHero,
                  ),
                  SizedBox(width: metrics.spaceXs),
                ],
                Flexible(
                  child: Text(
                    over
                        ? l10n.roomOver(formatMoney(Money(-remaining.paise)))
                        : l10n.roomLeft(
                            formatMoney(remaining),
                            formatMoney(budget),
                          ),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onHero),
                  ),
                ),
              ],
            ),
          ],
          if (perDay != null && days != null) ...[
            SizedBox(height: metrics.spaceLg),
            Wrap(
              spacing: metrics.spaceXl,
              runSpacing: metrics.spaceSm,
              children: [
                _Stat(
                  icon: Icons.calendar_today_rounded,
                  tileColor: tiles.blue,
                  label: l10n.roomPerDay,
                  value: formatMoney(perDay),
                ),
                _Stat(
                  icon: Icons.event_available_rounded,
                  tileColor: tiles.violet,
                  label: l10n.roomDays,
                  value: '$days',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const new({
    required this.icon,
    required this.tileColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color tileColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    return Semantics(
      container: true,
      label: AppLocalizations.of(context).listPair(label, value),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTile(icon: icon, color: tileColor),
            SizedBox(width: metrics.spaceMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onHeroMuted),
                ),
                Text(
                  value,
                  style: AppTextStyles.of(context).statValue
                      .copyWith(color: colors.onHero),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
