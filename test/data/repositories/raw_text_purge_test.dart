import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:expense_tracker/core/models/retention.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/repositories/capture_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/seed.dart';
import '../../support/test_database.dart';

/// Spec §13: original message text is removed once its retention ends;
/// the payment itself stays.
void main() {
  final now = DateTime.utc(2026, 11, 10, 9);
  late AppDatabase db;
  late CaptureRepository captures;

  setUp(() async {
    db = openTestDatabase(clock: Clock.fixed(now));
    captures = CaptureRepository(db, SequentialIds(), RecordingLogger());
    await seedExpense(db, DateTime(2026, 11, 2), 100);
    final txn = (await db.select(db.transactions).get()).single.id;
    for (final (id, days) in [('old', 40), ('new', 5)]) {
      final at = now.subtract(Duration(days: days)).millisecondsSinceEpoch;
      await db.customInsert(
        'INSERT INTO raw_captures (id, content_hash, source, received_at, '
        "status) VALUES (?, ?, 'paste', ?, 'parsed')",
        variables: [Variable(id), Variable('h$id'), Variable(at)],
      );
      await db.customInsert(
        'INSERT INTO transaction_sources (id, transaction_id, raw_capture_id, '
        "source, received_at, raw_text) VALUES (?, ?, ?, 'paste', ?, ?)",
        variables: [
          Variable('s$id'),
          Variable(txn),
          Variable(id),
          Variable(at),
          Variable('Rs 100 debited, text $id'),
        ],
      );
    }
  });
  tearDown(() => db.close());

  Future<Map<String, String?>> texts() async => {
    for (final s in await db.select(db.transactionSources).get())
      s.rawCaptureId: s.rawText,
  };

  Future<int> purge(RawTextRetention r) async {
    final cutoff = r.cutoff(now);
    if (cutoff == null) return 0;
    return switch (await captures.purgeRawText(cutoff)) {
      Ok(:final value) => value,
      Err(:final failure) => fail(failure.code),
    };
  }

  test('30 days removes only older text', () async {
    expect(await purge(RawTextRetention.days30), 1);
    expect(await texts(), {'old': null, 'new': 'Rs 100 debited, text new'});
    expect(await db.select(db.transactions).get(), hasLength(1));
  });

  test('"Don\'t keep" removes all of it', () async {
    expect(await purge(RawTextRetention.never), 2);
    expect((await texts()).values, everyElement(isNull));
  });

  test('"Until I delete it" keeps everything', () async {
    expect(await purge(RawTextRetention.forever), 0);
    expect((await texts()).values, everyElement(isNotNull));
  });
}
