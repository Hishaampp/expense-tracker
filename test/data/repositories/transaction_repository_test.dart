import 'package:clock/clock.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/repositories/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late TransactionRepository repository;
  late RecordingLogger log;
  final now = DateTime(2026, 11, 10, 14, 30);

  setUp(() {
    db = openTestDatabase(clock: Clock.fixed(now));
    log = RecordingLogger();
    repository = TransactionRepository(
      db,
      Clock.fixed(now),
      SequentialIds(),
      log,
    );
  });
  tearDown(() => db.close());

  MoneyTransaction valueOf(Result<MoneyTransaction, StoreFailure> result) {
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => fail('unexpected ${failure.code}'),
    };
  }

  Future<MoneyTransaction> add(int paise, DateTime at, {String? category}) {
    return repository
        .addExpense(
          amount: Money(paise),
          accountId: Account.cashId,
          categoryId: category,
          occurredAt: at,
        )
        .then(valueOf);
  }

  Future<List<MoneyTransaction>> inMonth(DateTime date, {int startDay = 1}) {
    return repository
        .watchInPeriod(MonthPeriod.containing(date, startDay: startDay))
        .first;
  }

  test('a new expense is stored with Cash, now, and confirmed', () async {
    final result = await repository.addExpense(
      amount: const Money(24000),
      accountId: Account.cashId,
      categoryId: 'cat_food',
    );
    final saved = valueOf(result);
    expect(saved.occurredAt, now.toUtc());
    expect(await inMonth(now), [saved]);
  });

  test(
    'month boundaries: last instant in, first instant of next out',
    () async {
      final lastOfNov = await add(100, DateTime(2026, 11, 30, 23, 59, 59));
      final firstOfDec = await add(200, DateTime(2026, 12));
      expect(await inMonth(DateTime(2026, 11, 15)), [lastOfNov]);
      expect(await inMonth(DateTime(2026, 12, 15)), [firstOfDec]);
    },
  );

  test('custom start day moves the boundary', () async {
    final on24 = await add(100, DateTime(2026, 11, 24, 12));
    final on25 = await add(200, DateTime(2026, 11, 25, 0, 0, 1));
    expect(await inMonth(DateTime(2026, 11, 10), startDay: 25), [on24]);
    expect(await inMonth(DateTime(2026, 11, 26), startDay: 25), [on25]);
  });

  test('newest first', () async {
    final older = await add(100, DateTime(2026, 11, 2));
    final newer = await add(200, DateTime(2026, 11, 9));
    expect(await inMonth(now), [newer, older]);
  });

  test('edit changes the stored transaction', () async {
    final saved = await add(100, DateTime(2026, 11, 2), category: 'cat_food');
    final result = await repository.edit(
      saved,
      amount: const Money(555),
      occurredAt: DateTime(2026, 11, 3),
      accountId: Account.cashId,
      categoryId: 'cat_fuel',
      note: '  petrol ',
    );
    final edited = valueOf(result);
    expect(edited.amount, const Money(555));
    expect(edited.note, 'petrol');
    expect(await inMonth(now), [edited]);
  });

  test('delete removes it and restore puts it back', () async {
    final saved = await add(100, DateTime(2026, 11, 2));
    valueOf(await repository.delete(saved));
    expect(await inMonth(now), isEmpty);
    valueOf(await repository.restore(saved));
    expect(await inMonth(now), [saved]);
  });

  test('editing a deleted transaction reports it missing', () async {
    final saved = await add(100, DateTime(2026, 11, 2));
    valueOf(await repository.delete(saved));
    final result = await repository.edit(
      saved,
      amount: const Money(1),
      occurredAt: saved.occurredAt,
      accountId: Account.cashId,
      categoryId: null,
      note: null,
    );
    expect(result, isA<Err<MoneyTransaction, StoreFailure>>());
  });

  test('the database rejects a zero amount; the failure is typed', () async {
    final result = await repository.addExpense(
      amount: Money.zero,
      accountId: Account.cashId,
      categoryId: null,
    );
    expect(
      result,
      isA<Err<MoneyTransaction, StoreFailure>>().having(
        (e) => e.failure,
        'failure',
        isA<StoreWriteFailed>(),
      ),
    );
    expect(log.events, ['transaction.add']);
  });

  test('an unknown account is rejected by the foreign key', () async {
    final result = await repository.addExpense(
      amount: const Money(100),
      accountId: 'nope',
      categoryId: null,
    );
    expect(result, isA<Err<MoneyTransaction, StoreFailure>>());
  });
}
