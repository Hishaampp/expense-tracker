import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/transaction_filter.dart';
import 'package:test/test.dart';

TransactionItem _item(
  int paise, {
  String? payee,
  String? note,
  String category = 'cat_food',
  String? roomId,
  TransactionKind kind = TransactionKind.expense,
  TransactionOrigin origin = TransactionOrigin.manual,
}) {
  final at = DateTime.utc(2026, 11, 10);
  return TransactionItem(
    transaction: MoneyTransaction(
      id: 't$paise',
      kind: kind,
      amount: Money(paise),
      occurredAt: at,
      accountId: 'account_cash',
      categoryId: category,
      roomId: roomId,
      payeeDisplay: payee,
      note: note,
      origin: origin,
      createdAt: at,
      updatedAt: at,
    ),
    category: Category(
      id: category,
      name: category == 'cat_food' ? 'Food & Dining' : 'Fuel',
      iconKey: 'food',
      kind: CategoryKind.expense,
      sortOrder: 0,
    ),
  );
}

void main() {
  final swiggy = _item(24000, payee: 'Swiggy');
  final fuel = _item(
    150050,
    payee: 'HP Petrol',
    category: 'cat_fuel',
    note: 'Bike tank',
    origin: TransactionOrigin.auto,
  );

  bool matches(TransactionFilter f, TransactionItem i) => f.matches(i);

  test('an empty filter matches everything and is not active', () {
    const filter = TransactionFilter();
    expect(filter.isActive, isFalse);
    expect(matches(filter, swiggy), isTrue);
  });

  test('a search matches payee, note and category, ignoring case', () {
    expect(matches(const TransactionFilter(query: 'SWIG'), swiggy), isTrue);
    expect(matches(const TransactionFilter(query: 'tank'), fuel), isTrue);
    expect(matches(const TransactionFilter(query: 'food'), swiggy), isTrue);
    expect(matches(const TransactionFilter(query: 'hp bike'), fuel), isTrue);
    expect(matches(const TransactionFilter(query: 'zomato'), swiggy), isFalse);
  });

  test('digits search amounts from the start', () {
    expect(matches(const TransactionFilter(query: '240'), swiggy), isTrue);
    expect(matches(const TransactionFilter(query: '24'), swiggy), isTrue);
    expect(matches(const TransactionFilter(query: '40'), swiggy), isFalse);
    expect(matches(const TransactionFilter(query: '₹1,500.5'), fuel), isTrue);
  });

  test('filters combine', () {
    const auto = TransactionFilter(origin: TransactionOrigin.auto);
    expect(matches(auto, fuel), isTrue);
    expect(matches(auto, swiggy), isFalse);
    final both = auto.copyWith(categoryId: 'cat_food');
    expect(both.filterCount, 2);
    expect(matches(both, fuel), isFalse);
    expect(matches(both.copyWith(clear: {FilterField.category}), fuel), isTrue);
  });
}
