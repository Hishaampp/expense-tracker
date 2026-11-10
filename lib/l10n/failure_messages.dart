import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';

/// The localized message for a [failure]. Exhaustive: adding a failure
/// type is a compile error here until it has a message.
String failureMessage(AppLocalizations l10n, Failure failure) {
  return switch (failure) {
    StoreWriteFailed() => l10n.failureStoreWrite,
    StoreRecordMissing() => l10n.failureStoreMissing,
  };
}
