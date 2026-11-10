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

/// The large title for [period]: the month it belongs to ("November"),
/// with the year when it is not [today]'s year. A period that starts on a
/// later day is named after the month it ends in.
String formatPeriodTitle(MonthPeriod period, DateTime today, String locale) {
  final named = period.start.day == 1
      ? period.start
      : period.end.subtract(const Duration(days: 1));
  return named.year == today.year
      ? DateFormat.MMMM(locale).format(named)
      : DateFormat.yMMMM(locale).format(named);
}

/// A day and month, for example `Oct 25`.
String formatDayMonth(DateTime localDay, String locale) {
  return DateFormat.MMMd(locale).format(localDay);
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
