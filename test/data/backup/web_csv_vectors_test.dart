// The app's CSV export, written out for the website's CSV to match byte
// for byte (web/src/lib/export/csv.test.ts). Transactions are given as
// local calendar dates, so the case holds in every time zone. Regenerate
// after a deliberate change with
//   UPDATE_WEB_VECTORS=1 flutter test test/data/backup/web_csv_vectors_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/data/backup/csv_export.dart';
import 'package:test/test.dart';

const _path = 'web/src/lib/export/fixtures/csv-vectors.json';

void main() {
  test('the website CSV case is current', () {
    const categories = [
      Category(
        id: 'food',
        name: 'Food, drinks',
        iconKey: 'food',
        kind: CategoryKind.expense,
        sortOrder: 0,
      ),
    ];
    const accounts = [
      Account(id: 'hdfc', name: 'HDFC "Savings"', type: AccountType.bank),
    ];
    final rooms = [
      Room(
        id: 'goa',
        name: 'Goa',
        type: RoomType.trip,
        autoTagMode: AutoTagMode.manual,
        createdAt: DateTime(2026),
      ),
    ];
    final cases = <Map<String, Object?>>[
      {
        'id': 'a',
        'kind': 'expense',
        'paise': 24050,
        'at': [2026, 11, 3, 9, 5],
        'categoryId': 'food',
        'accountId': 'hdfc',
        'payee': 'Swiggy',
        'note': 'Dinner, with "Asha"',
      },
      {
        'id': 'b',
        'kind': 'refund',
        'paise': 7,
        'at': [2026, 11, 4, 23, 59],
        'accountId': 'hdfc',
        'roomId': 'goa',
        'payee': '=HYPERLINK("http://x")',
        'note': 'line one\nline two',
        'review': 'needsReview',
        'origin': 'auto',
      },
      {
        'id': 'c',
        'kind': 'income',
        'paise': 8500000,
        'at': [2026, 11, 1, 0, 0],
        'accountId': 'missing',
        'payee': '-minus',
        'note': '@mention',
      },
      {
        'id': 'd',
        'kind': 'transfer',
        'paise': 100,
        'at': [2026, 10, 31, 12, 30],
        'accountId': 'hdfc',
        'payee': '+plus',
      },
      {
        'id': 'e',
        'kind': 'expense',
        'paise': 99999,
        'at': [2026, 11, 5, 8, 0],
        'accountId': 'hdfc',
        'hidden': true,
      },
    ];
    final transactions = [
      for (final c in cases)
        () {
          final at = c['at']! as List<int>;
          final when = DateTime(at[0], at[1], at[2], at[3], at[4]);
          return MoneyTransaction(
            id: c['id']! as String,
            kind: TransactionKind.values.byName(c['kind']! as String),
            amount: Money(c['paise']! as int),
            occurredAt: when,
            accountId: c['accountId']! as String,
            categoryId: c['categoryId'] as String?,
            roomId: c['roomId'] as String?,
            payeeDisplay: c['payee'] as String?,
            note: c['note'] as String?,
            reviewStatus: c['review'] == 'needsReview'
                ? ReviewStatus.needsReview
                : ReviewStatus.confirmed,
            origin: c['origin'] == 'auto'
                ? TransactionOrigin.auto
                : TransactionOrigin.manual,
            isHidden: c['hidden'] == true,
            createdAt: when,
            updatedAt: when,
          );
        }(),
    ];
    final csv = transactionsCsv(
      transactions: transactions,
      categories: categories,
      accounts: accounts,
      rooms: rooms,
    );
    final json = const JsonEncoder.withIndent(' ').convert({
      'categories': [
        for (final c in categories) {'id': c.id, 'name': c.name},
      ],
      'accounts': [
        for (final a in accounts) {'id': a.id, 'name': a.name},
      ],
      'rooms': [
        for (final r in rooms) {'id': r.id, 'name': r.name},
      ],
      'transactions': cases,
      'csv': csv,
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
