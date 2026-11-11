import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/appearance_mode.dart';
import 'package:expense_tracker/core/models/retention.dart';
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
  static const String _appearanceKey = 'appearance';
  static const String _iosSetupKey = 'ios_shortcut_setup_at';
  static const String _weeklyReviewKey = 'weekly_review';
  static const String _watchCategoryKey = 'watch_category';
  static const String _weeklySinceKey = 'weekly_review_since';
  static const String _onboardedKey = 'onboarded';
  static const String _appLockKey = 'app_lock';
  static const String _retentionKey = 'raw_text_retention';

  /// Whether the app asks for Face ID, fingerprint or the passcode on
  /// open. Defaults to off. Live.
  Stream<bool> watchAppLock() => _watch(_appLockKey).map((v) => v == 'on');

  /// Whether the app lock is on, read once (before the first frame).
  Future<bool> appLockOn() async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(_appLockKey))).getSingleOrNull();
    return row?.value == 'on';
  }

  /// Turns the app lock on or off.
  @useResult
  Future<Result<bool, StoreFailure>> setAppLock({required bool on}) =>
      _put('settings.app_lock', _appLockKey, on ? 'on' : 'off', on);

  /// How long original message text is kept. Live.
  Stream<RawTextRetention> watchRetention() =>
      _watch(_retentionKey).map(RawTextRetention.parse);

  /// How long original message text is kept, read once.
  Future<RawTextRetention> retention() async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(_retentionKey))).getSingleOrNull();
    return RawTextRetention.parse(row?.value);
  }

  /// Saves the retention [choice].
  @useResult
  Future<Result<RawTextRetention, StoreFailure>> setRetention(
    RawTextRetention choice,
  ) => _put('settings.retention', _retentionKey, choice.name, choice);

  /// Whether the first-launch welcome is done: it was finished, or the
  /// app already holds transactions from before it existed.
  Future<bool> isOnboarded() async {
    final setting = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(_onboardedKey))).getSingleOrNull();
    if (setting != null) return true;
    final any = await (_db.select(_db.transactions)..limit(1)).get();
    return any.isNotEmpty;
  }

  /// Records that the first-launch welcome is done.
  @useResult
  Future<Result<bool, StoreFailure>> markOnboarded() =>
      _put('settings.onboarded', _onboardedKey, 'yes', true);

  /// When the weekly review was first scheduled, or null.
  Future<DateTime?> weeklyReviewSince() async {
    final query = _db.select(_db.settings)
      ..where((s) => s.key.equals(_weeklySinceKey));
    final ms = int.tryParse((await query.getSingleOrNull())?.value ?? '');
    return ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  /// Records [atUtc] as when the weekly review was first scheduled, unless
  /// a time is already recorded.
  @useResult
  Future<Result<DateTime, StoreFailure>> markWeeklyReviewSince(
    DateTime atUtc,
  ) async {
    final known = await weeklyReviewSince();
    if (known != null) return Ok(known);
    return await _put(
      'settings.weekly_since',
      _weeklySinceKey,
      '${atUtc.millisecondsSinceEpoch}',
      atUtc,
    );
  }

  Stream<String?> _watch(String key) {
    final query = _db.select(_db.settings)..where((s) => s.key.equals(key));
    return query.watchSingleOrNull().map((row) => row?.value);
  }

  Future<Result<T, StoreFailure>> _put<T>(
    String event,
    String key,
    String? value,
    T result,
  ) async {
    try {
      if (value == null) {
        await (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();
      } else {
        await _db
            .into(_db.settings)
            .insertOnConflictUpdate(
              SettingsCompanion.insert(key: key, value: value),
            );
      }
      return Ok(result);
    } on SqliteException catch (e, st) {
      _log.error(event, e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Whether the Sunday-evening weekly review notification is on. Defaults
  /// to on (spec §10).
  Stream<bool> watchWeeklyReview() =>
      _watch(_weeklyReviewKey).map((value) => value != 'off');

  /// Turns the weekly review notification on or off.
  @useResult
  Future<Result<bool, StoreFailure>> setWeeklyReview({required bool on}) =>
      _put('settings.weekly_review', _weeklyReviewKey, on ? 'on' : 'off', on);

  /// The category the user chose to watch next week, or null (spec §10).
  Stream<String?> watchWatchedCategory() => _watch(_watchCategoryKey);

  /// Sets the category to watch, or clears it with null.
  @useResult
  Future<Result<String?, StoreFailure>> setWatchedCategory(
    String? categoryId,
  ) => _put(
    'settings.watch_category',
    _watchCategoryKey,
    categoryId,
    categoryId,
  );

  /// When the user finished the iPhone Shortcuts setup, or null.
  Stream<DateTime?> watchIosShortcutSetupAt() {
    final query = _db.select(_db.settings)
      ..where((s) => s.key.equals(_iosSetupKey));
    return query.watchSingleOrNull().map((row) {
      final ms = int.tryParse(row?.value ?? '');
      return ms == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    });
  }

  /// Records that the iPhone Shortcuts setup was finished at [atUtc].
  @useResult
  Future<Result<DateTime, StoreFailure>> setIosShortcutSetupAt(
    DateTime atUtc,
  ) async {
    try {
      await _db
          .into(_db.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(
              key: _iosSetupKey,
              value: '${atUtc.millisecondsSinceEpoch}',
            ),
          );
      return Ok(atUtc);
    } on SqliteException catch (e, st) {
      _log.error('settings.ios_setup', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Light, dark or follow the phone. Defaults to following the phone.
  Stream<AppearanceMode> watchAppearance() {
    final query = _db.select(_db.settings)
      ..where((s) => s.key.equals(_appearanceKey));
    return query.watchSingleOrNull().map(
      (row) => AppearanceMode.parse(row?.value),
    );
  }

  /// Saves the appearance [mode].
  @useResult
  Future<Result<AppearanceMode, StoreFailure>> setAppearance(
    AppearanceMode mode,
  ) async {
    try {
      await _db
          .into(_db.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(key: _appearanceKey, value: mode.name),
          );
      return Ok(mode);
    } on SqliteException catch (e, st) {
      _log.error('settings.appearance', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

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
