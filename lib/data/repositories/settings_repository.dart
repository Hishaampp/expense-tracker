import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/common.dart';

/// Reads and writes app settings.
class SettingsRepository {
  /// Creates the repository over [_db].
  new(this._db, this._log);

  final AppDatabase _db;
  final AppLogger _log;

  static const String _monthStartDayKey = 'month_start_day';

  /// The day of the month a budgeting month starts on (spec §5.9).
  /// Defaults to 1.
  Stream<int> watchMonthStartDay() {
    final query = _db.select(_db.settings)
      ..where((s) => s.key.equals(_monthStartDayKey));
    return query.watchSingleOrNull().map(
      (row) => (int.tryParse(row?.value ?? '') ?? 1).clamp(
        1,
        MonthPeriod.maxStartDaySetting,
      ),
    );
  }

  /// Saves the month start [day] (clamped to 1–28).
  @useResult
  Future<Result<int, StoreFailure>> setMonthStartDay(int day) async {
    final value = day.clamp(1, MonthPeriod.maxStartDaySetting);
    try {
      await _db
          .into(_db.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(key: _monthStartDayKey, value: '$value'),
          );
      return Ok(value);
    } on SqliteException catch (e, st) {
      _log.error('settings.month_start_day', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }
}
