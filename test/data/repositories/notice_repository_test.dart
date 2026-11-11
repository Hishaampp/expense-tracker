import 'package:clock/clock.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/notice.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/repositories/notice_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late NoticeRepository repository;
  final now = DateTime.utc(2026, 11, 10, 9);

  setUp(() {
    final clock = Clock.fixed(now);
    db = openTestDatabase(clock: clock);
    repository = NoticeRepository(db, clock, RecordingLogger());
  });
  tearDown(() => db.close());

  Notice notice(String id, DateTime at) => Notice(
    id: id,
    kind: NoticeKind.budget,
    title: 'Title $id',
    body: 'Body',
    route: '/budgets',
    createdAt: at,
  );

  test('a notice is kept once, newest first, unread until seen', () async {
    expect(
      await repository.add(notice('a', now)),
      isA<Ok<bool, StoreFailure>>(),
    );
    final again = await repository.add(notice('a', now));
    expect(switch (again) {
      Ok(:final value) => value,
      Err() => null,
    }, false);
    final _ = await repository.add(
      notice('b', now.add(const Duration(hours: 1))),
    );

    expect(
      [for (final n in await repository.watchAll().first) n.id],
      ['b', 'a'],
    );
    expect(await repository.watchUnreadCount().first, 2);

    final read = await repository.markAllRead();
    expect(switch (read) {
      Ok(:final value) => value,
      Err() => null,
    }, 2);
    expect(await repository.watchUnreadCount().first, 0);
  });

  test('notices older than 60 days are purged', () async {
    final _ = await repository.add(
      notice('old', now.subtract(const Duration(days: 61))),
    );
    final _ = await repository.add(
      notice('recent', now.subtract(const Duration(days: 59))),
    );
    final purged = await repository.purgeOld();
    expect(switch (purged) {
      Ok(:final value) => value,
      Err() => null,
    }, 1);
    expect(
      [for (final n in await repository.watchAll().first) n.id],
      ['recent'],
    );
  });
}
