import 'package:drift/drift.dart' show Variable;
import 'package:expense_tracker/data/db/app_database.dart';

var _id = 0;

/// Saves an expense at [local] time straight into the database.
Future<void> seedExpense(
  AppDatabase db,
  DateTime local,
  int rupees, {
  String category = 'cat_food',
  String? payee,
  String? roomId,
  String reviewStatus = 'confirmed',
  String origin = 'manual',
  String kind = 'expense',
}) {
  final at = local.toUtc().millisecondsSinceEpoch;
  return db.customInsert(
    'INSERT INTO transactions (id, kind, amount_paise, occurred_at, '
    'account_id, category_id, room_id, payee_display, payee_key, instrument, '
    'review_status, origin, created_at, updated_at) VALUES '
    '(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    variables: [
      for (final v in [
        'seed-${_id++}',
        kind,
        rupees * 100,
        at,
        'account_cash',
        category,
        roomId,
        payee,
        payee?.toLowerCase(),
        'upi',
        reviewStatus,
        origin,
        at,
        at,
      ])
        Variable<Object>(v),
    ],
    updates: {db.transactions},
  );
}

/// Saves income at [local] time straight into the database.
Future<void> seedIncome(
  AppDatabase db,
  DateTime local,
  int rupees, {
  String category = 'cat_salary',
}) => seedExpense(db, local, rupees, category: category, kind: 'income');

/// Saves a Room straight into the database.
Future<void> seedRoom(
  AppDatabase db, {
  required String id,
  required String name,
  String type = 'wedding',
  String mode = 'suggest',
}) => db.customInsert(
  'INSERT INTO rooms (id, name, type, auto_tag_mode, created_at) '
  'VALUES (?, ?, ?, ?, 0)',
  variables: [
    Variable<String>(id),
    Variable<String>(name),
    Variable<String>(type),
    Variable<String>(mode),
  ],
  updates: {db.rooms},
);
