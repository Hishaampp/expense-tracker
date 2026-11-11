import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/notice.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/common.dart';

/// The in-app notification inbox.
class NoticeRepository {
  /// Creates the repository over [_db].
  new(this._db, this._clock, this._log);

  final AppDatabase _db;
  final Clock _clock;
  final AppLogger _log;

  /// How long a notice stays in the inbox.
  static const Duration keepFor = Duration(days: 60);

  /// Every notice, newest first. Live.
  Stream<List<Notice>> watchAll() {
    final query = _db.select(_db.notices)
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);
    return query.watch().map((rows) => rows.map(_fromRow).toList());
  }

  /// How many notices are unread. Live.
  Stream<int> watchUnreadCount() {
    final count = _db.notices.id.count();
    final query = _db.selectOnly(_db.notices)
      ..addColumns([count])
      ..where(_db.notices.readAt.isNull());
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Keeps [notice], unless one with its id is already kept. Returns
  /// whether it was added.
  @useResult
  Future<Result<bool, StoreFailure>> add(Notice notice) async {
    try {
      // An ignored insert still reports the last row id, so ask first.
      if (await exists(notice.id)) return const Ok(false);
      await _db
          .into(_db.notices)
          .insert(
            NoticesCompanion.insert(
              id: notice.id,
              kind: notice.kind,
              title: notice.title,
              body: notice.body,
              route: Value(notice.route),
              createdAt: notice.createdAt.toUtc().millisecondsSinceEpoch,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return const Ok(true);
    } on SqliteException catch (e, st) {
      _log.error('notice.add', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Whether a notice with [id] is kept.
  Future<bool> exists(String id) async {
    final query = _db.select(_db.notices)..where((n) => n.id.equals(id));
    return await query.getSingleOrNull() != null;
  }

  /// Marks every unread notice as seen now.
  @useResult
  Future<Result<int, StoreFailure>> markAllRead() async {
    try {
      final now = _clock.now().toUtc().millisecondsSinceEpoch;
      final changed =
          await (_db.update(_db.notices)..where((n) => n.readAt.isNull()))
              .write(NoticesCompanion(readAt: Value(now)));
      return Ok(changed);
    } on SqliteException catch (e, st) {
      _log.error('notice.read', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Removes notices older than [keepFor].
  @useResult
  Future<Result<int, StoreFailure>> purgeOld() async {
    try {
      final cutoff = _clock.now().toUtc().subtract(keepFor);
      final removed =
          await (_db.delete(_db.notices)..where(
                (n) => n.createdAt.isSmallerThanValue(
                  cutoff.millisecondsSinceEpoch,
                ),
              ))
              .go();
      return Ok(removed);
    } on SqliteException catch (e, st) {
      _log.error('notice.purge', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  static Notice _fromRow(NoticeRow row) => Notice(
    id: row.id,
    kind: row.kind,
    title: row.title,
    body: row.body,
    route: row.route,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
    readAt: row.readAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row.readAt!, isUtc: true),
  );
}
