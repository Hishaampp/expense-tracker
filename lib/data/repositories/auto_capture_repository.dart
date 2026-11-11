import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/dedup.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/id_generator.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/capture_draft.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/mappers.dart';
import 'package:expense_tracker/data/repositories/transaction_repository.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/common.dart';

/// Reads and writes for automatic capture (spec §7.6) and the review inbox
/// (spec §5.7): what the duplicate check compares against, merging a
/// repeated report into its transaction, and confirming reviewed ones.
class AutoCaptureRepository {
  /// Creates the repository.
  new(this._db, this._transactions, this._clock, this._ids, this._log);

  final AppDatabase _db;
  final TransactionRepository _transactions;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _log;

  /// Saved payments within [duplicateWindow] of [atUtc], or carrying
  /// [refNo], as the duplicate check sees them.
  Future<List<KnownPayment>> knownPaymentsNear(
    DateTime atUtc, {
    String? refNo,
  }) async {
    final from = atUtc.subtract(duplicateWindow).millisecondsSinceEpoch;
    final to = atUtc.add(duplicateWindow).millisecondsSinceEpoch;
    final query = _db.select(_db.transactions)
      ..where(
        (t) =>
            t.occurredAt.isBetweenValues(from, to) |
            (refNo == null ? const Constant(false) : t.refNo.equals(refNo)),
      );
    final rows = await query.get();
    if (rows.isEmpty) return const [];
    final ids = [for (final r in rows) r.id];
    final accountIds = {for (final r in rows) r.accountId};
    final accounts = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.isIn(accountIds))).get();
    final last4 = {for (final a in accounts) a.id: a.last4};
    final sources = await (_db.select(
      _db.transactionSources,
    )..where((s) => s.transactionId.isIn(ids))).get();
    final keys = <String, Set<String>>{};
    for (final s in sources) {
      keys
          .putIfAbsent(s.transactionId, () => {})
          .add(sourceKey(s.source, s.origin));
    }
    return [
      for (final row in rows)
        (
          id: row.id,
          report: PaymentReport(
            amount: Money(row.amountPaise),
            kind: row.kind,
            occurredAt: DateTime.fromMillisecondsSinceEpoch(
              row.occurredAt,
              isUtc: true,
            ),
            sourceKey: '',
            accountLast4: last4[row.accountId],
            refNo: row.refNo,
            payeeKey: row.payeeKey,
            payeeName: row.payeeDisplay,
          ),
          sourceKeys: keys[row.id] ?? const <String>{},
        ),
    ];
  }

  /// The source key the duplicate check compares (`source:origin`).
  static String sourceKey(String source, String? origin) =>
      '$source:${origin ?? ''}';

  /// The expense a refund of [amount] to [payeeKey] most likely reverses:
  /// the same reference number, or the newest expense with that payee and
  /// amount in the 30 days before [beforeUtc] (spec §5.5).
  Future<MoneyTransaction?> findRefundOriginal({
    required Money amount,
    required DateTime beforeUtc,
    String? refNo,
    String? payeeKey,
  }) async {
    if (refNo != null) {
      final byRef =
          await (_db.select(_db.transactions)
                ..where(
                  (t) =>
                      t.refNo.equals(refNo) &
                      t.kind.equals(TransactionKind.expense.name),
                )
                ..limit(1))
              .getSingleOrNull();
      if (byRef != null) return transactionFromRow(byRef);
    }
    if (payeeKey == null) return null;
    final from = beforeUtc.subtract(const Duration(days: 30));
    final row =
        await (_db.select(_db.transactions)
              ..where(
                (t) =>
                    t.payeeKey.equals(payeeKey) &
                    t.amountPaise.equals(amount.paise) &
                    t.kind.equals(TransactionKind.expense.name) &
                    t.occurredAt.isBetweenValues(
                      from.millisecondsSinceEpoch,
                      beforeUtc.millisecondsSinceEpoch,
                    ),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : transactionFromRow(row);
  }

  /// Records [draft]'s capture as another report of transaction
  /// [existingId]: links it, and fills in what the saved one lacked
  /// (reference number, payee, a real account instead of Cash).
  @useResult
  Future<Result<void, StoreFailure>> mergeInto(
    String existingId,
    CaptureDraft draft,
  ) async {
    final now = _clock.now().toUtc();
    final capture = draft.capture;
    try {
      await _db.transaction(() async {
        final row = await (_db.select(
          _db.transactions,
        )..where((t) => t.id.equals(existingId))).getSingle();
        await _db
            .into(_db.rawCaptures)
            .insert(
              RawCapturesCompanion.insert(
                id: capture.id,
                contentHash: capture.contentHash,
                source: capture.source.wireName,
                origin: Value(capture.origin),
                receivedAt: capture.receivedAt.millisecondsSinceEpoch,
                status: 'duplicate',
              ),
              mode: InsertMode.insertOrIgnore,
            );
        await _db
            .into(_db.transactionSources)
            .insert(
              TransactionSourcesCompanion.insert(
                id: _ids.newId(),
                transactionId: existingId,
                rawCaptureId: capture.id,
                source: capture.source.wireName,
                origin: Value(capture.origin),
                receivedAt: capture.receivedAt.millisecondsSinceEpoch,
                rawText: Value(capture.text),
                parserTemplateId: Value(draft.templateId),
                confidence: Value(draft.confidence),
              ),
            );
        final betterAccount =
            row.accountId == Account.cashId && draft.accountLast4 != null
            ? await _transactions.resolveAccount(draft, now)
            : null;
        await (_db.update(
          _db.transactions,
        )..where((t) => t.id.equals(existingId))).write(
          TransactionsCompanion(
            refNo: row.refNo == null
                ? Value(draft.refNo)
                : const Value.absent(),
            payeeKey: row.payeeKey == null
                ? Value(draft.payeeKey)
                : const Value.absent(),
            payeeDisplay: row.payeeDisplay == null
                ? Value(draft.payeeDisplay)
                : const Value.absent(),
            accountId: betterAccount == null
                ? const Value.absent()
                : Value(betterAccount),
            updatedAt: Value(now.millisecondsSinceEpoch),
          ),
        );
      });
      return const Ok(null);
    } on SqliteException catch (e, st) {
      _log.error('capture.merge', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Transactions waiting in the review inbox, newest first. Live.
  Stream<List<MoneyTransaction>> watchNeedsReview() {
    final query = _db.select(_db.transactions)
      ..where(
        (t) =>
            t.reviewStatus.equals(ReviewStatus.needsReview.name) &
            t.isHidden.equals(false),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    return query.watch().map(
      (rows) => rows.map(transactionFromRow).toList(growable: false),
    );
  }

  /// Confirms [id] in [categoryId] (spec §5.7).
  @useResult
  Future<Result<void, StoreFailure>> confirm(String id, String categoryId) {
    return _update(
      'review.confirm',
      id,
      TransactionsCompanion(
        categoryId: Value(categoryId),
        reviewStatus: const Value(ReviewStatus.confirmed),
      ),
    );
  }

  /// Marks [id] as a transfer between the user's own accounts: not
  /// spending (spec §5.4), and confirmed.
  @useResult
  Future<Result<void, StoreFailure>> markTransfer(String id) {
    return _update(
      'review.transfer',
      id,
      const TransactionsCompanion(
        kind: Value(TransactionKind.transfer),
        categoryId: Value(transferCategoryId),
        reviewStatus: Value(ReviewStatus.confirmed),
      ),
    );
  }

  /// Puts [txn] back in the review inbox exactly as it was (Undo).
  @useResult
  Future<Result<void, StoreFailure>> restoreReview(MoneyTransaction txn) {
    return _update(
      'review.undo',
      txn.id,
      TransactionsCompanion(
        kind: Value(txn.kind),
        categoryId: Value(txn.categoryId),
        roomId: Value(txn.roomId),
        reviewStatus: Value(txn.reviewStatus),
      ),
    );
  }

  /// Confirms every waiting transaction in [ids] as [categoryId]. Returns
  /// how many were confirmed.
  @useResult
  Future<Result<int, StoreFailure>> confirmMany(
    Iterable<String> ids,
    String categoryId,
  ) async {
    try {
      final count =
          await (_db.update(_db.transactions)..where(
                (t) =>
                    t.id.isIn(ids) &
                    t.reviewStatus.equals(ReviewStatus.needsReview.name),
              ))
              .write(
                TransactionsCompanion(
                  categoryId: Value(categoryId),
                  reviewStatus: const Value(ReviewStatus.confirmed),
                  updatedAt: Value(_clock.now().toUtc().millisecondsSinceEpoch),
                ),
              );
      return Ok(count);
    } on SqliteException catch (e, st) {
      _log.error('review.confirm_many', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Confirms every waiting transaction that already has a suggested
  /// category. Returns how many were confirmed.
  @useResult
  Future<Result<int, StoreFailure>> confirmAllSuggested() async {
    try {
      final count =
          await (_db.update(_db.transactions)..where(
                (t) =>
                    t.reviewStatus.equals(ReviewStatus.needsReview.name) &
                    t.categoryId.isNotNull(),
              ))
              .write(
                TransactionsCompanion(
                  reviewStatus: const Value(ReviewStatus.confirmed),
                  updatedAt: Value(_clock.now().toUtc().millisecondsSinceEpoch),
                ),
              );
      return Ok(count);
    } on SqliteException catch (e, st) {
      _log.error('review.confirm_all', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Id of the built-in Transfer category.
  static const String transferCategoryId = 'cat_transfer';

  Future<Result<void, StoreFailure>> _update(
    String event,
    String id,
    TransactionsCompanion change,
  ) async {
    try {
      final changed =
          await (_db.update(
            _db.transactions,
          )..where((t) => t.id.equals(id))).write(
            change.copyWith(
              updatedAt: Value(_clock.now().toUtc().millisecondsSinceEpoch),
            ),
          );
      return changed > 0 ? const Ok(null) : Err(StoreRecordMissing(id));
    } on SqliteException catch (e, st) {
      _log.error(event, e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }
}
