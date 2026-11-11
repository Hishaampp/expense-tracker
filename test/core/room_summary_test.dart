import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:expense_tracker/core/room_summary.dart';
import 'package:test/test.dart';

var _n = 0;

MoneyTransaction _txn(
  int paise,
  DateTime local, {
  TransactionKind kind = TransactionKind.expense,
  String? categoryId = 'food',
}) => MoneyTransaction(
  id: 't${_n++}',
  kind: kind,
  amount: Money(paise),
  occurredAt: local.toUtc(),
  accountId: 'account_cash',
  categoryId: categoryId,
  roomId: 'room',
  createdAt: local.toUtc(),
  updatedAt: local.toUtc(),
);

Room _room({DateTime? from, DateTime? to, int? budget}) => Room(
  id: 'room',
  name: 'Goa',
  type: RoomType.trip,
  autoTagMode: AutoTagMode.dateWindow,
  createdAt: DateTime.utc(2026),
  startDay: from == null ? null : LocalDay.of(from),
  endDay: to == null ? null : LocalDay.of(to),
  budget: budget == null ? null : Money(budget),
);

void main() {
  test('a 3-day trip: total, per day, budget left', () {
    final room = _room(
      from: DateTime(2026, 11, 8),
      to: DateTime(2026, 11, 10),
      budget: 1500000,
    );
    final summary = RoomSummary.of(room, [
      _txn(300000, DateTime(2026, 11, 8, 12)),
      _txn(450000, DateTime(2026, 11, 9, 20)),
      _txn(150000, DateTime(2026, 11, 10, 9), categoryId: 'fuel'),
      _txn(50000, DateTime(2026, 11, 10, 10), kind: TransactionKind.refund),
    ], today: LocalDay.of(DateTime(2026, 11, 20)));
    expect(summary.spent, const Money(850000));
    expect(summary.days, 3, reason: 'ended trips stop counting days');
    expect(summary.perDay, const Money(283333));
    expect(summary.remaining, const Money(650000));
    expect(summary.progress, closeTo(0.567, 0.001));
    expect(summary.byDay.first.day, LocalDay.of(DateTime(2026, 11, 10)));
    expect(summary.byDay.first.spent, const Money(100000));
  });

  test('an ongoing trip counts days up to today', () {
    final summary = RoomSummary.of(
      _room(from: DateTime(2026, 11, 8)),
      const [],
      today: LocalDay.of(DateTime(2026, 11, 11)),
    );
    expect(summary.days, 4);
    expect(summary.remaining, isNull);
  });

  test('over budget shows a negative remainder', () {
    final summary = RoomSummary.of(_room(budget: 100000), [
      _txn(150000, DateTime(2026, 11, 8)),
    ], today: LocalDay.of(DateTime(2026, 11, 8)));
    expect(summary.remaining, const Money(-50000));
    expect(summary.days, isNull, reason: 'undated');
  });

  test('a wedding across two months: each month shows only its part', () {
    final txns = [
      _txn(5000000, DateTime(2026, 11, 20)),
      _txn(12000000, DateTime(2026, 12, 5)),
    ];
    final whole = RoomSummary.of(
      _room(),
      txns,
      today: LocalDay.of(DateTime(2026, 12, 6)),
    );
    expect(whole.spent, const Money(17000000));
    final november = MonthPeriod.containing(DateTime(2026, 11, 15));
    final inNovember = MonthSummary.of(
      txns.where((t) => november.contains(t.occurredAt.toLocal())),
    );
    expect(inNovember.spentInRooms, const Money(5000000));
    expect(inNovember.spentForBudget, Money.zero);
  });

  test('a local day survives a round trip', () {
    final day = LocalDay.of(DateTime(2026, 3, 29, 23, 30));
    expect(day.date, DateTime(2026, 3, 29));
    expect(LocalDay.of(day.date), day);
  });
}
