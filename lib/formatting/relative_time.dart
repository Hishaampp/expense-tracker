import 'package:expense_tracker/l10n/app_localizations.dart';

/// How long ago [then] was, seen from [now]: "just now", "5 minutes ago",
/// "2 hours ago", "yesterday", "3 days ago".
String formatTimeAgo(AppLocalizations l10n, DateTime then, DateTime now) {
  final gap = now.difference(then);
  if (gap.inMinutes < 1) return l10n.timeJustNow;
  if (gap.inHours < 1) return l10n.timeMinutesAgo(gap.inMinutes);
  if (gap.inDays < 1) return l10n.timeHoursAgo(gap.inHours);
  return l10n.timeDaysAgo(gap.inDays);
}
