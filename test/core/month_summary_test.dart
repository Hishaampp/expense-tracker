import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:test/test.dart';

MoneyTransaction _txn(
  int paise, {
  TransactionKind kind = TransactionKind.expense,
  String? categoryId,
  String? roomId,
  bool isHidden = false,
}) {
  final at = DateTime.utc(2026, 11, 10);
  return MoneyTransaction(
    id: 'id-$paise-$kind-$categoryId-$roomId',
    kind: kind,
    amount: Money(paise),
    occurredAt: at,
    accountId: 'account_cash',
    categoryId: categoryId,
    roomId: roomId,
    isHidden: isHidden,
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  test('empty input gives zero totals', () {
    final summary = MonthSummary.of(const []);
    expect(summary.spent, Money.zero);
    expect(summary.moneyIn, Money.zero);
    expect(summary.byCategory, isEmpty);
  });

  test('spent is expenses minus refunds; transfers are ignored', () {
    final summary = MonthSummary.of([
      _txn(50000, categoryId: 'food'),
      _txn(20000, categoryId: 'fuel'),
      _txn(10000, kind: TransactionKind.refund, categoryId: 'food'),
      _txn(200000, kind: TransactionKind.transfer),
      _txn(5200000, kind: TransactionKind.income),
    ]);
    expect(summary.spent, const Money(60000));
    expect(summary.moneyIn, const Money(5200000));
  });

  test('Room spending is included in spent and reported separately', () {
    final summary = MonthSummary.of([
      _txn(30000, categoryId: 'food'),
      _txn(620000, categoryId: 'travel', roomId: 'goa'),
    ]);
    expect(summary.spent, const Money(650000));
    expect(summary.spentInRooms, const Money(620000));
  });

  test('hidden transactions are not counted', () {
    final summary = MonthSummary.of([
      _txn(30000, categoryId: 'food'),
      _txn(99900, categoryId: 'food', isHidden: true),
    ]);
    expect(summary.spent, const Money(30000));
  });

  test('categories are sorted largest first, uncategorised included', () {
    final summary = MonthSummary.of([
      _txn(100, categoryId: 'a'),
      _txn(300, categoryId: 'b'),
      _txn(200),
      _txn(50, categoryId: 'a'),
    ]);
    expect(summary.byCategory, [
      (categoryId: 'b', spent: const Money(300)),
      (categoryId: null, spent: const Money(200)),
      (categoryId: 'a', spent: const Money(150)),
    ]);
  });

  test('a fully refunded category is left out', () {
    final summary = MonthSummary.of([
      _txn(100, categoryId: 'a'),
      _txn(100, kind: TransactionKind.refund, categoryId: 'a'),
    ]);
    expect(summary.byCategory, isEmpty);
  });
}
