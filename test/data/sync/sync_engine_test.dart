import 'dart:math';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/sync/sync_crypto.dart';
import 'package:expense_tracker/data/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/seed.dart';
import '../../support/test_database.dart';

/// Phase 9: two phones with one sync key stay the same through a server
/// that only ever holds ciphertext.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final key = SyncKey.generate(Random(9));
  late MemorySyncServer server;
  late AppDatabase phoneA;
  late AppDatabase phoneB;
  late SyncEngine a;
  late SyncEngine b;

  setUp(() async {
    server = MemorySyncServer();
    phoneA = openTestDatabase();
    phoneB = openTestDatabase();
    a = SyncEngine(phoneA, SyncCrypto(key), server);
    b = SyncEngine(phoneB, SyncCrypto(key), server);
  });
  tearDown(() async {
    await phoneA.close();
    await phoneB.close();
  });

  Future<List<String>> payees(AppDatabase db) async => [
    for (final t in await (db.select(
      db.transactions,
    )..orderBy([(t) => OrderingTerm.asc(t.amountPaise)])).get())
      t.payeeDisplay ?? '',
  ];

  // Trigger times are milliseconds; keep edits apart.
  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 5));

  test('nothing is queued until sync is turned on', () async {
    await seedExpense(phoneA, DateTime(2026, 11, 3), 300, payee: 'Swiggy');
    expect(await phoneA.select(phoneA.syncOutbox).get(), isEmpty);
    await a.enable();
    final queued = await phoneA.select(phoneA.syncOutbox).get();
    expect(queued.map((q) => q.recordTable), contains('transactions'));
  });

  test('a payment made on one phone appears on the other', () async {
    await a.enable();
    await b.enable();
    await seedExpense(phoneA, DateTime(2026, 11, 3), 300, payee: 'Swiggy');
    await a.sync();
    await b.sync();
    expect(await payees(phoneB), ['Swiggy']);
  });

  test('a new phone gets everything, rooms and budgets included', () async {
    await seedRoom(phoneA, id: 'goa', name: 'Goa trip', type: 'trip');
    await seedExpense(
      phoneA,
      DateTime(2026, 11, 4),
      1500,
      payee: 'Hotel',
      roomId: 'goa',
    );
    await phoneA.customStatement(
      "INSERT INTO budgets (id, amount_paise) VALUES ('month', 3000000)",
    );
    await a.enable();
    await a.sync();

    await b.enable();
    await b.sync();
    final txn = (await phoneB.select(phoneB.transactions).get()).single;
    expect(txn.roomId, 'goa');
    expect(
      (await phoneB.select(phoneB.budgets).get()).single.amountPaise,
      3000000,
    );
    // Pulled changes are not sent back.
    expect(await phoneB.select(phoneB.syncOutbox).get(), isEmpty);
  });

  test('edits and deletes travel both ways', () async {
    await a.enable();
    await b.enable();
    await seedExpense(phoneA, DateTime(2026, 11, 3), 300, payee: 'Swiggy');
    await a.sync();
    await b.sync();

    await tick();
    await phoneB.customStatement(
      "UPDATE transactions SET payee_display = 'Swiggy Instamart'",
    );
    await b.sync();
    await a.sync();
    expect(await payees(phoneA), ['Swiggy Instamart']);

    await tick();
    await phoneA.customStatement('DELETE FROM transactions');
    await a.sync();
    await b.sync();
    expect(await payees(phoneB), isEmpty);
  });

  test('when both phones edit, the later edit wins on both', () async {
    await a.enable();
    await b.enable();
    await seedExpense(phoneA, DateTime(2026, 11, 3), 300, payee: 'Swiggy');
    await a.sync();
    await b.sync();

    await tick();
    await phoneA.customStatement(
      "UPDATE transactions SET payee_display = 'From A'",
    );
    await tick();
    await phoneB.customStatement(
      "UPDATE transactions SET payee_display = 'From B'",
    );
    await a.sync();
    await b.sync();
    await a.sync();
    expect(await payees(phoneA), ['From B']);
    expect(await payees(phoneB), ['From B']);
  });

  test('message text and phone-only settings never leave the phone', () async {
    await phoneA.customStatement(
      "INSERT INTO settings (key, value) VALUES ('app_lock', 'on'), "
      "('month_start_day', '25')",
    );
    await a.enable();
    await a.sync();
    await b.enable();
    await b.sync();
    final settings = {
      for (final s in await phoneB.select(phoneB.settings).get())
        s.key: s.value,
    };
    expect(settings['month_start_day'], '25');
    expect(settings.containsKey('app_lock'), isFalse);
  });

  test('the server holds only ciphertext and opaque ids', () async {
    await seedExpense(phoneA, DateTime(2026, 11, 3), 24050, payee: 'Swiggy');
    await a.enable();
    await a.sync();
    expect(server.stored, isNotEmpty);
    for (final record in server.stored) {
      for (final secret in ['Swiggy', '2405000', 'transactions', 'cat_food']) {
        expect(record.blob.contains(secret), isFalse, reason: secret);
        expect(record.id.contains(secret), isFalse, reason: secret);
      }
    }
  });

  test('a phone with another key ignores what it cannot open', () async {
    await seedExpense(phoneA, DateTime(2026, 11, 3), 300, payee: 'Swiggy');
    await a.enable();
    await a.sync();
    final stranger = SyncEngine(
      phoneB,
      SyncCrypto(SyncKey.generate(Random(10))),
      server,
    );
    await stranger.enable();
    final report = await stranger.sync();
    expect(report.applied, 0);
    expect(await payees(phoneB), isEmpty);
  });
}
