import 'dart:convert';

import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/backup/backup_codec.dart';
import 'package:expense_tracker/data/backup/csv_export.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How a backup action ended.
sealed class BackupOutcome {
  const new();
}

/// The file was made and handed to the share sheet; [shared] says
/// whether the user saved it somewhere.
final class BackupShared extends BackupOutcome {
  /// Creates the outcome.
  const new({required this.shared});

  /// Whether the user completed the share.
  final bool shared;
}

/// A backup was restored.
final class BackupRestored extends BackupOutcome {
  /// Creates the outcome.
  const new(this.report);

  /// What came back.
  final RestoreReport report;
}

/// The user backed out (no file picked).
final class BackupCancelled extends BackupOutcome {
  /// Creates the outcome.
  const new();
}

/// It failed.
final class BackupFailed extends BackupOutcome {
  /// Creates the outcome.
  const new(this.failure);

  /// Why.
  final Failure failure;
}

/// Backup & export's view model. Its state is whether work is running.
class BackupNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<BackupOutcome> _busy(Future<BackupOutcome> Function() work) async {
    state = true;
    try {
      return await work();
    } finally {
      state = false;
    }
  }

  /// Makes an encrypted backup with [password] and opens the share sheet.
  Future<BackupOutcome> create(String password) => _busy(() async {
    final file = await ref.read(backupCodecProvider).export(password);
    switch (file) {
      case Err(:final failure):
        return BackupFailed(failure);
      case Ok(:final value):
        final now = ref.read(clockProvider).now();
        final shared = await ref
            .read(fileShareProvider)
            .share(
              name: 'expenses-backup-${_stamp(now)}.expbackup',
              bytes: value,
              mimeType: 'application/octet-stream',
            );
        if (shared) ref.read(hapticsProvider).commit();
        return BackupShared(shared: shared);
    }
  });

  /// Lets the user pick a backup file; null when they cancel.
  Future<Uint8List?> pick() => ref.read(fileShareProvider).pick();

  /// Replaces all data with the backup in [bytes].
  Future<BackupOutcome> restore(Uint8List bytes, String password) =>
      _busy(() async {
        final result = await ref
            .read(backupCodecProvider)
            .restore(bytes, password);
        switch (result) {
          case Err(:final failure):
            return BackupFailed(failure);
          case Ok(:final value):
            ref.read(hapticsProvider).commit();
            return BackupRestored(value);
        }
      });

  /// Exports every payment as CSV and opens the share sheet.
  Future<BackupOutcome> exportCsv() => _busy(() async {
    final csv = transactionsCsv(
      transactions: await ref.read(transactionRepositoryProvider).all(),
      categories: await ref.read(categoriesProvider.future),
      accounts: await ref.read(accountsProvider.future),
      rooms: await ref.read(roomRepositoryProvider).all(),
    );
    final now = ref.read(clockProvider).now();
    final shared = await ref
        .read(fileShareProvider)
        .share(
          name: 'expenses-${_stamp(now)}.csv',
          bytes: Uint8List.fromList(utf8.encode(csv)),
          mimeType: 'text/csv',
        );
    return BackupShared(shared: shared);
  });

  static String _stamp(DateTime local) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }
}

/// Provides [BackupNotifier].
final NotifierProvider<BackupNotifier, bool> backupNotifierProvider =
    NotifierProvider.autoDispose<BackupNotifier, bool>(BackupNotifier.new);
