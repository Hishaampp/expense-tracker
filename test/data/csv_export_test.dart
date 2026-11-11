import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/data/backup/csv_export.dart';
import 'package:test/test.dart';

void main() {
  test('cells are quoted and formulas defused', () {
    final at = DateTime(2026, 11, 3, 9, 5);
    final csv = transactionsCsv(
      transactions: [
        MoneyTransaction(
          id: 't',
          kind: TransactionKind.expense,
          amount: const Money(123405),
          occurredAt: at.toUtc(),
          accountId: 'account_cash',
          payeeDisplay: '=HYPERLINK("x")',
          note: 'tea, "chai"',
          createdAt: at,
          updatedAt: at,
        ),
      ],
      categories: const [],
      accounts: const [],
      rooms: const [],
    );
    final row = csv.split('\r\n')[1];
    expect(row, startsWith('2026-11-03,09:05,expense,1234.05,'));
    expect(row, contains('"\'=HYPERLINK(""x"")"'));
    expect(row, contains('"tea, ""chai"""'));
  });
}
