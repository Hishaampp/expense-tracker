import 'dart:async';

import 'package:expense_tracker/features/backup/presentation/backup_notifier.dart';
import 'package:expense_tracker/features/backup/presentation/widgets/password_sheet.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings → Backup & export (spec §13): an encrypted backup to save
/// anywhere, restore from one, and a CSV export.
class BackupScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  void _report(
    ScaffoldMessengerState messenger,
    AppLocalizations l10n,
    BackupOutcome outcome, {
    required String done,
  }) {
    final text = switch (outcome) {
      BackupRestored(:final report) => l10n.backupRestored(report.transactions),
      BackupShared(shared: true) => done,
      BackupShared() => l10n.backupNotShared,
      BackupFailed(:final failure) => failureMessage(l10n, failure),
      BackupCancelled() => null,
    };
    if (text == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final password = await showAppSheet<String>(
      context,
      const PasswordSheet(isNew: true),
    );
    if (password == null) return;
    final outcome = await ref
        .read(backupNotifierProvider.notifier)
        .create(password);
    _report(messenger, l10n, outcome, done: l10n.backupReady);
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(backupNotifierProvider.notifier);
    final bytes = await notifier.pick();
    if (bytes == null || !context.mounted) return;
    final password = await showAppSheet<String>(
      context,
      const PasswordSheet(isNew: false),
    );
    if (password == null || !context.mounted) return;
    // Replacing everything is the one decision here that cannot be undone.
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupConfirmTitle),
        content: Text(l10n.backupConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.backupConfirmReplace),
          ),
        ],
      ),
    );
    // Null means dismissed: keep the data.
    if (sure != true) return;
    final outcome = await notifier.restore(bytes, password);
    _report(messenger, l10n, outcome, done: '');
  }

  Future<void> _csv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref.read(backupNotifierProvider.notifier).exportCsv();
    _report(messenger, l10n, outcome, done: l10n.backupCsvReady);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final tiles = CategoryColors.of(context);
    final busy = ref.watch(backupNotifierProvider);
    return LargeTitlePage(
      title: Text(l10n.backupTitle),
      leading: RoundIconButton(
        icon: Icons.arrow_back_rounded,
        tooltip: l10n.back,
        floating: false,
        color: colors.onSurface,
        onPressed: context.pop,
      ),
      children: [
        if (busy)
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                SizedBox.square(
                  dimension: AppMetrics.of(context).iconSize,
                  child: const CircularProgressIndicator(),
                ),
                SizedBox(width: AppMetrics.of(context).spaceSm),
                Text(l10n.backupWorking),
              ],
            ),
          ),
        Entrance(
          child: _ActionCard(
            icon: Icons.lock_rounded,
            tile: tiles.green,
            title: l10n.backupCardTitle,
            body: l10n.backupCardBody,
            action: FilledButton(
              onPressed: busy ? null : () => unawaited(_create(context, ref)),
              child: Text(l10n.backupCreate),
            ),
          ),
        ),
        Entrance(
          index: 1,
          child: _ActionCard(
            icon: Icons.settings_backup_restore_rounded,
            tile: tiles.blue,
            title: l10n.backupRestoreTitle,
            body: l10n.backupRestoreBody,
            action: OutlinedButton(
              onPressed: busy ? null : () => unawaited(_restore(context, ref)),
              child: Text(l10n.backupRestoreChoose),
            ),
          ),
        ),
        Entrance(
          index: 2,
          child: _ActionCard(
            icon: Icons.table_view_rounded,
            tile: tiles.amber,
            title: l10n.backupCsvTitle,
            body: l10n.backupCsvBody,
            action: OutlinedButton(
              onPressed: busy ? null : () => unawaited(_csv(context, ref)),
              child: Text(l10n.backupCsvExport),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const new({
    required this.icon,
    required this.tile,
    required this.title,
    required this.body,
    required this.action,
  });

  final IconData icon;
  final Color tile;
  final String title;
  final String body;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconTile(icon: icon, color: tile),
              SizedBox(width: metrics.spaceMd),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: textTheme.titleMedium),
                ),
              ),
            ],
          ),
          SizedBox(height: metrics.spaceSm),
          Text(body, style: textTheme.bodyMedium),
          SizedBox(height: metrics.spaceMd),
          action,
        ],
      ),
    );
  }
}
