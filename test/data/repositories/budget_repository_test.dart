import 'package:clock/clock.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/budget_plan.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/repositories/budget_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/common.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late BudgetRepository repository;

  setUp(() {
    final clock = Clock.fixed(DateTime(2026, 11, 10, 14, 30));
    db = openTestDatabase(clock: clock);
    repository = BudgetRepository(db, clock, RecordingLogger());
  });
  tearDown(() => db.close());

  test('no budgets on a new install', () async {
    expect(await repository.watchPlan().first, BudgetPlan.none);
  });

  test('monthly and category budgets are saved, changed and removed', () async {
    expect(
      await repository.setMonthly(const Money(3000000)),
      isA<Ok<Money?, StoreFailure>>(),
    );
    expect(
      await repository.setCategory('cat_food', const Money(600000)),
      isA<Ok<Money?, StoreFailure>>(),
    );
    expect(
      await repository.watchPlan().first,
      const BudgetPlan(
        monthly: Money(3000000),
        byCategory: {'cat_food': Money(600000)},
      ),
    );

    expect(
      await repository.setMonthly(const Money(2500000)),
      isA<Ok<Money?, StoreFailure>>(),
    );
    expect(
      await repository.setCategory('cat_food', null),
      isA<Ok<Money?, StoreFailure>>(),
    );
    expect(
      await repository.watchPlan().first,
      const BudgetPlan(monthly: Money(2500000)),
    );
  });

  test('the schema refuses a zero budget or a mismatched id', () async {
    expect(
      () => db.customStatement(
        "INSERT INTO budgets (id, amount_paise) VALUES ('month', 0)",
      ),
      throwsA(isA<SqliteException>()),
    );
    expect(
      () => db.customStatement(
        'INSERT INTO budgets (id, category_id, amount_paise) '
        "VALUES ('category:cat_fuel', 'cat_food', 100)",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('a category budget goes when its category is deleted', () async {
    expect(
      await repository.setCategory('cat_food', const Money(100)),
      isA<Ok<Money?, StoreFailure>>(),
    );
    await db.customStatement('UPDATE transactions SET category_id = NULL');
    await db.customStatement("DELETE FROM categories WHERE id = 'cat_food'");
    expect((await repository.watchPlan().first).byCategory, isEmpty);
  });

  test('each alert key fires once', () async {
    Future<Set<String>> fire(Set<String> keys) async =>
        switch (await repository.markFired(keys)) {
          Ok(:final value) => value,
          Err(:final failure) => fail('unexpected ${failure.code}'),
        };

    expect(await fire({'month:1:80'}), {'month:1:80'});
    expect(await fire({'month:1:80', 'month:1:100'}), {'month:1:100'});
    expect(await fire({'month:1:80', 'month:1:100'}), isEmpty);
  });
}
