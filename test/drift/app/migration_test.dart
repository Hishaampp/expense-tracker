import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

/// Every schema step, checked against the committed snapshots, plus a
/// content test: data written by version 1 is still there after upgrading.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  group('each upgrade produces the expected schema', () {
    const versions = GeneratedHelper.versions;
    for (final (i, from) in versions.indexed) {
      for (final to in versions.skip(i + 1)) {
        test('$from to $to', () async {
          final schema = await verifier.schemaAt(from);
          final db = AppDatabase(schema.newConnection());
          await verifier.migrateAndValidate(db, to);
          await db.close();
        });
      }
    }
  });

  test('1 to 2 keeps accounts, categories and transactions', () async {
    const account = v1.AccountsData(
      id: 'account_cash',
      name: 'Cash',
      type: 'cash',
      isArchived: 0,
      createdAt: 1,
    );
    const category = v1.CategoriesData(
      id: 'cat_food',
      name: 'Food & Dining',
      icon: 'food',
      kind: 'expense',
      isArchived: 0,
      sortOrder: 0,
    );
    const transaction = v1.TransactionsData(
      id: 'txn-1',
      kind: 'expense',
      amountPaise: 24000,
      currency: 'INR',
      occurredAt: 1762765800000,
      accountId: 'account_cash',
      categoryId: 'cat_food',
      instrument: 'cash',
      reviewStatus: 'confirmed',
      isHidden: 0,
      origin: 'manual',
      createdAt: 1762765800000,
      updatedAt: 1762765800000,
    );
    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insert(oldDb.accounts, account)
          ..insert(oldDb.categories, category)
          ..insert(oldDb.transactions, transaction);
      },
      validateItems: (newDb) async {
        final transactions = await newDb.select(newDb.transactions).get();
        expect(transactions.single.amountPaise, 24000);
        expect(transactions.single.categoryId, 'cat_food');
        final accounts = await newDb.select(newDb.accounts).get();
        expect(accounts.single.id, 'account_cash');
        expect(await newDb.select(newDb.rawCaptures).get(), isEmpty);
      },
    );
  });
}
