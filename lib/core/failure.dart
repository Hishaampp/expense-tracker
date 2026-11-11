/// A recoverable failure. Carries a stable [code] and typed fields, never a
/// user-facing string; screens turn the code into localized text.
sealed class Failure {
  const new();

  /// Stable identifier, for example `store.write_failed`.
  String get code;
}

/// A failure of the on-device database.
sealed class StoreFailure extends Failure {
  const new();
}

/// A write could not be saved.
final class StoreWriteFailed extends StoreFailure {
  /// Creates the failure.
  const new();

  @override
  String get code => 'store.write_failed';
}

/// The record to change no longer exists.
final class StoreRecordMissing extends StoreFailure {
  /// Creates the failure for the record with [id].
  const new(this.id);

  /// Id of the missing record.
  final String id;

  @override
  String get code => 'store.record_missing';
}

/// A backup could not be made or restored.
sealed class BackupFailure extends Failure {
  const new();
}

/// The password does not open this backup (or the file was changed).
final class BackupWrongPassword extends BackupFailure {
  /// Creates the failure.
  const new();

  @override
  String get code => 'backup.wrong_password';
}

/// The file is not a backup made by this app.
final class BackupNotABackup extends BackupFailure {
  /// Creates the failure.
  const new();

  @override
  String get code => 'backup.not_a_backup';
}

/// The backup comes from a newer version of the app.
final class BackupTooNew extends BackupFailure {
  /// Creates the failure.
  const new();

  @override
  String get code => 'backup.too_new';
}

/// The file could not be written or read.
final class BackupFileFailed extends BackupFailure {
  /// Creates the failure.
  const new();

  @override
  String get code => 'backup.file_failed';
}
