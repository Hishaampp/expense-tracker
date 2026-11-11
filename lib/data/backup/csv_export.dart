import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/room.dart';

/// Every transaction as CSV for a spreadsheet (spec §13). Unencrypted:
/// the screen warns before sharing it. Amounts are in rupees with two
/// decimals; times are the phone's local time.
String transactionsCsv({
  required List<MoneyTransaction> transactions,
  required List<Category> categories,
  required List<Account> accounts,
  required List<Room> rooms,
}) {
  final category = {for (final c in categories) c.id: c.name};
  final account = {for (final a in accounts) a.id: a.name};
  final room = {for (final r in rooms) r.id: r.name};
  String two(int n) => n.toString().padLeft(2, '0');
  final lines = <List<String>>[
    [
      'Date',
      'Time',
      'Type',
      'Amount (INR)',
      'Category',
      'Account',
      'Room',
      'Payee',
      'Note',
      'Status',
      'Source',
    ],
    for (final t in transactions)
      if (!t.isHidden)
        () {
          final at = t.occurredAt.toLocal();
          final paise = t.amount.paise;
          return [
            '${at.year}-${two(at.month)}-${two(at.day)}',
            '${two(at.hour)}:${two(at.minute)}',
            t.kind.name,
            '${paise ~/ 100}.${two(paise % 100)}',
            category[t.categoryId] ?? '',
            account[t.accountId] ?? '',
            room[t.roomId] ?? '',
            t.payeeDisplay ?? '',
            t.note ?? '',
            t.reviewStatus.name,
            t.origin.name,
          ];
        }(),
  ];
  return '${lines.map((l) => l.map(_cell).join(',')).join('\r\n')}\r\n';
}

// Quotes a cell when needed, and defuses text a spreadsheet would run as a
// formula (a payee named "=HYPERLINK(...)").
String _cell(String value) {
  final safe = RegExp(r'^[=+\-@\t\r]').hasMatch(value) ? "'$value" : value;
  if (!RegExp(r'[",\r\n]').hasMatch(safe)) return safe;
  return '"${safe.replaceAll('"', '""')}"';
}
