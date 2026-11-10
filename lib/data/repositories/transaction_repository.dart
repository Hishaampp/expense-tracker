import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/id_generator.dart';
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
  Stream<List<MoneyTransaction>> watchInPeriod(MonthPeriod period) {
    final query = _db.select(_db.transactions)
      ..where(
        (t) =>
            t.occurredAt.isBiggerOrEqualValue(period.startUtcMs) &
            t.occurredAt.isSmallerThanValue(period.endUtcMs),
      )
      ..orderBy([
        (t) => OrderingTerm.desc(t.occurredAt),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch().map(
      (rows) => rows.map(transactionFromRow).toList(growable: false),
    );
  }

  /// The transaction with [id], or null if it does not exist.
  Future<MoneyTransaction?> findById(String id) async {
    final query = _db.select(_db.transactions)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : transactionFromRow(row);
  }

  /// Saves a new manual expense and returns it.
  @useResult
  Future<Result<MoneyTransaction, StoreFailure>> addExpense({
    required Money amount,
    required String accountId,
    required String? categoryId,
    DateTime? occurredAt,
    String? note,
  }) {
    final now = _clock.now().toUtc();
    final txn = MoneyTransaction(
      id: _ids.newId(),
      kind: TransactionKind.expense,
      amount: amount,
      occurredAt: (occurredAt ?? now).toUtc(),
      accountId: accountId,
      categoryId: categoryId,
      instrument: Instrument.cash,
      note: _blankToNull(note),
      createdAt: now,
      updatedAt: now,
    );
    return _write('transaction.add', txn, () async {
      await _db.into(_db.transactions).insert(transactionToRow(txn));
      return true;
    });
  }

  /// Saves the user's edits to [txn]'s amount, time, account, category and
  /// note, and returns the stored transaction.
  @useResult
  Future<Result<MoneyTransaction, StoreFailure>> edit(
    MoneyTransaction txn, {
    required Money amount,
    required DateTime occurredAt,
    required String accountId,
    required String? categoryId,
    required String? note,
  }) {
    final updated = txn.edited(
      amount: amount,
      occurredAt: occurredAt.toUtc(),
      accountId: accountId,
      categoryId: categoryId,
      note: _blankToNull(note),
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
