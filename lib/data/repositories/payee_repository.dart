import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/payee_rule.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/common.dart';

/// Payee rules and the merchant book (spec §8).
class PayeeRepository {
  /// Creates the repository over [_db].
  new(this._db, this._clock, this._log);

  final AppDatabase _db;
  final Clock _clock;
  final AppLogger _log;

  /// The rule for [payeeKey], or null.
  Future<PayeeRule?> ruleFor(String payeeKey) async {
    final query = _db.select(_db.payeeRules)
      ..where((r) => r.payeeKey.equals(payeeKey));
    final row = await query.getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  /// Every payee seen in a transaction, most used first, each with its
  /// rule. Live: re-emits when a transaction or a rule changes.
  Stream<List<PayeeEntry>> watchBook() {
    final query = _db.customSelect(
      'SELECT t.payee_key AS k, COUNT(*) AS n, MAX(t.payee_display) AS d, '
      'r.payee_key AS rk, r.category_id AS c, r.room_id AS rm, '
      'r.display_name AS dn '
      'FROM transactions t '
      'LEFT JOIN payee_rules r ON r.payee_key = t.payee_key '
      'WHERE t.payee_key IS NOT NULL AND t.is_hidden = 0 '
      'GROUP BY t.payee_key ORDER BY n DESC, k',
      readsFrom: {_db.transactions, _db.payeeRules},
    );
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (
            payeeKey: row.read<String>('k'),
            name:
                row.readNullable<String>('dn') ??
                row.readNullable<String>('d') ??
                row.read<String>('k'),
            count: row.read<int>('n'),
            rule: row.readNullable<String>('rk') == null
                ? null
                : PayeeRule(
                    payeeKey: row.read<String>('k'),
                    categoryId: row.readNullable<String>('c'),
                    roomId: row.readNullable<String>('rm'),
                    displayName: row.readNullable<String>('dn'),
                  ),
          ),
      ],
    );
  }

  /// Saves [rule]; an empty rule is forgotten. A display name is also
  /// written onto the payee's transactions, so lists show it everywhere.
  @useResult
  Future<Result<PayeeRule, StoreFailure>> save(PayeeRule rule) async {
    try {
      await _db.transaction(() async {
        final before = await ruleFor(rule.payeeKey);
        if (rule.isEmpty) {
          await (_db.delete(
            _db.payeeRules,
          )..where((r) => r.payeeKey.equals(rule.payeeKey))).go();
        } else {
          await _db
              .into(_db.payeeRules)
              .insertOnConflictUpdate(
                PayeeRulesCompanion.insert(
                  payeeKey: rule.payeeKey,
                  categoryId: Value(rule.categoryId),
                  roomId: Value(rule.roomId),
                  displayName: Value(rule.displayName),
                  updatedAt: _clock.now().toUtc().millisecondsSinceEpoch,
                ),
              );
        }
        final name = rule.displayName;
        if (name != null && name != before?.displayName) {
          await (_db.update(_db.transactions)
                ..where((t) => t.payeeKey.equals(rule.payeeKey)))
              .write(TransactionsCompanion(payeeDisplay: Value(name)));
        }
      });
      return Ok(rule);
    } on SqliteException catch (e, st) {
      _log.error('payee.save', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Payments from [payeeKey] still waiting in review, other than
  /// [exceptId].
  Future<List<String>> waitingFrom(String payeeKey, {String? exceptId}) async {
    final query = _db.select(_db.transactions)
      ..where(
        (t) =>
            t.payeeKey.equals(payeeKey) &
            t.reviewStatus.equals(ReviewStatus.needsReview.name) &
            t.isHidden.equals(false),
      );
    return [
      for (final row in await query.get())
        if (row.id != exceptId) row.id,
    ];
  }

  static PayeeRule _fromRow(PayeeRuleRow row) => PayeeRule(
    payeeKey: row.payeeKey,
    categoryId: row.categoryId,
    roomId: row.roomId,
    displayName: row.displayName,
  );
}
