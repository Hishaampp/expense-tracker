import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:expense_tracker/core/safe_to_spend.dart';
import 'package:test/test.dart';

const _rupee = 100;

/// November 2026, months starting on the 1st: 30 days.
final MonthPeriod _november = MonthPeriod.containing(DateTime(2026, 11, 10));

SafeToSpend _safe({
  required int? budgetRupees,
  required int spentRupees,
  DateTime? today,
  MonthPeriod? period,
}) => SafeToSpend.of(
  budget: budgetRupees == null ? null : Money(budgetRupees * _rupee),
  spent: Money(spentRupees * _rupee),
  period: period ?? _november,
  today: today ?? DateTime(2026, 11, 10),
);

void main() {
  test('no budget, or a zero one, means nothing to show', () {
    expect(_safe(budgetRupees: null, spentRupees: 500), const NoBudget());
    expect(_safe(budgetRupees: 0, spentRupees: 0), const NoBudget());
  });

  test('what is left is shared over the days left, today included', () {
    // 10 to 30 November is 21 days; ₹21,000 left is ₹1,000 a day.
    final safe = _safe(budgetRupees: 30000, spentRupees: 9000);
    expect(safe, isA<OnTrack>());
    final on = safe as OnTrack;
    expect(on.daysLeft, 21);
    expect(on.left, const Money(21000 * _rupee));
    expect(on.perDay, const Money(1000 * _rupee));
    expect(on.used, closeTo(0.3, 1e-9));
  });

  test('the daily amount rounds down, so following it never overspends', () {
    // ₹10,000 over 21 days = ₹476.190…: ₹476.19, never ₹476.20.
    final on = _safe(budgetRupees: 10000, spentRupees: 0) as OnTrack;
    expect(on.perDay, const Money(47619));
    expect(on.perDay.paise * on.daysLeft, lessThanOrEqualTo(on.left.paise));
  });

  test('on the last day of the month, everything left is for today', () {
    final on = _safe(
      budgetRupees: 30000,
      spentRupees: 29000,
      today: DateTime(2026, 11, 30),
    ) as OnTrack;
    expect(on.daysLeft, 1);
    expect(on.perDay, const Money(1000 * _rupee));
  });

  test('a month starting on the salary day ends the day before it', () {
    final period = MonthPeriod.containing(DateTime(2026, 11, 24), startDay: 25);
    final on = _safe(
      budgetRupees: 3000,
      spentRupees: 0,
      period: period,
      today: DateTime(2026, 11, 24),
    ) as OnTrack;
    // 24 November is the last day of the period that started 25 October.
    expect(on.daysLeft, 1);
    expect(on.perDay, const Money(3000 * _rupee));
  });

  test('spending exactly the budget leaves nothing, not an overspend', () {
    final on = _safe(budgetRupees: 5000, spentRupees: 5000) as OnTrack;
    expect(on.left, Money.zero);
    expect(on.perDay, Money.zero);
  });

  test('overspent says by how much', () {
    final safe = _safe(budgetRupees: 5000, spentRupees: 6200);
    expect(
      safe,
      const Overspent(
        budget: Money(5000 * _rupee),
        spent: Money(6200 * _rupee),
        over: Money(1200 * _rupee),
      ),
    );
  });

  test('Rooms outside the budget do not eat into safe to spend', () {
    final at = DateTime.utc(2026, 11, 5);
    MoneyTransaction txn(String id, int rupees, {String? roomId}) =>
        MoneyTransaction(
          id: id,
          kind: TransactionKind.expense,
          amount: Money(rupees * _rupee),
          occurredAt: at,
          accountId: 'account_cash',
          roomId: roomId,
          createdAt: at,
          updatedAt: at,
        );
    final summary = MonthSummary.of(
      [
        txn('a', 6000),
        txn('goa', 40000, roomId: 'goa'),
        txn('wedding', 2000, roomId: 'wedding'),
      ],
      budgetRoomIds: const {'wedding'},
    );
    expect(summary.spent, const Money(48000 * _rupee));
    final on = SafeToSpend.of(
      budget: const Money(30000 * _rupee),
      spent: summary.spentForBudget,
      period: _november,
      today: DateTime(2026, 11, 10),
    ) as OnTrack;
    // ₹30,000 − (₹6,000 + the counted ₹2,000) = ₹22,000; the trip is out.
    expect(on.left, const Money(22000 * _rupee));
  });

  test('a past month counts as one day left', () {
    final october = _november.previous;
    final on =
        _safe(budgetRupees: 1000, spentRupees: 400, period: october) as OnTrack;
    expect(on.daysLeft, 1);
    expect(on.perDay, const Money(600 * _rupee));
  });
}
