import 'dart:async';

import 'package:expense_tracker/features/capture/presentation/iphone_setup_notifier.dart';
import 'package:expense_tracker/features/capture/presentation/widgets/info_card.dart';
import 'package:expense_tracker/features/capture/presentation/widgets/step_card.dart';
import 'package:expense_tracker/features/capture/presentation/widgets/test_parse_box.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The iPhone auto-capture guide (spec §6.3): how to make the Shortcuts
/// "Message" automation that hands bank SMS to the app, a place to test a
/// message, and a button to record that setup is done.
class IphoneSetupScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  Future<void> _openShortcuts(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final ok = await ref
        .read(iphoneSetupNotifierProvider.notifier)
        .openShortcuts();
    if (ok) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.autoCaptureActionFailed)));
  }

  Future<void> _done(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final failure = await ref
        .read(iphoneSetupNotifierProvider.notifier)
        .markDone();
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            failure == null
                ? l10n.iosSetupSaved
                : failureMessage(l10n, failure),
          ),
        ),
      );
    if (failure == null) router.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final result = ref.watch(iphoneSetupNotifierProvider);
    final notifier = ref.read(iphoneSetupNotifierProvider.notifier);
    final steps = [
      (l10n.iosStep1Title, l10n.iosStep1Body),
      (l10n.iosStep2Title, l10n.iosStep2Body),
      (l10n.iosStep3Title, l10n.iosStep3Body),
      (l10n.iosStep4Title, l10n.iosStep4Body),
      (l10n.iosStep5Title, l10n.iosStep5Body),
    ];
    return LargeTitlePage(
      title: Text(l10n.iosSetupTitle),
      leading: RoundIconButton(
        icon: Icons.arrow_back_rounded,
        tooltip: l10n.back,
        floating: false,
        color: AppColors.of(context).onSurface,
        onPressed: context.pop,
      ),
      children: [
        Entrance(
          child: Text(
            l10n.iosSetupIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        for (final (index, (title, body)) in steps.indexed)
          Entrance(
            index: index + 1,
            child: StepCard(
              number: index + 1,
              numberLabel: l10n.iosSetupStep(index + 1),
              title: title,
              body: body,
              child: switch (index) {
                0 => OutlinedButton(
                  onPressed: () => unawaited(_openShortcuts(context, ref)),
                  child: Text(l10n.iosStep1Action),
                ),
                4 => TestParseBox(result: result, onCheck: notifier.test),
                _ => null,
              },
            ),
          ),
        Entrance(
          index: steps.length + 1,
          child: InfoCard(title: l10n.iosLimitsTitle, body: l10n.iosLimitsBody),
        ),
        Entrance(
          index: steps.length + 2,
          child: FilledButton(
            onPressed: () => unawaited(_done(context, ref)),
            child: Text(l10n.iosSetupDone),
          ),
        ),
      ],
    );
  }
}
