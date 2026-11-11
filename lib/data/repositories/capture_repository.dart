import 'package:drift/drift.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/id_generator.dart';
import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/common.dart';

/// A message on the Unparsed list.
typedef UnparsedItem = ({String id, String maskedText, DateTime receivedAt});

/// Records captures that do not become transactions, and serves the
/// Unparsed list (spec §7.2, §7.8). Never logs message text.
class CaptureRepository {
  /// Creates the repository over [_db].
  new(this._db, this._ids, this._log);

  final AppDatabase _db;
  final IdGenerator _ids;
  final AppLogger _log;

  /// Whether a capture with [contentHash] was already recorded.
  Future<bool> isKnown(String contentHash) async {
    final query = _db.select(_db.rawCaptures)
      ..where((c) => c.contentHash.equals(contentHash));
    return await query.getSingleOrNull() != null;
  }

  /// Whether a transaction already carries reference number [refNo].
  Future<bool> hasTransactionWithRef(String refNo) async {
    final query = _db.select(_db.transactions)
      ..where((t) => t.refNo.equals(refNo))
      ..limit(1);
    return await query.getSingleOrNull() != null;
  }

  /// Records [capture] as not a transaction, with [reason].
  @useResult
  Future<Result<void, StoreFailure>> recordDropped(
    RawCapture capture,
    String reason,
  ) {
    return _write('capture.dropped', () async {
      await _db
          .into(_db.rawCaptures)
          .insert(
            _row(capture, 'dropped', dropReason: reason),
            mode: InsertMode.insertOrIgnore,
          );
    });
  }

  /// Records [capture] on the Unparsed list as [maskedText].
  @useResult
  Future<Result<void, StoreFailure>> recordUnparsed(
    RawCapture capture,
    String maskedText,
  ) {
    return _write('capture.unparsed', () {
      return _db.transaction(() async {
        await _db.into(_db.rawCaptures).insert(_row(capture, 'unparsed'));
        await _db
            .into(_db.unparsedMessages)
            .insert(
              UnparsedMessagesCompanion.insert(
                id: _ids.newId(),
                rawCaptureId: capture.id,
                maskedText: maskedText,
                receivedAt: capture.receivedAt.toUtc().millisecondsSinceEpoch,
              ),
            );
      });
    });
  }

  /// When the newest capture from [source] arrived, or null. Live.
  Stream<DateTime?> watchLastCaptureAt(CaptureSource source) {
    final newest = _db.rawCaptures.receivedAt.max();
    final query = _db.selectOnly(_db.rawCaptures)
      ..addColumns([newest])
      ..where(_db.rawCaptures.source.equals(source.wireName));
    return query.watchSingle().map((row) {
      final ms = row.read(newest);
      return ms == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    });
  }

  /// Unresolved Unparsed messages, newest first. Live.
  Stream<List<UnparsedItem>> watchUnparsed() {
    final query = _db.select(_db.unparsedMessages)
      ..where((u) => u.resolvedTransactionId.isNull())
      ..orderBy([(u) => OrderingTerm.desc(u.receivedAt)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (
            id: row.id,
            maskedText: row.maskedText,
            receivedAt: DateTime.fromMillisecondsSinceEpoch(
              row.receivedAt,
              isUtc: true,
            ),
          ),
      ],
    );
  }

  /// The Unparsed message with [id], or null.
  Future<UnparsedItem?> findUnparsed(String id) async {
    final query = _db.select(_db.unparsedMessages)
      ..where((u) => u.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return (
      id: row.id,
      maskedText: row.maskedText,
      receivedAt: DateTime.fromMillisecondsSinceEpoch(
        row.receivedAt,
        isUtc: true,
      ),
    );
  }

  RawCapturesCompanion _row(
    RawCapture capture,
    String status, {
    String? dropReason,
  }) {
    return RawCapturesCompanion.insert(
      id: capture.id,
      contentHash: capture.contentHash,
      source: capture.source.wireName,
      origin: Value(capture.origin),
      receivedAt: capture.receivedAt.toUtc().millisecondsSinceEpoch,
      status: status,
      dropReason: Value(dropReason),
    );
  }

  Future<Result<void, StoreFailure>> _write(
    String event,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      return const Ok(null);
    } on SqliteException catch (e, st) {
      _log.error(event, e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Removes original message text received before [cutoffUtc] (spec
  /// §13). Returns how many messages lost their text.
  @useResult
  Future<Result<int, StoreFailure>> purgeRawText(DateTime cutoffUtc) async {
    try {
      final cleared =
          await (_db.update(_db.transactionSources)..where(
                (s) =>
                    s.rawText.isNotNull() &
                    s.receivedAt.isSmallerThanValue(
                      cutoffUtc.millisecondsSinceEpoch,
                    ),
              ))
              .write(const TransactionSourcesCompanion(rawText: Value(null)));
      return Ok(cleared);
    } on SqliteException catch (e, st) {
      _log.error('capture.purge', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }
}
