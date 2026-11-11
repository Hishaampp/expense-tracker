import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/services/cloud/cloud_auth.dart';

/// The localized message for a [failure]. Exhaustive: adding a failure
/// type is a compile error here until it has a message.
String failureMessage(AppLocalizations l10n, Failure failure) {
  return switch (failure) {
    StoreWriteFailed() => l10n.failureStoreWrite,
    StoreRecordMissing() => l10n.failureStoreMissing,
    BackupWrongPassword() => l10n.failureBackupPassword,
    BackupNotABackup() => l10n.failureBackupNotBackup,
    BackupTooNew() => l10n.failureBackupTooNew,
    BackupFileFailed() => l10n.failureBackupFile,
  };
}

/// The message for a sign-in [problem] with the optional account (Phase 9).
String cloudProblemMessage(AppLocalizations l10n, CloudAuthProblem problem) =>
    switch (problem) {
      CloudAuthProblem.badCode => l10n.accountProblemCode,
      CloudAuthProblem.tooMany => l10n.accountProblemTooMany,
      CloudAuthProblem.offline => l10n.accountProblemOffline,
    };
