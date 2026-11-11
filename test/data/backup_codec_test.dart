import 'dart:convert';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/backup/backup_codec.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/seed.dart';
import '../support/test_database.dart';

/// Phase 8 acceptance (spec §16): restoring a backup on a fresh install
/// reproduces all data.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final clock = Clock.fixed(DateTime(2026, 11, 10, 14, 30));
  late AppDatabase phone;
  late AppDatabase fresh;

  setUp(() {
    phone = openTestDatabase(clock: clock);
    fresh = openTestDatabase(clock: clock);
  });
  tearDown(() async {
    await phone.close();
    await fresh.close();
  });

  BackupCodec codec(AppDatabase db) =>
      BackupCodec(db, iterations: 1000, random: Random(7));

  Future<Map<String, List<Map<String, Object?>>>> everything(
    AppDatabase db,
  ) async => {
    for (final table in BackupCodec.tables)
      table: [
        for (final row
            in await db
                .customSelect('SELECT * FROM $table ORDER BY rowid')
                .get())
          row.data,
      ],
  };

  Future<void> fill(AppDatabase db) async {
    await seedRoom(db, id: 'goa', name: 'Goa trip', type: 'trip');
    await seedExpense(db, DateTime(2026, 11, 3, 13), 300, payee: 'Swiggy');
    await seedExpense(
      db,
      DateTime(2026, 11, 4, 9),
      1500,
      payee: 'Hotel',
      roomId: 'goa',
    );
    await db.customStatement(
      "INSERT INTO budgets (id, amount_paise) VALUES ('month', 3000000)",
    );
    await db.customStatement(
      'INSERT INTO payee_rules (payee_key, category_id, display_name, '
      "updated_at) VALUES ('swiggy', 'cat_food', 'Swiggy', 1)",
    );
    await db.customStatement(
      "INSERT INTO settings (key, value) VALUES ('appearance', 'dark')",
    );
  }

  test('a fresh install restored from a backup holds the same data', () async {
    await fill(phone);
    final file = switch (await codec(phone).export('correct horse')) {
      Ok(:final value) => value,
      Err(:final failure) => fail(failure.code),
    };
    final report = switch (await codec(fresh).restore(file, 'correct horse')) {
      Ok(:final value) => value,
      Err(:final failure) => fail(failure.code),
    };

    expect(report.transactions, 2);
    expect(report.rooms, 1);
    expect(await everything(fresh), await everything(phone));
  });

  test('the file reveals nothing without the password', () async {
    await fill(phone);
    final file = switch (await codec(phone).export('correct horse')) {
      Ok(:final value) => value,
      Err(:final failure) => fail(failure.code),
    };
    final text = utf8.decode(file);
    for (final secret in ['Swiggy', 'Goa', 'Hotel', '150000']) {
      expect(text.contains(secret), isFalse, reason: secret);
    }
  });

  test('a wrong password changes nothing', () async {
    await fill(phone);
    await fill(fresh);
    final before = await everything(fresh);
    final file = switch (await codec(phone).export('correct horse')) {
      Ok(:final value) => value,
      Err(:final failure) => fail(failure.code),
    };
    final result = await codec(fresh).restore(file, 'wrong horse');
    expect(result, isA<Err<RestoreReport, BackupFailure>>());
    expect((result as Err).failure, isA<BackupWrongPassword>());
    expect(await everything(fresh), before);
  });

  test('a file that is not a backup is refused', () async {
    final result = await codec(fresh)
        .restore(Uint8List.fromList(utf8.encode('Date,Amount\n')), 'x');
    expect((result as Err).failure, isA<BackupNotABackup>());
  });

  test('a backup from a newer app is refused', () async {
    final newer = BackupCodec(phone, iterations: 1000, schemaVersion: 99);
    final bumped = switch (await newer.export('pw123456')) {
      Ok(:final value) => value,
      Err(:final failure) => fail(failure.code),
    };
    final result = await codec(fresh).restore(bumped, 'pw123456');
    expect((result as Err).failure, isA<BackupTooNew>());
  });
}
