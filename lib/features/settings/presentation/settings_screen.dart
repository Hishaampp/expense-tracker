import 'dart:async';

import 'package:expense_tracker/features/settings/presentation/settings_notifier.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/month_start_day_dialog.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/ledger_row.dart';
import 'package:expense_tracker/widgets/ledger_section.dart';
import 'package:expense_tracker/widgets/ledger_skeleton.dart';
import 'package:expense_tracker/widgets/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App settings. Phase 1 holds the month start day only.
class SettingsScreen extends ConsumerWidget {
  /// Creates the Settings screen.
  const new({super.key});

  Future<void> _pickMonthStartDay(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final picked = await showDialog<int>(
      context: context,
      builder: (_) => MonthStartDayDialog(selectedDay: current),
    );
    // Null means dismissed: change nothing.
    if (picked == null || picked == current) return;
    final failure = await notifier.setMonthStartDay(picked);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            failure == null
                ? l10n.settingsMonthStartSaved(picked)
                : failureMessage(l10n, failure),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final async = ref.watch(settingsNotifierProvider);
    final state = async.value;

    final Widget body;
    if (state != null) {
      final value = l10n.settingsMonthStartValue(state.monthStartDay);
      body = ListView(
        children: [
          SizedBox(height: metrics.spaceSm),
          Semantics(
            header: true,
            child: Text(
              l10n.settingsTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          SizedBox(height: metrics.spaceXl),
          LedgerSection(
            title: l10n.settingsMonthSection,
            rows: [
              LedgerRow(
                icon: Icons.calendar_month_outlined,
                title: l10n.settingsMonthStart,
                subtitle: l10n.settingsMonthStartHelp,
                amountText: value,
                semanticLabel: l10n.settingsMonthStartSemantics(
                  state.monthStartDay,
                ),
                onTap: () => unawaited(
                  _pickMonthStartDay(context, ref, state.monthStartDay),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (async.hasError) {
      body = Center(
        child: ErrorStateView(
          message: l10n.failureLoad,
          actionLabel: l10n.tryAgain,
          onAction: () => ref.invalidate(settingsNotifierProvider),
        ),
      );
    } else {
      body = LedgerSkeleton(semanticLabel: l10n.loading, rowCount: 1);
    }
    return Scaffold(body: PageFrame(child: body));
  }
}
