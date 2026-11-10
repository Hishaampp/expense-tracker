import 'package:drift/drift.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/mappers.dart';

/// Reads categories.
class CategoryRepository {
  /// Creates the repository over [_db].
  new(this._db);

  final AppDatabase _db;

  /// Every category, in picker order.
  Stream<List<Category>> watchAll() {
    final query = _db.select(_db.categories)
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);
    return query.watch().map(
      (rows) => rows.map(categoryFromRow).toList(growable: false),
    );
  }
}
