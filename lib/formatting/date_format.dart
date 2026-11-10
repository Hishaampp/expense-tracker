import 'package:expense_tracker/core/month_period.dart';
import 'package:intl/intl.dart';

/// The name of [period], for example `November 2026`. A period that does
/// not start on the 1st is shown as a range: `25 Oct – 24 Nov 2026`.
String formatMonthPeriod(MonthPeriod period, String locale) {
  if (period.start.day == 1) {
    return DateFormat.yMMMM(locale).format(period.start);
  }
  final lastDay = period.end.subtract(const Duration(days: 1));
  final from = DateFormat.MMMd(locale).format(period.start);
  final to = DateFormat.yMMMd(locale).format(lastDay);
  return '$from – $to';
}

/// A day heading, for example `Tue, 10 Nov`.
String formatDayHeading(DateTime localDay, String locale) {
  return DateFormat.MMMEd(locale).format(localDay);
}

/// A short date, for example `10 Nov 2026`.
String formatShortDate(DateTime localDay, String locale) {
  return DateFormat.yMMMd(locale).format(localDay);
}

/// A time of day, for example `9:14 AM`.
String formatTime(DateTime localTime, String locale) {
  return DateFormat.jm(locale).format(localTime);
}
