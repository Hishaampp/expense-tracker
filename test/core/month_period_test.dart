import 'package:expense_tracker/core/month_period.dart';
import 'package:test/test.dart';

void main() {
  group('start day 1', () {
    test('a calendar month', () {
      final period = MonthPeriod.containing(DateTime(2026, 11, 10));
      expect(period.start, DateTime(2026, 11));
      expect(period.end, DateTime(2026, 12));
    });

    test('first and last instants', () {
      final period = MonthPeriod.containing(DateTime(2026, 11, 10));
      expect(period.contains(DateTime(2026, 11)), isTrue);
      expect(period.contains(DateTime(2026, 11, 30, 23, 59, 59)), isTrue);
      expect(period.contains(DateTime(2026, 12)), isFalse);
      expect(period.contains(DateTime(2026, 10, 31, 23, 59, 59)), isFalse);
    });

    test('December rolls into the next year', () {
      final period = MonthPeriod.containing(DateTime(2026, 12, 31));
      expect(period.end, DateTime(2027));
      expect(period.next.start, DateTime(2027));
    });
  });

  group('custom start day', () {
    test('on or after the start day belongs to this month', () {
      final period = MonthPeriod.containing(
        DateTime(2026, 11, 25),
        startDay: 25,
      );
      expect(period.start, DateTime(2026, 11, 25));
      expect(period.end, DateTime(2026, 12, 25));
    });

    test('before the start day belongs to the previous month', () {
      final period = MonthPeriod.containing(
        DateTime(2026, 11, 24),
        startDay: 25,
      );
      expect(period.start, DateTime(2026, 10, 25));
      expect(period.end, DateTime(2026, 11, 25));
    });

    test('January before the start day reaches back a year', () {
      final period = MonthPeriod.containing(DateTime(2027, 1, 3), startDay: 5);
      expect(period.start, DateTime(2026, 12, 5));
      expect(period.end, DateTime(2027, 1, 5));
    });

    test('a start day past the end of a short month uses its last day', () {
      final period = MonthPeriod.containing(
        DateTime(2027, 2, 28),
        startDay: 31,
      );
      expect(period.start, DateTime(2027, 2, 28));
      expect(period.end, DateTime(2027, 3, 31));
      final before = MonthPeriod.containing(
        DateTime(2027, 2, 27),
        startDay: 31,
      );
      expect(before.start, DateTime(2027, 1, 31));
      expect(before.end, DateTime(2027, 2, 28));
    });

    test('leap February', () {
      final period = MonthPeriod.containing(
        DateTime(2028, 2, 29),
        startDay: 30,
      );
      expect(period.start, DateTime(2028, 2, 29));
    });

    test('periods tile the calendar with no gap or overlap', () {
      for (final startDay in [1, 5, 15, 28, 29, 30, 31]) {
        var period = MonthPeriod.containing(DateTime(2026), startDay: startDay);
        for (var i = 0; i < 30; i++) {
          final next = period.next;
          expect(next.start, period.end, reason: 'startDay $startDay');
          expect(next.previous, period, reason: 'startDay $startDay');
          period = next;
        }
      }
    });
  });

  group('daysLeftIncluding', () {
    test('counts today', () {
      final period = MonthPeriod.containing(DateTime(2026, 11, 10));
      expect(period.daysLeftIncluding(DateTime(2026, 11, 10, 18)), 21);
    });

    test('is 1 on the last day', () {
      final period = MonthPeriod.containing(DateTime(2026, 11, 30));
      expect(period.daysLeftIncluding(DateTime(2026, 11, 30, 23, 59)), 1);
    });

    test('is 0 outside the period', () {
      final period = MonthPeriod.containing(DateTime(2026, 11, 10));
      expect(period.daysLeftIncluding(DateTime(2026, 12)), 0);
    });
  });
}
