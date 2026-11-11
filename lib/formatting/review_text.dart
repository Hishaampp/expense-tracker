import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';

/// The supporting line of a review card: account (if known), date and
/// time, joined with the locale's separator.
String reviewDetails(
  AppLocalizations l10n,
  String locale, {
  required String accountName,
  required DateTime localTime,
}) {
  final when = l10n.listPair(
    formatShortDate(localTime, locale),
    formatTime(localTime, locale),
  );
  return accountName.isEmpty ? when : l10n.listPair(accountName, when);
}
