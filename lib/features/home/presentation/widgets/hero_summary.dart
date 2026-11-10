import 'package:expense_tracker/features/home/presentation/home_notifier.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/count_up_money.dart';
import 'package:expense_tracker/widgets/hero_card.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// The dark card that opens Home: the month's spending as a sentence, a few
/// numbers under it, and an arrow to Activity.
class HeroSummary extends StatelessWidget {
  /// Creates the card for [state].
  const new({required this.state, required this.onSeeAll, super.key});

  /// The month shown.
  final HomeState state;

  /// Opens Activity.
  final VoidCallback onSeeAll;

  String _sentence(AppLocalizations l10n, String locale, String amount) {
    if (!state.isCurrent) {
      return l10n.heroSpentIn(
        amount,
        formatPeriodTitle(state.period, state.today, locale),
      );
    }
    if (state.period.start.day == 1) return l10n.heroSpentThisMonth(amount);
    return l10n.heroSpentSince(
      amount,
      formatDayMonth(state.period.start, locale),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final tiles = CategoryColors.of(context);
    final styles = AppTextStyles.of(context);
    final locale = Localizations.localeOf(context).toString();
    final summary = state.summary;
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isCurrent)
            Text(
              l10n.heroGreeting,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: colors.onHero),
            ),
          Semantics(
            container: true,
            label: _sentence(l10n, locale, formatMoney(summary.spent)),
            child: ExcludeSemantics(
              child: CountUpMoney(
                money: summary.spent,
                builder: (context, shown) => Text(
                  _sentence(l10n, locale, formatMoney(shown)),
                  style: styles.heroSentence.copyWith(color: colors.onHero),
                ),
              ),
            ),
          ),
          SizedBox(height: metrics.spaceLg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroStat(
                      icon: Icons.south_west_rounded,
                      tileColor: tiles.green,
                      label: l10n.heroMoneyIn,
                      semanticLabel: l10n.heroMoneyInSemantics(
                        formatMoney(summary.moneyIn),
                      ),
                      child: CountUpMoney(
                        money: summary.moneyIn,
                        builder: (context, shown) => Text(
                          summary.moneyIn.isPositive
                              ? formatMoneyIn(shown)
                              : formatMoney(shown),
                          style: styles.statValue.copyWith(
                            color: summary.moneyIn.isPositive
                                ? colors.moneyInOnHero
                                : colors.onHero,
                          ),
                        ),
                      ),
                    ),
                    _HeroStat(
                      icon: Icons.calendar_today_rounded,
                      tileColor: tiles.blue,
                      label: l10n.heroDailyAverage,
                      semanticLabel: l10n.heroDailyAverageSemantics(
                        formatMoney(state.dailyAverage),
                      ),
                      child: CountUpMoney(
                        money: state.dailyAverage,
                        builder: (context, shown) => Text(
                          formatMoney(shown),
                          style: styles.statValue.copyWith(
                            color: colors.onHero,
                          ),
                        ),
                      ),
                    ),
                    if (summary.spentInRooms.isPositive)
                      _HeroStat(
                        icon: Icons.luggage_rounded,
                        tileColor: tiles.orange,
                        label: l10n.heroInRooms,
                        semanticLabel: l10n.heroInRoomsSemantics(
                          formatMoney(summary.spentInRooms),
                        ),
                        child: CountUpMoney(
                          money: summary.spentInRooms,
                          builder: (context, shown) => Text(
                            formatMoney(shown),
                            style: styles.statValue.copyWith(
                              color: colors.onHero,
                            ),
                          ),
                        ),
                      )
                    else
                      _HeroStat(
                        icon: Icons.receipt_rounded,
                        tileColor: tiles.violet,
                        label: l10n.heroPayments,
                        semanticLabel: l10n.heroPaymentsValue(
                          state.paymentCount,
                        ),
                        child: Text(
                          l10n.heroPaymentsValue(state.paymentCount),
                          style: styles.statValue.copyWith(
                            color: colors.onHero,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _ArrowButton(label: l10n.seeAllActivity, onTap: onSeeAll),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const new({
    required this.icon,
    required this.tileColor,
    required this.label,
    required this.semanticLabel,
    required this.child,
  });

  final IconData icon;
  final Color tileColor;
  final String label;
  final String semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    return Semantics(
      container: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: metrics.spaceXs),
          child: Row(
            children: [
              IconTile(icon: icon, color: tileColor),
              SizedBox(width: metrics.spaceMd),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onHeroMuted),
                    ),
                    child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: colors.accentFill,
          shape: const CircleBorder(),
          child: Pressable(
            onTap: onTap,
            shape: const CircleBorder(),
            child: SizedBox.square(
              dimension: metrics.heroArrowSize,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: colors.onAccentFill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
