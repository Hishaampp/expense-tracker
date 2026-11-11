import 'package:expense_tracker/core/merchant_categories.dart';
import 'package:test/test.dart';

void main() {
  test('UPI ids and names suggest categories', () {
    expect(suggestCategory(payeeKey: 'swiggy@icici'), 'cat_food');
    expect(suggestCategory(payeeName: 'BLINKIT'), 'cat_groceries');
    expect(suggestCategory(payeeKey: 'name:HP PETROL PUMP'), 'cat_fuel');
    expect(suggestCategory(payeeKey: 'amazonpay@apl'), 'cat_shopping');
  });

  test('short keywords match whole words only', () {
    expect(suggestCategory(payeeName: 'Rajiorder Stores'), isNull);
    expect(suggestCategory(payeeName: 'Jio Recharge'), 'cat_mobile');
  });

  test('unknown payees get no suggestion', () {
    expect(suggestCategory(payeeKey: '98xxxxxx01@ybl'), isNull);
    expect(suggestCategory(), isNull);
  });
}
