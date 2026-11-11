import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/budget_plan.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:meta/meta.dart';

/// What a budget alert is about.
enum AlertSubject {
  /// The monthly budget.
  month,

  /// One category's budget.
  category,

  /// One Room's budget.
  room,
}

/// A budget threshold that has been reached (spec §10). Each [key] fires
/// at most once: the database records it.
@immutable
final class BudgetAlert {
  /// Creates the alert.
  const new({
    required this.subject,
    required this.percent,
    required this.key,
    this.subjectId,
  });

  /// What the alert is about.
  final AlertSubject subject;

  /// The category or Room id; null for the monthly budget.
  final String? subjectId;

  /// The threshold reached: 80 or 100.
  final int percent;

  /// Stable identity: subject, id, budget period and threshold. A month's
  /// alerts start again next month; a Room's fire once in its life.
  final String key;

  /// Whether the budget is used up.
  bool get isFull => percent >= 100;

  @override
  bool operator ==(Object other) => other is BudgetAlert && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'BudgetAlert($key)';
}

/// The thresholds that warn: 80% and 100% for the month and Rooms, 100%
/// only for a category (spec §10).
const List<int> monthThresholds = [80, 100];

/// See [monthThresholds].
const List<int> categoryThresholds = [100];

/// Every threshold reached in [period] by [summary] against [plan], and by
/// each active Room's spending in [roomSpentPaise] against its own budget.
/// The caller drops keys already fired, then [loudest] picks what to show.
List<BudgetAlert> reachedAlerts({
  required BudgetPlan plan,
  required MonthSummary summary,
  required MonthPeriod period,
  required List<Room> rooms,
  required Map<String, int> roomSpentPaise,
}) {
  final month = LocalDay.of(period.start).value;
  final alerts = <BudgetAlert>[];

  void check({
    required AlertSubject subject,
    required String? id,
    required Money? budget,
    required int spentPaise,
    required List<int> thresholds,
    required String scope,
  }) {
    if (budget == null || !budget.isPositive) return;
    for (final percent in thresholds) {
      // spent / budget >= percent / 100, in whole paise.
      if (spentPaise * 100 >= budget.paise * percent) {
        alerts.add(
          BudgetAlert(
            subject: subject,
            subjectId: id,
            percent: percent,
            key: '$scope:$percent',
          ),
        );
      }
    }
  }

  check(
    subject: AlertSubject.month,
    id: null,
    budget: plan.monthly,
    spentPaise: summary.spentForBudget.paise,
    thresholds: monthThresholds,
    scope: 'month:$month',
  );
  for (final entry in plan.byCategory.entries) {
    check(
      subject: AlertSubject.category,
      id: entry.key,
      budget: entry.value,
      spentPaise: summary.budgetByCategory[entry.key]?.paise ?? 0,
      thresholds: categoryThresholds,
      scope: 'category:${entry.key}:$month',
    );
  }
  for (final room in rooms) {
    if (!room.isActive) continue;
    check(
      subject: AlertSubject.room,
      id: room.id,
      budget: room.budget,
      spentPaise: roomSpentPaise[room.id] ?? 0,
      thresholds: monthThresholds,
      scope: 'room:${room.id}',
    );
  }
  return alerts;
}

/// One alert per subject: the highest threshold among [fresh]. A budget
/// set when it is already passed says "used up" once, not 80% and then
/// 100%.
List<BudgetAlert> loudest(Iterable<BudgetAlert> fresh) {
  final bySubject = <(AlertSubject, String?), BudgetAlert>{};
  for (final alert in fresh) {
    final id = (alert.subject, alert.subjectId);
    final current = bySubject[id];
    if (current == null || alert.percent > current.percent) {
      bySubject[id] = alert;
    }
  }
  return bySubject.values.toList(growable: false);
}
