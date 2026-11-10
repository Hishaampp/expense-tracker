import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/data/db/app_database.dart';

/// Id of the built-in "Other" expense category.
const String otherCategoryId = 'cat_other';

const List<(String, String, String)> _expenseSeed = [
  ('cat_food', 'Food & Dining', 'food'),
  ('cat_groceries', 'Groceries', 'groceries'),
  ('cat_transport', 'Transport', 'transport'),
  ('cat_fuel', 'Fuel', 'fuel'),
  ('cat_shopping', 'Shopping', 'shopping'),
  ('cat_bills', 'Bills & Utilities', 'bills'),
  ('cat_mobile', 'Mobile & Internet', 'mobile'),
  ('cat_rent', 'Rent', 'rent'),
  ('cat_emi', 'EMI & Loans', 'emi'),
  ('cat_health', 'Health', 'health'),
  ('cat_education', 'Education', 'education'),
  ('cat_entertainment', 'Entertainment', 'entertainment'),
  ('cat_personal', 'Personal Care', 'personal'),
  ('cat_gifts', 'Gifts & Shagun', 'gifts'),
  ('cat_family', 'Family Support', 'family'),
  ('cat_travel', 'Travel', 'travel'),
  ('cat_fees', 'Fees & Charges', 'fees'),
  (otherCategoryId, 'Other', 'other'),
];

const List<(String, String, String)> _systemSeed = [
  ('cat_transfer', 'Transfer', 'transfer'),
  ('cat_salary', 'Salary', 'salary'),
  ('cat_refund', 'Refund', 'refund'),
  ('cat_other_income', 'Other income', 'income'),
];

/// Inserts the Cash account and default categories (spec §8) into a newly
/// created database. [nowUtcMs] stamps the created rows.
Future<void> seedDatabase(AppDatabase db, int nowUtcMs) async {
  await db.batch((batch) {
    batch
      ..insert(
        db.accounts,
        AccountsCompanion.insert(
          id: Account.cashId,
          name: 'Cash',
          type: AccountType.cash,
          createdAt: nowUtcMs,
        ),
      )
      ..insertAll(db.categories, [
        for (final (index, (id, name, icon)) in _expenseSeed.indexed)
          CategoriesCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            kind: CategoryKind.expense,
            sortOrder: index,
          ),
        for (final (index, (id, name, icon)) in _systemSeed.indexed)
          CategoriesCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            kind: CategoryKind.system,
            sortOrder: 100 + index,
          ),
      ]);
  });
}
