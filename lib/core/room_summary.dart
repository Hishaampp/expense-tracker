import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:meta/meta.dart';

/// Spending on one local day.
typedef DaySpend = ({LocalDay day, Money spent});

/// Totals for one Room, derived on read (spec §5.1, §9.4).
@immutable
final class RoomSummary {
  const new _({
    required this.room,
    required this.spent,
    required this.byCategory,
    required this.byDay,
    required this.days,
  });

  /// Folds [transactions] (the Room's own) into totals. Hidden ones and
  /// transfers are ignored; refunds reduce spending (spec §5.5). [today]
  /// ends an open-ended Room's day count.
  factory of(
    Room room,
    Iterable<MoneyTransaction> transactions, {
    required LocalDay today,
  }) {
    final month = MonthSummary.of(transactions);
    final perDay = <LocalDay, int>{};
    for (final txn in transactions) {
      if (txn.isHidden) continue;
      final sign = switch (txn.kind) {
        TransactionKind.expense => 1,
        TransactionKind.refund => -1,
        TransactionKind.income || TransactionKind.transfer => 0,
      };
      if (sign == 0) continue;
      final day = LocalDay.of(txn.occurredAt);
      perDay.update(
        day,
        (v) => v + sign * txn.amount.paise,
        ifAbsent: () => sign * txn.amount.paise,
      );
    }
    final byDay = [
      for (final e in perDay.entries)
        if (e.value > 0) (day: e.key, spent: Money(e.value)),
    ]..sort((a, b) => b.day.value.compareTo(a.day.value));
    return RoomSummary._(
      room: room,
      spent: month.spent,
      byCategory: month.byCategory,
      byDay: List.unmodifiable(byDay),
      days: _daysOf(room, today),
    );
  }

  static int? _daysOf(Room room, LocalDay today) {
    final start = room.startDay;
    if (start == null || today.isBefore(start)) return null;
    final end = room.endDay;
    final last = end == null || today.isBefore(end) ? today : end;
    return last.since(start) + 1;
  }

  /// The Room.
  final Room room;

  /// Expenses minus refunds.
  final Money spent;

  /// Spending per category, largest first.
  final List<CategorySpend> byCategory;

  /// Spending per day, newest first.
  final List<DaySpend> byDay;

  /// Days so far (up to the end day), or null when undated or not started.
  final int? days;

  /// Average spend per day so far, for dated Rooms.
  Money? get perDay {
    final d = days;
    if (d == null || d == 0) return null;
    return Money(spent.paise ~/ d);
  }

  /// Budget left (negative when over), or null without a budget.
  Money? get remaining {
    final budget = room.budget;
    return budget == null ? null : Money(budget.paise - spent.paise);
  }

  /// Share of the budget used, 0 and up, or null without a budget.
  double? get progress {
    final budget = room.budget;
    if (budget == null || budget.paise == 0) return null;
    return spent.paise / budget.paise;
  }
}
