import 'package:drift/drift.dart';
import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/room.dart';
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

/// Maps a stored Room to its value type.
Room roomFromRow(RoomRow row) {
  return Room(
    id: row.id,
    name: row.name,
    type: row.type,
    emoji: row.emoji,
    startDay: row.startDay == null ? null : LocalDay(row.startDay!),
    endDay: row.endDay == null ? null : LocalDay(row.endDay!),
    budget: row.budgetPaise == null ? null : Money(row.budgetPaise!),
    autoTagMode: row.autoTagMode,
    countsTowardMonthlyBudget: row.countsTowardMonthlyBudget,
    status: row.status,
    createdAt: _fromMs(row.createdAt),
  );
}

/// Maps a Room to the row that stores it.
RoomsCompanion roomToRow(Room room) {
  return RoomsCompanion.insert(
    id: room.id,
    name: room.name,
    type: room.type,
    emoji: Value(room.emoji),
    startDay: Value(room.startDay?.value),
    endDay: Value(room.endDay?.value),
    budgetPaise: Value(room.budget?.paise),
    autoTagMode: room.autoTagMode,
    countsTowardMonthlyBudget: Value(room.countsTowardMonthlyBudget),
    status: Value(room.status),
    createdAt: room.createdAt.toUtc().millisecondsSinceEpoch,
  );
}
