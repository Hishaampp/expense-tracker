import 'dart:async';

import 'package:expense_tracker/core/models/appearance_mode.dart';
import 'package:expense_tracker/features/settings/presentation/settings_notifier.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/appearance_sheet.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/month_start_day_sheet.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_group.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/info_row.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// App settings.
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
    final picked = await showMonthStartDaySheet(context, current);
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

  Future<void> _pickAppearance(
    BuildContext context,
    WidgetRef ref,
    AppearanceMode current,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final picked = await showAppearanceSheet(context, current);
    // Null means dismissed: change nothing. The theme change is the feedback.
    if (picked == null || picked == current) return;
    final failure = await notifier.setAppearance(picked);
    if (failure != null) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tiles = CategoryColors.of(context);
    final async = ref.watch(settingsNotifierProvider);
    final state = async.value;

    if (state == null) {
      return LargeTitlePage(
        title: Text(l10n.settingsTitle),
        children: [
          if (async.hasError)
            ErrorStateView(
              message: l10n.failureLoad,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(settingsNotifierProvider),
            )
          else
            PulsingPlaceholder(semanticLabel: l10n.loading),
        ],
      );
    }
    final appearance = appearanceLabel(l10n, state.appearance);
    return LargeTitlePage(
      title: Text(l10n.settingsTitle),
      children: [
        Entrance(
          child: SettingsGroup(
            label: l10n.settingsSectionMonth,
            rows: [
              InfoRow(
                leading: IconTile(
                  icon: Icons.calendar_month_rounded,
                  color: tiles.orange,
                ),
                title: l10n.settingsMonthStart,
                trailingText: l10n.settingsMonthStartValue(state.monthStartDay),
                trailingIsAmount: false,
                showChevron: true,
                semanticLabel: l10n.settingsMonthStartSemantics(
                  state.monthStartDay,
                ),
                onTap: () => unawaited(
                  _pickMonthStartDay(context, ref, state.monthStartDay),
                ),
              ),
              InfoRow(
                leading: IconTile(
                  icon: Icons.savings_rounded,
                  color: tiles.green,
                ),
                title: l10n.settingsBudgets,
                trailingText: switch (state.monthlyBudget) {
                  final budget? => formatMoney(budget),
                  null => l10n.budgetsNotSet,
                },
                trailingIsAmount: state.monthlyBudget != null,
                showChevron: true,
                semanticLabel: l10n.settingsBudgetsSemantics(
                  switch (state.monthlyBudget) {
                    final budget? => formatMoney(budget),
                    null => l10n.budgetsNotSet,
                  },
                ),
                onTap: () => unawaited(context.push(Routes.budgets)),
              ),
            ],
          ),
        ),
        Entrance(
          index: 1,
          child: SettingsGroup(
            label: l10n.settingsSectionMessages,
            rows: [
              InfoRow(
                leading: IconTile(icon: Icons.bolt_rounded, color: tiles.green),
                title: l10n.autoCaptureTitle,
                trailingText: switch (state.autoCaptureOn) {
                  true => l10n.autoCaptureRowOn,
                  false => l10n.autoCaptureRowOff,
                  null => null,
                },
                trailingIsAmount: false,
                showChevron: true,
                semanticLabel: switch (state.autoCaptureOn) {
                  true => l10n.autoCaptureRowSemantics(l10n.on),
                  false => l10n.autoCaptureRowSemantics(l10n.off),
                  null => l10n.autoCaptureTitle,
                },
                onTap: () => unawaited(context.push(Routes.autoCapture)),
              ),
              InfoRow(
                leading: IconTile(
                  icon: Icons.storefront_rounded,
                  color: tiles.orange,
                ),
                title: l10n.settingsPayees,
                trailingIsAmount: false,
                showChevron: true,
                semanticLabel: l10n.settingsPayeesSemantics,
                onTap: () => unawaited(context.push(Routes.payees)),
              ),
              InfoRow(
                leading: IconTile(
                  icon: Icons.mark_unread_chat_alt_rounded,
                  color: tiles.blue,
                ),
                title: l10n.unparsedTitle,
                trailingText: state.unparsedCount == null
                    ? null
                    : l10n.settingsUnparsedCount(state.unparsedCount!),
                trailingIsAmount: false,
                showChevron: true,
                semanticLabel: state.unparsedCount == null
                    ? l10n.unparsedTitle
                    : l10n.unparsedRowSemantics(state.unparsedCount!),
                onTap: () => unawaited(context.push(Routes.unparsed)),
              ),
            ],
          ),
        ),
        Entrance(
          index: 2,
          child: SettingsGroup(
            label: l10n.settingsSectionLook,
            rows: [
              InfoRow(
                leading: IconTile(
                  icon: Icons.dark_mode_rounded,
                  color: tiles.violet,
                ),
                title: l10n.settingsAppearance,
                trailingText: appearance,
                trailingIsAmount: false,
                showChevron: true,
                semanticLabel: l10n.settingsAppearanceSemantics(appearance),
                onTap: () =>
                    unawaited(_pickAppearance(context, ref, state.appearance)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
