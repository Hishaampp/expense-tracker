import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/spending_stats.dart';
import 'package:expense_tracker/core/weekly_review.dart';
import 'package:test/test.dart';

var _id = 0;

MoneyTransaction _txn(
  DateTime local,
  int rupees, {
  String? categoryId,
  String? payee,
  TransactionKind kind = TransactionKind.expense,
}) => MoneyTransaction(
  id: 't${_id++}',
  kind: kind,
  amount: Money(rupees * 100),
  occurredAt: local.toUtc(),
  accountId: 'account_cash',
  categoryId: categoryId,
  payeeDisplay: payee,
  payeeKey: payee?.toLowerCase(),
  createdAt: local.toUtc(),
  updatedAt: local.toUtc(),
);

LocalDay _day(int year, int month, int day) =>
    LocalDay.of(DateTime(year, month, day, 12));

void main() {
  group('LocalWeek', () {
    test('runs Monday to Sunday', () {
      // Tuesday 10 November 2026.
      final week = LocalWeek.containing(_day(2026, 11, 10));
      expect(week.start, _day(2026, 11, 9));
      expect(week.end, _day(2026, 11, 15));
      expect(week.start.date.weekday, DateTime.monday);
    });

    test('the review on Sunday covers the week ending that day', () {
      final week = LocalWeek.reviewedOn(_day(2026, 11, 15));
      expect(week.start, _day(2026, 11, 9));
    });

    test('opened midweek, the review covers the last full week', () {
      final week = LocalWeek.reviewedOn(_day(2026, 11, 10));
      expect(week.start, _day(2026, 11, 2));
      expect(week.end, _day(2026, 11, 8));
    });
  });

  test('the review compares weeks and ranks categories and payees', () {
    final week = LocalWeek.containing(_day(2026, 11, 9));
    final review = WeeklyReview.of([
      // This week (9–15 Nov).
      _txn(DateTime(2026, 11, 9, 9), 300, categoryId: 'food', payee: 'Swiggy'),
      _txn(DateTime(2026, 11, 10, 9), 200, categoryId: 'food', payee: 'Swiggy'),
      _txn(DateTime(2026, 11, 11, 9), 450, categoryId: 'fuel', payee: 'HP'),
      _txn(DateTime(2026, 11, 12, 9), 50, categoryId: 'bills'),
      _txn(DateTime(2026, 11, 13, 9), 10, categoryId: 'fees', payee: 'Bank'),
      _txn(
        DateTime(2026, 11, 15, 22),
        100,
        categoryId: 'food',
        payee: 'Swiggy',
        kind: TransactionKind.refund,
      ),
      // Last week.
      _txn(DateTime(2026, 11, 3, 9), 1000, categoryId: 'food'),
      // Two weeks ago: ignored.
      _txn(DateTime(2026, 10, 27, 9), 9999, categoryId: 'food'),
    ], week);

    expect(review.spent, const Money(91000));
    expect(review.lastWeekSpent, const Money(100000));
    expect(review.change, const Money(-9000));
    expect(
      [for (final c in review.topCategories) c.categoryId],
      ['fuel', 'food', 'bills'],
    );
    expect(
      [for (final p in review.topPayees) p.name],
      ['Swiggy', 'HP', 'Bank'],
    );
    expect(review.topPayees.first.count, 2);
  });

  group('stats', () {
    final november = MonthPeriod.containing(DateTime(2026, 11, 10));

    test('spending by day covers every day of the month', () {
      final days = spendByDay([
        _txn(DateTime(2026, 11, 1, 8), 100),
        _txn(DateTime(2026, 11, 1, 20), 50),
        _txn(DateTime(2026, 11, 30, 23, 30), 70),
        _txn(DateTime(2026, 12, 1, 0, 5), 999),
      ], november);
      expect(days, hasLength(30));
      expect(days.first.spent, const Money(15000));
      expect(days.last.spent, const Money(7000));
      expect(days[1].spent, Money.zero);
    });

    test('a refund-only day shows as nothing spent', () {
      final days = spendByDay([
        _txn(DateTime(2026, 11, 2, 8), 100, kind: TransactionKind.refund),
      ], november);
      expect(days[1].spent, Money.zero);
    });

    test('spending by month buckets each month', () {
      final months = spendByMonth(
        [
          _txn(DateTime(2026, 10, 31, 23), 100),
          _txn(DateTime(2026, 11, 1, 1), 200),
        ],
        [november.previous, november],
      );
      expect(
        [for (final m in months) m.spent],
        const [Money(10000), Money(20000)],
      );
    });
  });
}
