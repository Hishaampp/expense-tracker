import 'package:drift/drift.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/data/db/app_database.dart';

DateTime _fromMs(int utcMs) =>
    DateTime.fromMillisecondsSinceEpoch(utcMs, isUtc: true);

/// Maps a stored account to its value type.
Account accountFromRow(AccountRow row) {
  return Account(
    id: row.id,
    name: row.name,
    type: row.type,
    isArchived: row.isArchived,
  );
}

/// Maps a stored category to its value type.
Category categoryFromRow(CategoryRow row) {
  return Category(
    id: row.id,
    name: row.name,
    iconKey: row.icon,
    kind: row.kind,
    sortOrder: row.sortOrder,
    isArchived: row.isArchived,
  );
}

/// Maps a stored transaction to its value type.
MoneyTransaction transactionFromRow(TransactionRow row) {
  return MoneyTransaction(
    id: row.id,
    kind: row.kind,
    amount: Money(row.amountPaise, Currency.tryParse(row.currency)!),
    occurredAt: _fromMs(row.occurredAt),
    accountId: row.accountId,
    toAccountId: row.toAccountId,
    categoryId: row.categoryId,
    roomId: row.roomId,
    payeeKey: row.payeeKey,
    payeeDisplay: row.payeeDisplay,
    instrument: row.instrument,
    refNo: row.refNo,
    note: row.note,
    reviewStatus: row.reviewStatus,
    isHidden: row.isHidden,
    linkedTransactionId: row.linkedTransactionId,
    origin: row.origin,
    createdAt: _fromMs(row.createdAt),
    updatedAt: _fromMs(row.updatedAt),
  );
}

/// Maps a transaction to the row that stores it.
TransactionsCompanion transactionToRow(MoneyTransaction txn) {
  return TransactionsCompanion.insert(
    id: txn.id,
    kind: txn.kind,
    amountPaise: txn.amount.paise,
    currency: Value(txn.amount.currency.code),
    occurredAt: txn.occurredAt.toUtc().millisecondsSinceEpoch,
    accountId: txn.accountId,
    toAccountId: Value(txn.toAccountId),
    categoryId: Value(txn.categoryId),
    roomId: Value(txn.roomId),
    payeeKey: Value(txn.payeeKey),
    payeeDisplay: Value(txn.payeeDisplay),
    instrument: txn.instrument,
    refNo: Value(txn.refNo),
    note: Value(txn.note),
    reviewStatus: txn.reviewStatus,
    isHidden: Value(txn.isHidden),
    linkedTransactionId: Value(txn.linkedTransactionId),
    origin: txn.origin,
    createdAt: txn.createdAt.toUtc().millisecondsSinceEpoch,
    updatedAt: txn.updatedAt.toUtc().millisecondsSinceEpoch,
  );
}
