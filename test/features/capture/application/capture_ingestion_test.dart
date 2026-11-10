import 'package:clock/clock.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/capture_draft.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/repositories/capture_repository.dart';
import 'package:expense_tracker/data/repositories/transaction_repository.dart';
import 'package:expense_tracker/features/capture/application/capture_ingestion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:txn_parser/txn_parser.dart';

import '../../../support/test_database.dart';

const _hdfcDebit =
    'Rs.240.00 debited from A/c XX1234 on 10-11-26 to VPA swiggy@icici. '
    'UPI Ref No 631245678901. Not you? Call 18002586161';

void main() {
  late AppDatabase db;
  late CaptureIngestion ingestion;
  late TransactionRepository transactions;
  final now = DateTime.utc(2026, 11, 10, 9);
  var next = 0;

  RawCapture capture(String text, {DateTime? at, String? origin}) => RawCapture(
    id: 'cap-${++next}',
    source: CaptureSource.paste,
    text: text,
    origin: origin,
    receivedAt: at ?? now,
  );

  setUp(() {
    db = openTestDatabase(clock: Clock.fixed(now));
    final ids = SequentialIds();
    final log = RecordingLogger();
    ingestion = CaptureIngestion(
      const TxnParser(),
      CaptureRepository(db, ids, log),
    );
    transactions = TransactionRepository(db, Clock.fixed(now), ids, log);
  });
  tearDown(() => db.close());

  Future<IngestionOutcome> ingest(RawCapture c) async {
    return switch (await ingestion.ingest(c)) {
      Ok(:final value) => value,
      Err(:final failure) => fail('unexpected ${failure.code}'),
    };
  }

  Future<MoneyTransaction> save(CaptureDraft draft) async {
    final result = await transactions.addFromCapture(
      draft: draft,
      amount: draft.amount,
      kind: draft.kind,
      categoryId: 'cat_food',
    );
    return switch (result) {
      Ok(:final value) => value,
      Err<MoneyTransaction, StoreFailure>(:final failure) => fail(failure.code),
    };
  }

  test('a debit SMS becomes a draft and saves with its account', () async {
    final outcome = await ingest(capture(_hdfcDebit, origin: 'AX-HDFCBK'));
    final draft = (outcome as IngestedDraft).draft;
    expect(draft.kind, TransactionKind.expense);
    expect(draft.amount, const Money(24000));
    expect(draft.accountLabel, 'HDFC ••1234');
    expect(draft.payeeKey, 'swiggy@icici');

    final txn = await save(draft);
    expect(txn.refNo, '631245678901');
    expect(txn.origin, TransactionOrigin.auto);
    expect(txn.instrument, Instrument.upi);
    final accounts = await db.select(db.accounts).get();
    expect(accounts.map((a) => a.name), contains('HDFC ••1234'));
    final sources = await db.select(db.transactionSources).get();
    expect(sources.single.transactionId, txn.id);
    expect(sources.single.rawText, _hdfcDebit);
    final raw = await db.select(db.rawCaptures).get();
    expect(raw.single.status, 'parsed');
  });

  test('the same account is reused, not created twice', () async {
    final first = await ingest(capture(_hdfcDebit, origin: 'AX-HDFCBK'));
    await save((first as IngestedDraft).draft);
    final second = await ingest(
      capture(
        'Rs.99.00 debited from A/c XX1234 to VPA chai@ybl. '
        'UPI Ref No 631245678999.',
        origin: 'AX-HDFCBK',
      ),
    );
    await save((second as IngestedDraft).draft);
    final accounts = await (db.select(
      db.accounts,
    )..where((a) => a.last4.equals('1234'))).get();
    expect(accounts, hasLength(1));
  });

  test('a message whose reference is already saved is a duplicate', () async {
    final first = await ingest(capture(_hdfcDebit));
    await save((first as IngestedDraft).draft);
    final again = await ingest(
      capture(_hdfcDebit, at: now.add(const Duration(hours: 1))),
    );
    expect(again, isA<IngestedDuplicate>());
  });

  test('an OTP is dropped and recorded with its reason only', () async {
    final outcome = await ingest(
      capture('OTP is 482913 for txn of INR 2,499.00 at AMAZON.'),
    );
    expect((outcome as IngestedDropped).messageClass, MessageClass.otp);
    final raw = await db.select(db.rawCaptures).getSingle();
    expect(raw.status, 'dropped');
    expect(raw.dropReason, 'otp');
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  test('the same capture twice is a duplicate', () async {
    final otp = capture('OTP is 482913 for txn of INR 2,499.00 at AMAZON.');
    await ingest(otp);
    expect(await ingest(otp), isA<IngestedDuplicate>());
  });

  test(
    'an unreadable message with an amount goes to Unparsed, masked',
    () async {
      final outcome = await ingest(
        capture('Txn alert: Rs 75 at KIRANA corner, a/c 99887766.'),
      );
      expect((outcome as IngestedUnparsed).amount, const Money(7500));
      final row = await db.select(db.unparsedMessages).getSingle();
      expect(row.maskedText, contains('Rs 75'));
      expect(row.maskedText, isNot(contains('99887766')));
    },
  );

  test('text with no amount records nothing', () async {
    expect(
      await ingest(capture('Your cheque book has been dispatched.')),
      isA<IngestedNoAmount>(),
    );
    expect(await db.select(db.rawCaptures).get(), isEmpty);
  });

  test('a credit becomes money in; a refund stays a refund', () async {
    final credit = await ingest(
      capture('Received ₹1,000 from Anita Sharma', origin: 'com.phonepe.app'),
    );
    expect((credit as IngestedDraft).draft.kind, TransactionKind.income);
    final refund = await ingest(
      capture('Refund of Rs 499.00 credited to your Card x4321 from FLIPKART'),
    );
    expect((refund as IngestedDraft).draft.kind, TransactionKind.refund);
  });

  test('a date without a time on another day reads as midday', () async {
    final outcome = await ingest(
      capture('Rs 50 debited from A/c XX1234 on 05-11-26 to VPA x@ybl.'),
    );
    final draft = (outcome as IngestedDraft).draft;
    expect(draft.occurredAt, DateTime(2026, 11, 5, 12));
  });
}
