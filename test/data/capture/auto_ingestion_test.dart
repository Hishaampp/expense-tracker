import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/payee_rule.dart';
import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/capture/auto_ingestion.dart';
import 'package:expense_tracker/data/capture/capture_ingestion.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/mappers.dart';
import 'package:expense_tracker/data/repositories/auto_capture_repository.dart';
import 'package:expense_tracker/data/repositories/capture_repository.dart';
import 'package:expense_tracker/data/repositories/payee_repository.dart';
import 'package:expense_tracker/data/repositories/room_repository.dart';
import 'package:expense_tracker/data/repositories/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:txn_parser/txn_parser.dart';

import '../../support/test_database.dart';

const _messages = 'com.google.android.apps.messaging';
const _gpay = 'com.google.android.apps.nbu.paisa.user';
const _phonepe = 'com.phonepe.app';

void main() {
  late AppDatabase db;
  late AutoIngestion auto;
  late RoomRepository rooms;
  late PayeeRepository payees;
  final t0 = DateTime.utc(2026, 11, 10, 9);
  var next = 0;

  RawCapture n(String text, String origin, {Duration after = Duration.zero}) =>
      RawCapture(
        id: 'cap-${++next}',
        source: CaptureSource.androidNotification,
        origin: origin,
        text: text,
        receivedAt: t0.add(after),
      );

  setUp(() {
    db = openTestDatabase(clock: Clock.fixed(t0));
    final ids = SequentialIds();
    final log = RecordingLogger();
    final transactions = TransactionRepository(db, Clock.fixed(t0), ids, log);
    rooms = RoomRepository(db, Clock.fixed(t0), ids, log);
    payees = PayeeRepository(db, Clock.fixed(t0), log);
    auto = AutoIngestion(
      CaptureIngestion(const TxnParser(), CaptureRepository(db, ids, log)),
      AutoCaptureRepository(db, transactions, Clock.fixed(t0), ids, log),
      transactions,
      rooms,
      payees,
    );
  });
  tearDown(() => db.close());

  Future<AutoOutcome> ingest(RawCapture c) async =>
      switch (await auto.ingest(c)) {
        Ok(:final value) => value,
        Err(:final failure) => fail(failure.code),
      };

  Future<List<TransactionRow>> all() => db.select(db.transactions).get();

  test('a bank SMS saves at once and waits for review', () async {
    expect(
      await ingest(
        n(
          'Rs.340.00 debited from A/c XX1234 to VPA swiggy@icici. '
          'UPI Ref No 631245678901.',
          _messages,
        ),
      ),
      AutoOutcome.saved,
    );
    final txn = transactionFromRow((await all()).single);
    expect(txn.reviewStatus, ReviewStatus.needsReview);
    expect(txn.categoryId, 'cat_food', reason: 'Swiggy suggests Food');
    expect(txn.amount.paise, 34000);
  });

  test(
    'the same payment from the bank SMS and Google Pay is saved once',
    () async {
      await ingest(
        n(
          'Rs.340.00 debited from A/c XX1234 to VPA swiggy@icici. '
          'UPI Ref No 631245678901.',
          _messages,
        ),
      );
      expect(
        await ingest(
          n('Paid ₹340 to Swiggy', _gpay, after: const Duration(seconds: 20)),
        ),
        AutoOutcome.merged,
      );
      expect(await all(), hasLength(1));
      final sources = await db.select(db.transactionSources).get();
      expect(sources, hasLength(2));
    },
  );

  test('two equal payments in one app stay two', () async {
    await ingest(n('Paid ₹15 to Chai Point', _phonepe));
    await ingest(
      n('Paid ₹15 to Chai Point', _phonepe, after: const Duration(minutes: 3)),
    );
    expect(await all(), hasLength(2));
  });

  test('an ATM withdrawal is a transfer to Cash, not spending', () async {
    await ingest(
      n(
        'Rs 2000.00 withdrawn at ATM KOTAK MG ROAD from Kotak Bank a/c '
        'XX3344 on 06-11-2026.',
        _messages,
      ),
    );
    final txn = transactionFromRow((await all()).single);
    expect(txn.kind, TransactionKind.transfer);
    expect(txn.toAccountId, Account.cashId);
    expect(txn.reviewStatus, ReviewStatus.confirmed);
  });

  test('a credit card bill payment is a transfer', () async {
    await ingest(
      n(
        'Rs 12,430.00 debited from A/c XX1234 towards your credit card '
        'bill. Ref 631255554444.',
        _messages,
      ),
    );
    expect(
      transactionFromRow((await all()).single).kind,
      TransactionKind.transfer,
    );
  });

  test('a refund links to its expense and inherits the category', () async {
    await ingest(n('Paid ₹499 to Flipkart', _phonepe));
    final expense = (await all()).single;
    await (db.update(db.transactions)..where((t) => t.id.equals(expense.id)))
        .write(const TransactionsCompanion(categoryId: Value('cat_shopping')));
    await ingest(
      n(
        'Refund of ₹499 from Flipkart credited to your account',
        _messages,
        after: const Duration(days: 2),
      ),
    );
    final refund = (await all()).firstWhere(
      (t) => t.kind == TransactionKind.refund,
    );
    expect(refund.linkedTransactionId, expense.id);
    expect(refund.categoryId, 'cat_shopping');
  });

  test('the reversal of a failed payment is hidden', () async {
    await ingest(
      n(
        'Rs 150.00 reversed to your A/c X5678 for failed UPI txn Ref '
        '631299991111.',
        _messages,
      ),
    );
    expect((await all()).single.isHidden, isTrue);
  });

  test('an OTP is recorded and saves nothing', () async {
    expect(
      await ingest(n('OTP is 482913 for txn of INR 2,499.00.', _messages)),
      AutoOutcome.recorded,
    );
    expect(await all(), isEmpty);
  });

  group('Rooms', () {
    const swiggy =
        'Rs.340.00 debited from A/c XX1234 to VPA swiggy@icici. '
        'UPI Ref No 631245678901.';

    Future<Room> trip(String name, {int from = -1, int? to}) async {
      final day = LocalDay.of(t0);
      final made = await rooms.create(
        name: name,
        type: RoomType.trip,
        autoTagMode: AutoTagMode.dateWindow,
        startDay: day.plus(from),
        endDay: to == null ? null : day.plus(to),
      );
      return switch (made) {
        Ok(:final value) => value,
        Err(:final failure) => fail(failure.code),
      };
    }

    test('an expense during a trip joins the trip', () async {
      final goa = await trip('Goa', to: 1);
      await ingest(n(swiggy, _messages));
      expect((await all()).single.roomId, goa.id);
    });

    test('overlapping trips leave the choice to review', () async {
      await trip('Goa');
      await trip('Work trip');
      await ingest(n(swiggy, _messages));
      expect((await all()).single.roomId, isNull);
    });

    test('a wedding only suggests; it never takes the expense', () async {
      final made = await rooms.create(
        name: 'Wedding',
        type: RoomType.wedding,
        autoTagMode: AutoTagMode.suggest,
      );
      expect(made, isA<Ok<Room, StoreFailure>>());
      await ingest(n(swiggy, _messages));
      expect((await all()).single.roomId, isNull);
    });

    test('a trip that ended yesterday does not claim today', () async {
      await trip('Goa', from: -3, to: -1);
      await ingest(n(swiggy, _messages));
      expect((await all()).single.roomId, isNull);
    });
  });

  group('payee rules', () {
    Future<String> firstKey(String text, {String origin = _phonepe}) async {
      await ingest(n(text, origin));
      return (await all()).single.payeeKey!;
    }

    test('a learned category confirms the next payment by itself', () async {
      final key = await firstKey('Paid ₹62 to Sharma Dairy');
      final saved = await payees.save(
        PayeeRule(payeeKey: key, categoryId: 'cat_groceries'),
      );
      expect(saved, isA<Ok<PayeeRule, StoreFailure>>());

      await ingest(
        n(
          'Paid ₹70 to Sharma Dairy',
          _phonepe,
          after: const Duration(hours: 3),
        ),
      );
      final second = (await all()).firstWhere((t) => t.amountPaise == 7000);
      expect(second.categoryId, 'cat_groceries');
      expect(second.reviewStatus, ReviewStatus.confirmed);
    });

    test('a payee Room takes the payment while the Room is active', () async {
      final key = await firstKey('Paid ₹2500 to Tanishq');
      final made = await rooms.create(
        name: 'Wedding',
        type: RoomType.wedding,
        autoTagMode: AutoTagMode.manual,
      );
      final wedding = switch (made) {
        Ok(:final value) => value,
        Err(:final failure) => fail(failure.code),
      };
      final _ = await payees.save(PayeeRule(payeeKey: key, roomId: wedding.id));

      await ingest(
        n('Paid ₹900 to Tanishq', _phonepe, after: const Duration(hours: 3)),
      );
      final second = (await all()).firstWhere((t) => t.amountPaise == 90000);
      expect(second.roomId, wedding.id);
      // A Room alone teaches no category: it still waits for review.
      expect(second.reviewStatus, ReviewStatus.needsReview);
    });

    test('a name given to a payee shows on old and new payments', () async {
      final key = await firstKey(
        'Rs.62.00 debited from A/c XX1234 to VPA 9876543210@ybl. '
        'UPI Ref No 631245678902.',
        origin: _messages,
      );
      final _ = await payees.save(
        PayeeRule(payeeKey: key, displayName: 'Milk man'),
      );
      expect((await all()).single.payeeDisplay, 'Milk man');

      await ingest(
        n(
          'Rs.40.00 debited from A/c XX1234 to VPA 9876543210@ybl. '
          'UPI Ref No 631245678903.',
          _messages,
          after: const Duration(hours: 3),
        ),
      );
      expect({for (final t in await all()) t.payeeDisplay}, {'Milk man'});
    });

    test('the merchant book counts payments per payee', () async {
      await ingest(n('Paid ₹62 to Sharma Dairy', _phonepe));
      await ingest(
        n(
          'Paid ₹70 to Sharma Dairy',
          _phonepe,
          after: const Duration(hours: 3),
        ),
      );
      await ingest(
        n('Paid ₹10 to Chai Point', _phonepe, after: const Duration(hours: 4)),
      );
      final book = await payees.watchBook().first;
      expect(
        [for (final e in book) (e.name, e.count)],
        [('Sharma Dairy', 2), ('Chai Point', 1)],
      );
    });
  });
}
