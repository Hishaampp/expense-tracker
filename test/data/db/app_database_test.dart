import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/repositories/account_repository.dart';
import 'package:expense_tracker/data/repositories/category_repository.dart';
import 'package:expense_tracker/data/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = openTestDatabase());
  tearDown(() => db.close());

  test('a new database has the Cash account', () async {
    final accounts = await AccountRepository(db).watchAll().first;
    expect(accounts.single.id, Account.cashId);
    expect(accounts.single.type, AccountType.cash);
  });

  test('a new database has 18 expense and 4 system categories', () async {
    final categories = await CategoryRepository(db).watchAll().first;
    expect(
      categories.where((c) => c.kind == CategoryKind.expense),
      hasLength(18),
    );
    expect(
      categories.where((c) => c.kind == CategoryKind.system),
      hasLength(4),
    );
    expect(categories.first.name, 'Food & Dining');
  });

  test('month start day defaults to 1 and is saved clamped', () async {
    final settings = SettingsRepository(db, RecordingLogger());
    expect(await settings.watchMonthStartDay().first, 1);
    expect(await settings.setMonthStartDay(25), isA<Ok<int, StoreFailure>>());
    expect(await settings.watchMonthStartDay().first, 25);
    expect(await settings.setMonthStartDay(31), isA<Ok<int, StoreFailure>>());
    expect(await settings.watchMonthStartDay().first, 28);
  });
}
