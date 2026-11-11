import 'dart:async';

import 'package:expense_tracker/core/budget_input.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/sync/sync_controller.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/choice_pill.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/hero_card.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/month_start_day_sheet.dart';
import 'package:expense_tracker/widgets/provider_buttons.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The first-launch welcome (spec §11 screen 1): three value cards, the
/// privacy promise, capture setup (skippable), two questions (salary day
/// and a monthly budget, both skippable) and the optional account (Phase
/// 9), then Home.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { capture, rooms, budget, privacy, setup, payday, monthly, sync }

// Salary days offered as one tap; any other day comes from the sheet.
const List<int> _paydays = [1, 5, 7, 10, 25];

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.capture;
  final TextEditingController _budget = TextEditingController();
  bool _finishing = false;
  bool _invalid = false;
  bool _forward = true;
  int _payday = 1;
  bool _openedAccount = false;

  @override
  void dispose() {
    _budget.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == _Step.monthly) {
      final typed = _budget.text.trim();
      if (typed.isNotEmpty && parseBudget(typed) == null) {
        setState(() => _invalid = true);
        return;
      }
    }
    final next = _step.index + 1;
    if (next < _Step.values.length) {
      setState(() {
        _forward = true;
        _step = _Step.values[next];
      });
    } else {
      unawaited(_finish());
    }
  }

  void _skipBudget() {
    _budget.clear();
    setState(() => _invalid = false);
    _next();
  }

  void _back() => setState(() {
    _forward = false;
    _step = _Step.values[_step.index - 1];
  });

  Future<void> _pickOtherPayday() async {
    final picked = await showMonthStartDaySheet(context, _payday);
    // Null means dismissed: keep the day.
    if (picked != null && mounted) setState(() => _payday = picked);
  }

  Future<void> _openAccount() async {
    _openedAccount = true;
    await context.push(Routes.account);
    if (!mounted) return;
    _openedAccount = false;
    if (ref.read(syncControllerProvider).value is! SyncSignedOut) {
      unawaited(_finish());
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final amount = parseBudget(_budget.text.trim());
    final saved = amount == null
        ? null
        : await ref.read(budgetRepositoryProvider).setMonthly(amount);
    final day = _payday == 1
        ? null
        : await ref.read(settingsRepositoryProvider).setMonthStartDay(_payday);
    final done = await ref.read(settingsRepositoryProvider).markOnboarded();
    final failure = switch ((saved, day, done)) {
      (Err(:final failure), _, _) ||
      (_, Err(:final failure), _) ||
      (_, _, Err(:final failure)) => failure,
      _ => null,
    };
    if (!mounted) return;
    if (failure != null) {
      setState(() => _finishing = false);
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
      return;
    }
    ref.read(hapticsProvider).commit();
    context.go(Routes.home);
  }

  Future<void> _setUp() async {
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    await context.push(ios ? Routes.iphoneSetup : Routes.autoCapture);
    if (mounted) _next();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final motion = AppMotion.of(context);
    final tiles = CategoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final total = _Step.values.length;
    // A sign-in from the sync step returns through the browser; the
    // account screen then shows the recovery code.
    final messenger = ScaffoldMessenger.of(context);
    ref.listen(syncControllerProvider, (_, next) {
      final signedIn = next.value is SyncNewKey || next.value is SyncNeedsCode;
      if (_step == _Step.sync && signedIn && !_openedAccount) {
        unawaited(_openAccount());
      }
    });
    final body = switch (_step) {
      _Step.capture => _Value(
        icon: Icons.bolt_rounded,
        color: tiles.green,
        title: l10n.onboardCaptureTitle,
        body: l10n.onboardCaptureBody,
      ),
      _Step.rooms => _Value(
        icon: Icons.luggage_rounded,
        color: tiles.blue,
        title: l10n.onboardRoomsTitle,
        body: l10n.onboardRoomsBody,
      ),
      _Step.budget => _Value(
        icon: Icons.savings_rounded,
        color: tiles.amber,
        title: l10n.onboardBudgetTitle,
        body: l10n.onboardBudgetBody,
      ),
      _Step.privacy => _Privacy(
        lines: [
          l10n.onboardPrivacyNoAccount,
          l10n.onboardPrivacyNoInternet,
          l10n.onboardPrivacyNoAds,
        ],
      ),
      _Step.setup => _Value(
        icon: Icons.notifications_active_rounded,
        color: tiles.violet,
        title: l10n.onboardSetupTitle,
        body: l10n.onboardSetupBody,
      ),
      _Step.payday => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Value(
            icon: Icons.event_repeat_rounded,
            color: tiles.teal,
            title: l10n.onboardPaydayTitle,
            body: l10n.onboardPaydayBody,
          ),
          SizedBox(height: metrics.spaceLg),
          Wrap(
            spacing: metrics.spaceSm,
            runSpacing: metrics.spaceSm,
            children: [
              for (final (i, day) in _paydays.indexed)
                Entrance(
                  index: i + 3,
                  child: ChoicePill(
                    label: day == 1
                        ? l10n.onboardPaydayFirst
                        : l10n.settingsMonthStartValue(day),
                    selected: _payday == day,
                    onTap: () => setState(() => _payday = day),
                  ),
                ),
              Entrance(
                index: _paydays.length + 3,
                child: ChoicePill(
                  label: _paydays.contains(_payday)
                      ? l10n.onboardPaydayOther
                      : l10n.settingsMonthStartValue(_payday),
                  icon: Icons.calendar_month_rounded,
                  selected: !_paydays.contains(_payday),
                  onTap: () => unawaited(_pickOtherPayday()),
                ),
              ),
            ],
          ),
        ],
      ),
      _Step.sync => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Value(
            icon: Icons.cloud_sync_rounded,
            color: tiles.blue,
            title: l10n.onboardSyncTitle,
            body: l10n.onboardSyncBody,
          ),
          SizedBox(height: metrics.spaceLg),
          Entrance(
            index: 3,
            child: ProviderButtons(
              onProblem: (problem) => messenger
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(content: Text(cloudProblemMessage(l10n, problem))),
                ),
            ),
          ),
          Entrance(
            index: 4,
            child: OutlinedButton(
              onPressed: _finishing ? null : () => unawaited(_openAccount()),
              child: Text(l10n.onboardSyncEmail),
            ),
          ),
        ],
      ),
      _Step.monthly => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Value(
            icon: Icons.account_balance_wallet_rounded,
            color: tiles.orange,
            title: l10n.onboardMonthlyTitle,
            body: l10n.onboardMonthlyBody,
          ),
          SizedBox(height: metrics.spaceLg),
          TextField(
            controller: _budget,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(maxBudgetDigits),
            ],
            decoration: InputDecoration(
              labelText: l10n.budgetsAmountLabel,
              prefixText: rupeeFieldPrefix,
              errorText: _invalid ? l10n.budgetsAmountInvalid : null,
            ),
            onChanged: (_) {
              if (_invalid) setState(() => _invalid = false);
            },
            onSubmitted: (_) => _next(),
          ),
        ],
      ),
    };
    final isLast = _step == _Step.sync;
    final skippable = _step == _Step.setup || _step == _Step.monthly;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: metrics.readableWidth),
            child: Padding(
              padding: EdgeInsetsDirectional.all(metrics.spaceXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (_step.index > 0)
                        RoundIconButton(
                          icon: Icons.arrow_back_rounded,
                          tooltip: l10n.back,
                          floating: false,
                          color: colors.onSurface,
                          onPressed: _back,
                        ),
                      const Spacer(),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          l10n.onboardStep(_step.index + 1, total),
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AnimatedSwitcher(
                        duration: resolveMotion(context, motion.medium),
                        switchInCurve: motion.enter,
                        switchOutCurve: motion.exit,
                        // The new step slides in from the side it comes
                        // from: ahead going forward, behind going back.
                        transitionBuilder: (child, animation) {
                          final incoming = child.key == ValueKey(_step);
                          final from = (incoming == _forward) ? 1.0 : -1.0;
                          final dx =
                              Directionality.of(context) == TextDirection.rtl
                              ? -from
                              : from;
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(dx * stepSlideShare, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              top: metrics.spaceXl,
                            ),
                            child: body,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: metrics.spaceLg),
                  _Dots(count: total, current: _step.index),
                  SizedBox(height: metrics.spaceLg),
                  if (_step == _Step.setup)
                    FilledButton(
                      onPressed: () => unawaited(_setUp()),
                      child: Text(l10n.onboardSetupAction),
                    )
                  else
                    FilledButton(
                      onPressed: _finishing ? null : _next,
                      child: Text(
                        isLast ? l10n.onboardStart : l10n.onboardNext,
                      ),
                    ),
                  if (skippable) ...[
                    SizedBox(height: metrics.spaceSm),
                    TextButton(
                      onPressed: _finishing
                          ? null
                          : _step == _Step.monthly
                          ? _skipBudget
                          : _next,
                      child: Text(l10n.onboardSkip),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const new({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final motion = AppMotion.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The icon pops in as the step arrives; still under reduced motion.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: popStartScale, end: 1),
          duration: resolveMotion(context, motion.slow),
          curve: motion.pop,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: IconTile(icon: icon, color: color, large: true),
        ),
        SizedBox(height: metrics.spaceXl),
        Entrance(
          index: 1,
          child: Semantics(
            header: true,
            child: Text(title, style: textTheme.headlineMedium),
          ),
        ),
        SizedBox(height: metrics.spaceMd),
        Entrance(index: 2, child: Text(body, style: textTheme.bodyLarge)),
      ],
    );
  }
}

class _Privacy extends StatelessWidget {
  const new({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final styles = AppTextStyles.of(context);
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_rounded,
            color: colors.onHero,
            size: metrics.iconLargeSize,
          ),
          SizedBox(height: metrics.spaceLg),
          Semantics(
            header: true,
            child: Text(
              l10n.onboardPrivacyTitle,
              style: styles.heroSentence.copyWith(color: colors.onHero),
            ),
          ),
          SizedBox(height: metrics.spaceLg),
          for (final line in lines)
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: metrics.spaceSm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_rounded, color: colors.moneyInOnHero),
                  SizedBox(width: metrics.spaceSm),
                  Expanded(
                    child: Text(
                      line,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: colors.onHero),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Where the user is in the welcome. Decorative: the step count is read
// out above.
class _Dots extends StatelessWidget {
  const new({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final motion = AppMotion.of(context);
    final gap = metrics.spaceXs;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: resolveMotion(context, motion.medium),
              curve: motion.move,
              margin: EdgeInsetsDirectional.symmetric(horizontal: gap),
              width: i == current ? metrics.spaceLg : metrics.progressHeight,
              height: metrics.progressHeight,
              decoration: BoxDecoration(
                color: i == current ? colors.accent : colors.hairline,
                borderRadius: BorderRadius.circular(metrics.progressHeight),
              ),
            ),
        ],
      ),
    );
  }
}
