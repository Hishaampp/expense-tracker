import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/id_generator.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/capture_draft.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/mappers.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/common.dart';

/// The single write path for transactions (spec §5.1). Writes commit before
/// they return; watchers then re-emit on their own.
class TransactionRepository {
  /// Creates the repository over [_db].
  new(this._db, this._clock, this._ids, this._log);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _log;

  /// Transactions whose time falls in [period], newest first.
  Stream<List<MoneyTransaction>> watchInPeriod(MonthPeriod period) =>
      watchBetween(period.startUtcMs, period.endUtcMs);

  /// Transactions from [startUtcMs] (inclusive) to [endUtcMs] (exclusive),
  /// newest first.
  Stream<List<MoneyTransaction>> watchBetween(int startUtcMs, int endUtcMs) {
    final query = _db.select(_db.transactions)
      ..where(
        (t) =>
            t.occurredAt.isBiggerOrEqualValue(startUtcMs) &
            t.occurredAt.isSmallerThanValue(endUtcMs),
      )
      ..orderBy([
        (t) => OrderingTerm.desc(t.occurredAt),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch().map(
      (rows) => rows.map(transactionFromRow).toList(growable: false),
    );
  }

  /// How many expenses each category has had since [sinceUtc], by category
  /// id. Used to put the most-used categories first in Quick Add.
  Future<Map<String, int>> categoryUsageSince(DateTime sinceUtc) async {
    final count = _db.transactions.id.count();
    final query = _db.selectOnly(_db.transactions)
      ..addColumns([_db.transactions.categoryId, count])
      ..where(
        _db.transactions.kind.equals(TransactionKind.expense.name) &
            _db.transactions.categoryId.isNotNull() &
            _db.transactions.occurredAt.isBiggerOrEqualValue(
              sinceUtc.millisecondsSinceEpoch,
            ),
      )
      ..groupBy([_db.transactions.categoryId]);
    final rows = await query.get();
    return {
      for (final row in rows)
        row.read(_db.transactions.categoryId)!: row.read(count) ?? 0,
    };
  }

  /// The transaction with [id], or null if it does not exist.
  Future<MoneyTransaction?> findById(String id) async {
    final query = _db.select(_db.transactions)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : transactionFromRow(row);
  }

  /// Saves a new manual transaction (an expense unless [kind] says
  /// otherwise) and returns it. If [unparsedId] is given, that Unparsed
  /// message is marked resolved in the same database transaction.
  @useResult
  Future<Result<MoneyTransaction, StoreFailure>> addExpense({
    required Money amount,
    required String accountId,
    required String? categoryId,
    TransactionKind kind = TransactionKind.expense,
    DateTime? occurredAt,
    String? note,
    String? unparsedId,
    String? roomId,
  }) {
    final now = _clock.now().toUtc();
    final txn = MoneyTransaction(
      id: _ids.newId(),
      kind: kind,
      amount: amount,
      occurredAt: (occurredAt ?? now).toUtc(),
      accountId: accountId,
      categoryId: categoryId,
      roomId: roomId,
      instrument: Instrument.cash,
      note: _blankToNull(note),
      createdAt: now,
      updatedAt: now,
    );
    return _write('transaction.add', txn, () {
      return _db.transaction(() async {
        await _db.into(_db.transactions).insert(transactionToRow(txn));
        if (unparsedId != null) {
          await (_db.update(
            _db.unparsedMessages,
          )..where((u) => u.id.equals(unparsedId))).write(
            UnparsedMessagesCompanion(resolvedTransactionId: Value(txn.id)),
          );
        }
        return true;
      });
    });
  }

  /// Saves a transaction read from a message, in one database transaction:
  /// finds or creates its account ("HDFC ••1234"), records the capture as
  /// parsed, stores the transaction and links the two (spec §7.6, §7.7).
  /// If [unparsedId] is given, that Unparsed message is marked resolved.
  @useResult
  Future<Result<MoneyTransaction, StoreFailure>> addFromCapture({
    required CaptureDraft draft,
    required Money amount,
    required TransactionKind kind,
    required String? categoryId,
    DateTime? occurredAt,
    String? note,
    String? unparsedId,
    ReviewStatus reviewStatus = ReviewStatus.confirmed,
    String? toAccountId,
    String? linkedTransactionId,
    String? roomId,
    bool isHidden = false,
    String? payeeDisplay,
  }) async {
    final now = _clock.now().toUtc();
    final capture = draft.capture;
    try {
      final txn = await _db.transaction(() async {
        final accountId = await _resolveAccount(draft, now);
        final txn = MoneyTransaction(
          id: _ids.newId(),
          kind: kind,
          amount: amount,
          occurredAt: (occurredAt ?? draft.occurredAt ?? capture.receivedAt)
              .toUtc(),
          accountId: accountId,
          toAccountId: toAccountId,
          categoryId: categoryId,
          roomId: roomId,
          payeeKey: draft.payeeKey,
          payeeDisplay: payeeDisplay ?? draft.payeeDisplay,
          instrument: draft.instrument,
          refNo: draft.refNo,
          note: _blankToNull(note),
          reviewStatus: reviewStatus,
          isHidden: isHidden,
          linkedTransactionId: linkedTransactionId,
          origin: TransactionOrigin.auto,
          createdAt: now,
          updatedAt: now,
        );
        await _db
            .into(_db.rawCaptures)
            .insert(
              RawCapturesCompanion.insert(
                id: capture.id,
                contentHash: capture.contentHash,
                source: capture.source.wireName,
                origin: Value(capture.origin),
                receivedAt: capture.receivedAt.millisecondsSinceEpoch,
                status: 'parsed',
              ),
              mode: InsertMode.insertOrIgnore,
            );
        await _db.into(_db.transactions).insert(transactionToRow(txn));
        await _db
            .into(_db.transactionSources)
            .insert(
              TransactionSourcesCompanion.insert(
                id: _ids.newId(),
                transactionId: txn.id,
                rawCaptureId: capture.id,
                source: capture.source.wireName,
                origin: Value(capture.origin),
                receivedAt: capture.receivedAt.millisecondsSinceEpoch,
                rawText: Value(capture.text),
                parserTemplateId: Value(draft.templateId),
                confidence: Value(draft.confidence),
              ),
            );
        if (unparsedId != null) {
          await (_db.update(
            _db.unparsedMessages,
          )..where((u) => u.id.equals(unparsedId))).write(
            UnparsedMessagesCompanion(resolvedTransactionId: Value(txn.id)),
          );
        }
        return txn;
      });
      return Ok(txn);
    } on SqliteException catch (e, st) {
      _log.error('transaction.add_from_capture', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Finds the account the message names, or creates it; Cash when the
  /// message names none. Must run inside a database transaction.
  Future<String> resolveAccount(CaptureDraft draft, DateTime now) =>
      _resolveAccount(draft, now);

  // Finds the account the message names, or creates it; Cash when the
  // message names none.
  Future<String> _resolveAccount(CaptureDraft draft, DateTime now) async {
    final last4 = draft.accountLast4;
    if (last4 == null) return Account.cashId;
    final type = draft.isCreditCard ? AccountType.creditCard : AccountType.bank;
    final query = _db.select(_db.accounts)
      ..where(
        (a) =>
            a.last4.equals(last4) &
            (draft.bankCode == null
                ? a.bankCode.isNull()
                : a.bankCode.equals(draft.bankCode!)),
      )
      ..limit(1);
    final existing = await query.getSingleOrNull();
    if (existing != null) return existing.id;
    final id = _ids.newId();
    await _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: id,
            name: draft.accountLabel!,
            type: type,
            bankCode: Value(draft.bankCode),
            last4: Value(last4),
            createdAt: now.millisecondsSinceEpoch,
          ),
        );
    return id;
  }

  /// Saves the user's edits to [txn]'s amount, time, account, category,
  /// note and Room, and returns the stored transaction.
  @useResult
  Future<Result<MoneyTransaction, StoreFailure>> edit(
    MoneyTransaction txn, {
    required Money amount,
    required DateTime occurredAt,
    required String accountId,
    required String? categoryId,
    required String? note,
    required String? roomId,
  }) {
    final updated = txn.edited(
      amount: amount,
      occurredAt: occurredAt.toUtc(),
      accountId: accountId,
      categoryId: categoryId,
      note: _blankToNull(note),
      roomId: roomId,
      updatedAt: _clock.now().toUtc(),
    );
    return _write('transaction.edit', updated, () async {
      final changed = await (_db.update(
        _db.transactions,
      )..where((t) => t.id.equals(txn.id))).write(transactionToRow(updated));
      return changed > 0;
    });
  }

  /// Deletes [txn]. Pass the same value to [restore] to undo.
  @useResult
  Future<Result<MoneyTransaction, StoreFailure>> delete(MoneyTransaction txn) {
    return _write('transaction.delete', txn, () async {
      final removed = await (_db.delete(
        _db.transactions,
      )..where((t) => t.id.equals(txn.id))).go();
      return removed > 0;
    });
  }

  /// Puts back a transaction removed by [delete].
  @useResult
  Future<Result<MoneyTransaction, StoreFailure>> restore(MoneyTransaction txn) {
    return _write('transaction.restore', txn, () async {
      await _db
          .into(_db.transactions)
          .insert(transactionToRow(txn), mode: InsertMode.insertOrIgnore);
      return true;
    });
  }

  // Runs [action]; `false` means the record was not there.
  Future<Result<MoneyTransaction, StoreFailure>> _write(
    String event,
    MoneyTransaction txn,
    Future<bool> Function() action,
  ) async {
    try {
      final found = await action();
      return found ? Ok(txn) : Err(StoreRecordMissing(txn.id));
    } on SqliteException catch (e, st) {
      _log.error(event, e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  static String? _blankToNull(String? text) {
    final trimmed = text?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
