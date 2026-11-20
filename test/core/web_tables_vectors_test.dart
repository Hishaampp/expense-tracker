// The app's Activity search and filters, and Room totals, written out for
// the website's pages to match (web/src/lib/insights/tables.test.ts).
// Transactions are given as local calendar dates, so the cases hold in
// every time zone. Regenerate after a deliberate change with
//   UPDATE_WEB_VECTORS=1 flutter test test/core/web_tables_vectors_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/room_summary.dart';
import 'package:expense_tracker/core/transaction_filter.dart';
import 'package:test/test.dart';

const _path = 'web/src/lib/insights/fixtures/tables-vectors.json';

void main() {
  test('the website search, filter and Room cases are current', () {
    final random = Random(23);
    const categories = [
      Category(
        id: 'food',
        name: 'Food & drinks',
        iconKey: 'food',
        kind: CategoryKind.expense,
        sortOrder: 0,
      ),
      Category(
        id: 'fuel',
        name: 'Fuel',
        iconKey: 'fuel',
        kind: CategoryKind.expense,
        sortOrder: 1,
      ),
      Category(
        id: 'salary',
        name: 'Salary',
        iconKey: 'salary',
        kind: CategoryKind.income,
        sortOrder: 2,
      ),
    ];
    const accounts = [
      Account(id: 'hdfc', name: 'HDFC Savings', type: AccountType.bank),
      Account(id: 'cash', name: 'Cash', type: AccountType.cash),
    ];
    const payees = [
      ('swiggy', 'Swiggy'),
      ('zomato', 'Zomato Ltd'),
      ('rahul@okhdfc', null),
      (null, null),
      ('hp-petrol', 'HP Petrol Pump'),
    ];
    const notes = [null, null, 'Dinner with Asha', 'office lunch', 'tank full'];
    const kinds = [
      TransactionKind.expense,
      TransactionKind.expense,
      TransactionKind.expense,
      TransactionKind.expense,
      TransactionKind.expense,
      TransactionKind.refund,
      TransactionKind.income,
      TransactionKind.transfer,
    ];
    const rooms = [null, null, 'goa', 'wedding'];
    final rows = <Map<String, Object?>>[];
    final items = <TransactionItem>[];
    for (var i = 0; i < 160; i++) {
      final kind = kinds[random.nextInt(kinds.length)];
      final when = DateTime(
        2026,
        9 + random.nextInt(3),
        1 + random.nextInt(28),
        random.nextInt(24),
        random.nextInt(60),
      );
      // Some round rupees, some with paise.
      final paise = random.nextBool()
          ? (1 + random.nextInt(3000)) * 100
          : 1 + random.nextInt(300000);
      final (payeeKey, payeeDisplay) = payees[random.nextInt(payees.length)];
      final category = random.nextInt(4) == 0
          ? null
          : categories[random.nextInt(categories.length)];
      final account = accounts[random.nextInt(accounts.length)];
      final note = notes[random.nextInt(notes.length)];
      final room = rooms[random.nextInt(rooms.length)];
      final origin = random.nextBool()
          ? TransactionOrigin.manual
          : TransactionOrigin.auto;
      final hidden = random.nextInt(12) == 0;
      final id = 'r$i';
      rows.add({
        'id': id,
        'kind': kind.name,
        'paise': paise,
        'at': [when.year, when.month, when.day, when.hour, when.minute],
        'categoryId': category?.id,
        'accountId': account.id,
        'roomId': room,
        'payeeKey': payeeKey,
        'payeeDisplay': payeeDisplay,
        'note': note,
        'origin': origin.name,
        'hidden': hidden,
      });
      items.add(
        TransactionItem(
          transaction: MoneyTransaction(
            id: id,
            kind: kind,
            amount: Money(paise),
            occurredAt: when,
            accountId: account.id,
            categoryId: category?.id,
            roomId: room,
            payeeKey: payeeKey,
            payeeDisplay: payeeDisplay,
            note: note,
            origin: origin,
            isHidden: hidden,
            createdAt: when,
            updatedAt: when,
          ),
          category: category,
          account: account,
        ),
      );
    }

    final filters = <String, TransactionFilter>{
      'everything': const TransactionFilter(),
      'swig': const TransactionFilter(query: 'swig'),
      'two words': const TransactionFilter(query: '  Dinner   ASHA '),
      'category name': const TransactionFilter(query: 'drinks'),
      'account name': const TransactionFilter(query: 'savings'),
      'upi id': const TransactionFilter(query: 'okhdfc'),
      'amount 24': const TransactionFilter(query: '24'),
      'amount with rupee and comma': const TransactionFilter(query: '₹1,2'),
      'amount with paise': const TransactionFilter(query: '12.5'),
      'amount with paise found': const TransactionFilter(query: '911.3'),
      'no match': const TransactionFilter(query: 'nothing here'),
      'food in goa': const TransactionFilter(categoryId: 'food', roomId: 'goa'),
      'hdfc refunds': const TransactionFilter(
        accountId: 'hdfc',
        kind: TransactionKind.refund,
      ),
      'captured petrol': const TransactionFilter(
        query: 'petrol',
        origin: TransactionOrigin.auto,
      ),
    };
    // Activity filters what is not hidden.
    final visible = items.where((i) => !i.transaction.isHidden).toList();
    final filterCases = [
      for (final MapEntry(:key, :value) in filters.entries)
        {
          'name': key,
          'query': value.query,
          'categoryId': value.categoryId,
          'roomId': value.roomId,
          'accountId': value.accountId,
          'kind': value.kind?.name,
          'origin': value.origin?.name,
          'ids': [
            for (final i in visible)
              if (value.matches(i)) i.transaction.id,
          ],
        },
    ];

    final today = LocalDay.of(DateTime(2026, 11, 19));
    final roomList = [
      Room(
        id: 'goa',
        name: 'Goa',
        type: RoomType.trip,
        autoTagMode: AutoTagMode.manual,
        createdAt: DateTime(2026, 9),
        startDay: LocalDay.of(DateTime(2026, 9, 3)),
        endDay: LocalDay.of(DateTime(2026, 10, 20)),
        budget: const Money(15000000),
      ),
      Room(
        id: 'wedding',
        name: 'Wedding',
        type: RoomType.wedding,
        autoTagMode: AutoTagMode.manual,
        createdAt: DateTime(2026, 9),
        startDay: LocalDay.of(DateTime(2026, 10, 2)),
      ),
      Room(
        id: 'later',
        name: 'Later',
        type: RoomType.event,
        autoTagMode: AutoTagMode.manual,
        createdAt: DateTime(2026, 9),
        startDay: LocalDay.of(DateTime(2026, 12, 2)),
        budget: Money.zero,
      ),
    ];
    String day(LocalDay d) {
      final t = d.date;
      return '${t.year}-${'${t.month}'.padLeft(2, '0')}'
          '-${'${t.day}'.padLeft(2, '0')}';
    }

    final roomCases = [
      for (final room in roomList)
        () {
          final s = RoomSummary.of(room, [
            for (final i in items)
              if (i.transaction.roomId == room.id) i.transaction,
          ], today: today);
          return {
            'id': room.id,
            'startDay': room.startDay?.value,
            'endDay': room.endDay?.value,
            'budget': room.budget?.paise,
            'spent': s.spent.paise,
            'byCategory': [
              for (final c in s.byCategory) [c.categoryId, c.spent.paise],
            ],
            'byDay': [
              for (final d in s.byDay) [day(d.day), d.spent.paise],
            ],
            'days': s.days,
            'perDay': s.perDay?.paise,
            'remaining': s.remaining?.paise,
          };
        }(),
    ];

    final json = const JsonEncoder.withIndent(' ').convert({
      'today': [2026, 11, 19],
      'categories': [
        for (final c in categories) {'id': c.id, 'name': c.name},
      ],
      'accounts': [
        for (final a in accounts) {'id': a.id, 'name': a.name},
      ],
      'transactions': rows,
      'filters': filterCases,
      'rooms': roomCases,
    });
    final fresh = '$json\n';
    final file = File(_path);
    if (Platform.environment['UPDATE_WEB_VECTORS'] == '1') {
      file
        ..createSync(recursive: true)
        ..writeAsStringSync(fresh);
    }
    expect(file.readAsStringSync(), fresh);
  });
}
