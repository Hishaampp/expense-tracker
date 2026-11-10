import 'package:drift/drift.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/mappers.dart';

/// Reads accounts.
class AccountRepository {
  /// Creates the repository over [_db].
  new(this._db);

  final AppDatabase _db;

  /// Every account, oldest first (Cash is always first).
  Stream<List<Account>> watchAll() {
    final query = _db.select(_db.accounts)
      ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]);
    return query.watch().map(
      (rows) => rows.map(accountFromRow).toList(growable: false),
    );
  }
}
