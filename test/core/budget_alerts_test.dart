import 'package:expense_tracker/core/budget_alerts.dart';
import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/budget_plan.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:test/test.dart';

final MonthPeriod _november = MonthPeriod.containing(DateTime(2026, 11, 10));

MonthSummary _spent(
  int paise, {
  String? categoryId,
  String? roomId,
  Set<String> budgetRoomIds = const {},
}) {
  final at = DateTime.utc(2026, 11, 5);
  return MonthSummary.of([
    MoneyTransaction(
      id: 't',
      kind: TransactionKind.expense,
      amount: Money(paise),
      occurredAt: at,
      accountId: 'account_cash',
      categoryId: categoryId,
      roomId: roomId,
      createdAt: at,
      updatedAt: at,
    ),
  ], budgetRoomIds: budgetRoomIds);
}

Room _room(String id, {int? budget, RoomStatus status = RoomStatus.active}) =>
    Room(
      id: id,
      name: id,
      type: RoomType.trip,
      startDay: LocalDay.of(DateTime(2026, 11)),
      budget: budget == null ? null : Money(budget),
      autoTagMode: AutoTagMode.dateWindow,
      status: status,
      createdAt: DateTime.utc(2026, 11),
    );

List<String> _keys(List<BudgetAlert> alerts) => [for (final a in alerts) a.key];

void main() {
  final month = LocalDay.of(_november.start).value;

  group('monthly budget', () {
    List<BudgetAlert> at(int spentPaise) => reachedAlerts(
      plan: const BudgetPlan(monthly: Money(100000)),
      summary: _spent(spentPaise),
      period: _november,
      rooms: const [],
      roomSpentPaise: const {},
    );

    test('below 80% nothing is due', () {
      expect(at(79999), isEmpty);
    });

    test('80% exactly is due', () {
      expect(_keys(at(80000)), ['month:$month:80']);
    });

    test('100% brings both thresholds', () {
      expect(_keys(at(100000)), ['month:$month:80', 'month:$month:100']);
    });

    test('next month starts again with new keys', () {
      final december = reachedAlerts(
        plan: const BudgetPlan(monthly: Money(100000)),
        summary: _spent(90000),
        period: _november.next,
        rooms: const [],
        roomSpentPaise: const {},
      );
      expect(_keys(december).single, isNot('month:$month:80'));
    });

    test('a Room outside the budget does not count', () {
      final alerts = reachedAlerts(
        plan: const BudgetPlan(monthly: Money(100000)),
        summary: _spent(90000, roomId: 'goa'),
        period: _november,
        rooms: const [],
        roomSpentPaise: const {},
      );
      expect(alerts, isEmpty);
    });
  });

  test('a category warns only when used up', () {
    List<BudgetAlert> at(int paise) => reachedAlerts(
      plan: const BudgetPlan(byCategory: {'cat_food': Money(50000)}),
      summary: _spent(paise, categoryId: 'cat_food'),
      period: _november,
      rooms: const [],
      roomSpentPaise: const {},
    );
    expect(at(45000), isEmpty);
    expect(_keys(at(50000)), ['category:cat_food:$month:100']);
  });

  test('Rooms warn at 80% and 100% of their own budget, active only', () {
    final alerts = reachedAlerts(
      plan: BudgetPlan.none,
      summary: _spent(0),
      period: _november,
      rooms: [
        _room('goa', budget: 1000000),
        _room('old', budget: 1000, status: RoomStatus.archived),
        _room('free'),
      ],
      roomSpentPaise: const {'goa': 850000, 'old': 5000, 'free': 5000},
    );
    expect(_keys(alerts), ['room:goa:80']);
  });

  test('loudest keeps the highest threshold per budget', () {
    const alerts = [
      BudgetAlert(subject: AlertSubject.month, percent: 80, key: 'm80'),
      BudgetAlert(subject: AlertSubject.month, percent: 100, key: 'm100'),
      BudgetAlert(
        subject: AlertSubject.room,
        subjectId: 'goa',
        percent: 80,
        key: 'r80',
      ),
    ];
    expect(_keys(loudest(alerts))..sort(), ['m100', 'r80']);
  });
}
