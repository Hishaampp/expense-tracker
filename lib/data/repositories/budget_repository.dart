import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/budget_plan.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/common.dart';

/// Reads and writes budgets, and remembers which alerts were shown.
class BudgetRepository {
  /// Creates the repository over [_db].
  new(this._db, this._clock, this._log);

  final AppDatabase _db;
  final Clock _clock;
  final AppLogger _log;

  static const String _monthId = 'month';

  static String _categoryId(String categoryId) => 'category:$categoryId';

  /// Every budget. Live.
  Stream<BudgetPlan> watchPlan() {
    return _db.select(_db.budgets).watch().map((rows) {
      Money? monthly;
      final byCategory = <String, Money>{};
      for (final row in rows) {
        final amount = Money(row.amountPaise);
        if (row.categoryId case final id?) {
          byCategory[id] = amount;
        } else {
          monthly = amount;
        }
      }
      return BudgetPlan(
        monthly: monthly,
        byCategory: Map.unmodifiable(byCategory),
      );
    });
  }

  /// Sets the monthly budget to [amount], or removes it with null.
  @useResult
  Future<Result<Money?, StoreFailure>> setMonthly(Money? amount) =>
      _set('budget.month', _monthId, null, amount);

  /// Sets the budget of category [categoryId], or removes it with null.
  @useResult
  Future<Result<Money?, StoreFailure>> setCategory(
    String categoryId,
    Money? amount,
  ) => _set('budget.category', _categoryId(categoryId), categoryId, amount);

  Future<Result<Money?, StoreFailure>> _set(
    String event,
    String id,
    String? categoryId,
    Money? amount,
  ) async {
    try {
      if (amount == null || !amount.isPositive) {
        await (_db.delete(_db.budgets)..where((b) => b.id.equals(id))).go();
        return const Ok(null);
      }
      await _db
          .into(_db.budgets)
          .insertOnConflictUpdate(
            BudgetsCompanion.insert(
              id: id,
              categoryId: Value(categoryId),
              amountPaise: amount.paise,
            ),
          );
      return Ok(amount);
    } on SqliteException catch (e, st) {
      _log.error(event, e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Records [keys] as fired and returns those that had not fired before,
  /// in one transaction, so an alert is shown once even if two checks race.
  @useResult
  Future<Result<Set<String>, StoreFailure>> markFired(Set<String> keys) async {
    if (keys.isEmpty) return const Ok({});
    try {
      final now = _clock.now().toUtc().millisecondsSinceEpoch;
      final fresh = await _db.transaction(() async {
        final existing = await (_db.select(
          _db.firedAlerts,
        )..where((a) => a.key.isIn(keys))).map((a) => a.key).get();
        final added = keys.difference(existing.toSet());
        await _db.batch((batch) {
          batch.insertAll(_db.firedAlerts, [
            for (final key in added)
              FiredAlertsCompanion.insert(key: key, firedAt: now),
          ], mode: InsertMode.insertOrIgnore);
        });
        return added;
      });
      return Ok(fresh);
    } on SqliteException catch (e, st) {
      _log.error('budget.alerts', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }
}
