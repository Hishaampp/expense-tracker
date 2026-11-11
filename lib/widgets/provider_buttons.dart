import 'dart:async';

import 'package:expense_tracker/data/sync/sync_controller.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/services/cloud/cloud_auth.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Continue with Apple / Google" (Phase 9), for the providers turned on
/// in the project; nothing while none are. The sign-in page opens in the
/// browser and returns to the app, which then shows the recovery code.
class ProviderButtons extends ConsumerWidget {
  /// Creates the buttons; [onProblem] hears why opening one failed.
  const new({required this.onProblem, super.key});

  /// Called with what went wrong.
  final ValueChanged<CloudAuthProblem> onProblem;

  Future<void> _open(WidgetRef ref, CloudProvider provider) async {
    final problem = await ref
        .read(syncControllerProvider.notifier)
        .signInWith(provider);
    if (problem != null) onProblem(problem);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final providers = ref.watch(cloudProvidersProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final provider in providers) ...[
          OutlinedButton.icon(
            onPressed: () => unawaited(_open(ref, provider)),
            icon: Icon(switch (provider) {
              CloudProvider.apple => Icons.apple_rounded,
              CloudProvider.google => Icons.account_circle_rounded,
            }),
            label: Text(switch (provider) {
              CloudProvider.apple => l10n.accountContinueApple,
              CloudProvider.google => l10n.accountContinueGoogle,
            }),
          ),
          SizedBox(height: metrics.spaceSm),
        ],
      ],
    );
  }
}
