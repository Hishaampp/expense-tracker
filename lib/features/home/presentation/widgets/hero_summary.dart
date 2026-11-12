import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/features/home/presentation/home_notifier.dart';
import 'package:expense_tracker/formatting/date_format.dart';
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
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// The dark card that opens Home: the month's spending as a sentence, a few
/// numbers under it, and an arrow to Activity. Once income is recorded it
/// leads with the balance instead: what is left, a bar of how much of the
/// money in has gone, and money in, spent and carried over (Phase 10).
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

  // The balance sentence: what is left (this month) or what the month
  // saved (a past month), or by how much it fell short.
  String _balanceSentence(
    AppLocalizations l10n,
    String locale,
    String amount, {
    required bool short,
  }) {
    if (!state.isCurrent) {
      final month = formatPeriodTitle(state.period, state.today, locale);
      return short
          ? l10n.heroOverspentIn(amount, month)
          : l10n.heroSavedIn(amount, month);
    }
    if (state.period.start.day == 1) {
      return short
          ? l10n.heroShortThisMonth(amount)
          : l10n.heroLeftThisMonth(amount);
    }
    final date = formatDayMonth(state.period.start, locale);
    return short
        ? l10n.heroShortSince(amount, date)
        : l10n.heroLeftSince(amount, date);
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
    if (state.showsBalance) {
      return _BalanceCard(
        state: state,
        onSeeAll: onSeeAll,
        sentence: (amount, {required short}) =>
            _balanceSentence(l10n, locale, amount, short: short),
      );
    }
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
                    _MoneyStat(
                      icon: Icons.south_west_rounded,
                      tileColor: tiles.green,
                      label: l10n.heroMoneyIn,
                      semanticLabel: l10n.heroMoneyInSemantics(
                        formatMoney(summary.moneyIn),
                      ),
                      money: summary.moneyIn,
                      isMoneyIn: true,
                    ),
                    _MoneyStat(
                      icon: Icons.calendar_today_rounded,
                      tileColor: tiles.blue,
                      label: l10n.heroDailyAverage,
                      semanticLabel: l10n.heroDailyAverageSemantics(
                        formatMoney(state.dailyAverage),
                      ),
                      money: state.dailyAverage,
                    ),
                    if (summary.spentInRooms.isPositive)
                      _MoneyStat(
                        icon: Icons.luggage_rounded,
                        tileColor: tiles.orange,
                        label: l10n.heroInRooms,
                        semanticLabel: l10n.heroInRoomsSemantics(
                          formatMoney(summary.spentInRooms),
                        ),
                        money: summary.spentInRooms,
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

class _BalanceCard extends StatelessWidget {
  const new({
    required this.state,
    required this.onSeeAll,
    required this.sentence,
  });

  final HomeState state;
  final VoidCallback onSeeAll;
  final String Function(String amount, {required bool short}) sentence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final tiles = CategoryColors.of(context);
    final styles = AppTextStyles.of(context);
    final summary = state.summary;
    // This month: everything left, carried over included. A past month:
    // what that month itself saved.
    final left = state.isCurrent ? state.balance : summary.result;
    final short = left.isNegative;
    final shown = short ? Money(-left.paise) : left;
    final available = state.isCurrent ? state.available : summary.moneyIn;
    final over = summary.spent.paise > available.paise;
    final carried = state.carried;
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isCurrent)
            Text(
              l10n.heroGreeting,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: colors.onHero),
            ),
          Semantics(
            container: true,
            label: sentence(formatMoney(shown), short: short),
            child: ExcludeSemantics(
              child: CountUpMoney(
                money: shown,
                builder: (context, value) => Text(
                  sentence(formatMoney(value), short: short),
                  style: styles.heroSentence.copyWith(color: colors.onHero),
                ),
              ),
            ),
          ),
          if (available.isPositive) ...[
            SizedBox(height: metrics.spaceLg),
            GrowingBar(
              fraction: summary.spent.paise / available.paise,
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
                    l10n.heroBalanceUsed(
                      formatMoney(summary.spent),
                      formatMoney(available),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onHero),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: metrics.spaceLg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MoneyStat(
                      icon: Icons.south_west_rounded,
                      tileColor: tiles.green,
                      label: l10n.heroMoneyIn,
                      semanticLabel: l10n.heroMoneyInSemantics(
                        formatMoney(summary.moneyIn),
                      ),
                      money: summary.moneyIn,
                      isMoneyIn: true,
                    ),
                    _MoneyStat(
                      icon: Icons.north_east_rounded,
                      tileColor: tiles.red,
                      label: l10n.heroSpent,
                      semanticLabel: l10n.heroSpentSemantics(
                        formatMoney(summary.spent),
                      ),
                      money: summary.spent,
                    ),
                    if (state.isCurrent && carried != Money.zero)
                      _MoneyStat(
                        icon: Icons.history_rounded,
                        tileColor: tiles.blue,
                        label: l10n.heroCarried,
                        semanticLabel: l10n.heroCarriedSemantics(
                          formatMoney(carried),
                        ),
                        money: carried,
                      )
                    else
                      _MoneyStat(
                        icon: Icons.calendar_today_rounded,
                        tileColor: tiles.blue,
                        label: l10n.heroDailyAverage,
                        semanticLabel: l10n.heroDailyAverageSemantics(
                          formatMoney(state.dailyAverage),
                        ),
                        money: state.dailyAverage,
                      ),
                    if (summary.spentInRooms.isPositive)
                      _MoneyStat(
                        icon: Icons.luggage_rounded,
                        tileColor: tiles.orange,
                        label: l10n.heroInRooms,
                        semanticLabel: l10n.heroInRoomsSemantics(
                          formatMoney(summary.spentInRooms),
                        ),
                        money: summary.spentInRooms,
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

/// A hero stat whose value is an amount that counts up; money in shows
/// with a plus in its own colour.
class _MoneyStat extends StatelessWidget {
  const new({
    required this.icon,
    required this.tileColor,
    required this.label,
    required this.semanticLabel,
    required this.money,
    this.isMoneyIn = false,
  });

  final IconData icon;
  final Color tileColor;
  final String label;
  final String semanticLabel;
  final Money money;
  final bool isMoneyIn;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);
    final inFlow = isMoneyIn && money.isPositive;
    return _HeroStat(
      icon: icon,
      tileColor: tileColor,
      label: label,
      semanticLabel: semanticLabel,
      child: CountUpMoney(
        money: money,
        builder: (context, shown) => Text(
          inFlow ? formatMoneyIn(shown) : formatMoney(shown),
          style: styles.statValue.copyWith(
            color: inFlow ? colors.moneyInOnHero : colors.onHero,
          ),
        ),
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
