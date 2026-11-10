import 'package:meta/meta.dart';

/// One budgeting month: from the user's "month starts on day N" (spec §5.9)
/// up to, but not including, the same day of the next month.
///
/// All dates are device-local calendar dates at midnight. When a month is
/// shorter than N, the period starts on that month's last day.
@immutable
final class MonthPeriod {
  const new _(this.start, this.end, this.startDay);

  /// The period that contains [localDate], for months starting on
  /// [startDay] (1–31; values outside are clamped).
  factory containing(DateTime localDate, {int startDay = 1}) {
    final day = startDay.clamp(1, 31);
    final thisStart = _startIn(localDate.year, localDate.month, day);
    final date = DateTime(localDate.year, localDate.month, localDate.day);
    if (date.isBefore(thisStart)) {
      final previous = _startIn(localDate.year, localDate.month - 1, day);
      return MonthPeriod._(previous, thisStart, day);
    }
    final next = _startIn(localDate.year, localDate.month + 1, day);
    return MonthPeriod._(thisStart, next, day);
  }

  /// Largest start day the user can choose. Days 29–31 do not exist in
  /// every month.
  static const int maxStartDaySetting = 28;

  /// First local day of the period, at midnight.
  final DateTime start;

  /// First local day after the period, at midnight (exclusive).
  final DateTime end;

  /// The configured start day (1–31) this period was built with.
  final int startDay;

  /// [start] as UTC epoch milliseconds (inclusive bound for queries).
  int get startUtcMs => start.toUtc().millisecondsSinceEpoch;

  /// [end] as UTC epoch milliseconds (exclusive bound for queries).
  int get endUtcMs => end.toUtc().millisecondsSinceEpoch;

  /// The period after this one.
  MonthPeriod get next => MonthPeriod.containing(end, startDay: startDay);

  /// The period before this one.
  MonthPeriod get previous => MonthPeriod.containing(
    start.subtract(const Duration(days: 1)),
    startDay: startDay,
  );

  /// The period [months] after this one (before it, when negative).
  MonthPeriod shifted(int months) {
    var period = this;
    for (var i = 0; i < months.abs(); i++) {
      period = months > 0 ? period.next : period.previous;
    }
    return period;
  }

  /// Whether [localDateTime] falls inside the period.
  bool contains(DateTime localDateTime) =>
      !localDateTime.isBefore(start) && localDateTime.isBefore(end);

  /// Days of the period up to and including [localDate]: the whole length
  /// for a past period, zero for a future one.
  int daysElapsedOn(DateTime localDate) {
    final day = DateTime.utc(localDate.year, localDate.month, localDate.day);
    final from = DateTime.utc(start.year, start.month, start.day);
    final to = DateTime.utc(end.year, end.month, end.day);
    if (day.isBefore(from)) return 0;
    final last = day.isBefore(to) ? day : to.subtract(const Duration(days: 1));
    return last.difference(from).inDays + 1;
  }

  /// Days from [localDate] to the end of the period, counting [localDate]
  /// itself. Zero if [localDate] is outside the period.
  int daysLeftIncluding(DateTime localDate) {
    if (!contains(localDate)) return 0;
    final today = DateTime(localDate.year, localDate.month, localDate.day);
    // Calendar-day difference via UTC dates, so a DST shift cannot skew it.
    final from = DateTime.utc(today.year, today.month, today.day);
    final to = DateTime.utc(end.year, end.month, end.day);
    return to.difference(from).inDays;
  }

  // DateTime normalises month 0 and 13 into the neighbouring year.
  static DateTime _startIn(int year, int month, int startDay) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = startDay > daysInMonth ? daysInMonth : startDay;
    return DateTime(year, month, day);
  }

  @override
  bool operator ==(Object other) =>
      other is MonthPeriod &&
      other.start == start &&
      other.end == end &&
      other.startDay == startDay;

  @override
  int get hashCode => Object.hash(start, end, startDay);
}
