import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract (spec §13): the database file on the phone is encrypted, a
/// database from before encryption is encrypted in place without losing
/// anything, and a wrong key opens nothing.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final key = 'ab' * 32;
  late Directory dir;
  late String path;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('expenses_db');
    path = '${dir.path}/expenses.sqlite';
  });
  tearDown(() => dir.deleteSync(recursive: true));

  AppDatabase open({required String hexKey, required bool wasPlain}) =>
      AppDatabase(
        NativeDatabase(
          File(path),
          setup: (raw) =>
              AppDatabase.unlock(raw, hexKey: hexKey, wasPlain: wasPlain),
        ),
      );

  Future<int> categories(AppDatabase db) async =>
      (await db.select(db.categories).get()).length;

  test('a new database is written encrypted', () async {
    final db = open(hexKey: key, wasPlain: false);
    expect(await categories(db), greaterThan(0));
    await db.close();

    expect(await AppDatabase.isPlain(path), isFalse);
    final bytes = File(path).readAsBytesSync();
    expect(String.fromCharCodes(bytes.take(15)), isNot('SQLite format 3'));
    // No category name shows in the file.
    expect(String.fromCharCodes(bytes).contains('Groceries'), isFalse);
  });

  test('a database from before encryption keeps its data', () async {
    final plain = AppDatabase(NativeDatabase(File(path)));
    final seeded = await categories(plain);
    await plain.customStatement(
      "INSERT INTO settings (key, value) VALUES ('kept', 'yes')",
    );
    await plain.close();
    expect(await AppDatabase.isPlain(path), isTrue);

    final db = open(hexKey: key, wasPlain: true);
    expect(await categories(db), seeded);
    final kept = await db.select(db.settings).get();
    expect(kept.map((s) => s.key), contains('kept'));
    await db.close();
    expect(await AppDatabase.isPlain(path), isFalse);

    final again = open(hexKey: key, wasPlain: false);
    expect(await categories(again), seeded);
    await again.close();
  });

  test('a wrong key opens nothing', () async {
    final db = open(hexKey: key, wasPlain: false);
    await categories(db);
    await db.close();

    final wrong = open(hexKey: 'cd' * 32, wasPlain: false);
    await expectLater(categories(wrong), throwsA(anything));
    await wrong.close().catchError((_) {});
  });
}
