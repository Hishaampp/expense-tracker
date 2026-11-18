// The app's month maths, written out for the website's Overview to match
// (web/src/lib/insights/overview.test.ts). Transactions are given as local
// calendar dates, so the cases hold in every time zone. Regenerate after a
// deliberate change with
//   UPDATE_WEB_VECTORS=1 flutter test test/core/web_overview_vectors_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/core/month_summary.dart';
import 'package:expense_tracker/core/safe_to_spend.dart';
import 'package:test/test.dart';

const _path = 'web/src/lib/insights/fixtures/overview-vectors.json';

String _day(DateTime d) =>
    '${d.year}-${'${d.month}'.padLeft(2, '0')}-${'${d.day}'.padLeft(2, '0')}';

void main() {
  test('the website Overview cases are current', () {
    final random = Random(7);
    const kinds = [
      TransactionKind.expense,
      TransactionKind.expense,
      TransactionKind.expense,
      TransactionKind.expense,
      TransactionKind.expense,
      TransactionKind.expense,
      TransactionKind.expense,
      TransactionKind.refund,
      TransactionKind.income,
      TransactionKind.transfer,
    ];
    const categories = ['food', 'fuel', 'rent', 'shopping', null];
    const rooms = [null, null, null, null, 'goa', 'office'];
    final rows = <Map<String, Object?>>[];
    final txns = <MoneyTransaction>[];
    for (var i = 0; i < 420; i++) {
      final kind = kinds[random.nextInt(kinds.length)];
      final at = [
        2025,
        9 + random.nextInt(15),
        1 + random.nextInt(31),
        random.nextInt(24),
        random.nextInt(60),
      ];
      final when = DateTime(at[0], at[1], at[2], at[3], at[4]);
      final paise = kind == TransactionKind.income
          ? 2000000 + random.nextInt(6000000)
          : 1000 + random.nextInt(250000);
      final category = categories[random.nextInt(categories.length)];
      final room = rooms[random.nextInt(rooms.length)];
      final hidden = random.nextInt(15) == 0;
      final id = 't$i';
      rows.add({
        'id': id,
        'kind': kind.name,
        'paise': paise,
        'at': [when.year, when.month, when.day, when.hour, when.minute],
        'categoryId': category,
        'roomId': room,
        'hidden': hidden,
      });
      txns.add(
        MoneyTransaction(
          id: id,
          kind: kind,
          amount: Money(paise),
          occurredAt: when,
          accountId: 'cash',
          categoryId: category,
          roomId: room,
          isHidden: hidden,
          createdAt: when,
          updatedAt: when,
        ),
      );
    }
    const budgetRooms = {'office'};
    const monthlyBudget = 1500000;

    Map<String, Object?> summarise(MonthSummary s) => {
      'spent': s.spent.paise,
      'spentInRooms': s.spentInRooms.paise,
      'spentForBudget': s.spentForBudget.paise,
      'moneyIn': s.moneyIn.paise,
      'byCategory': [
        for (final c in s.byCategory) [c.categoryId, c.spent.paise],
      ],
      'budgetByCategory': {
        for (final e in s.budgetByCategory.entries) e.key ?? '': e.value.paise,
      },
    };

    List<MoneyTransaction> inPeriod(MonthPeriod p) => [
      for (final t in txns)
        if (p.contains(t.occurredAt)) t,
    ];

    int net(DateTime from, DateTime to) {
      var sum = 0;
      for (final t in txns) {
        if (t.isHidden) continue;
        if (t.occurredAt.isBefore(from) || !t.occurredAt.isBefore(to)) {
          continue;
        }
        sum += switch (t.kind) {
          TransactionKind.income || TransactionKind.refund => t.amount.paise,
          TransactionKind.expense => -t.amount.paise,
          TransactionKind.transfer => 0,
        };
      }
      return sum;
    }

    final firstIncome = txns
        .where((t) => !t.isHidden && t.kind == TransactionKind.income)
        .map((t) => t.occurredAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final cases = <Map<String, Object?>>[];
    for (final startDay in [1, 25, 28]) {
      for (final today in [
        DateTime(2026, 11, 19),
        DateTime(2026, 2, 28),
        DateTime(2026, 3),
        DateTime(2026, 12, 31),
      ]) {
        for (final offset in [0, -1, -5]) {
          final period = MonthPeriod.containing(
            today,
            startDay: startDay,
          ).shifted(offset);
          final summary = MonthSummary.of(
            inPeriod(period),
            budgetRoomIds: budgetRooms,
          );
          final balanceStart = MonthPeriod.containing(
            firstIncome,
            startDay: startDay,
          ).start;
          final carried = balanceStart.isBefore(period.start)
              ? net(balanceStart, period.start)
              : 0;
          final safe = SafeToSpend.of(
            budget: offset == 0 ? const Money(monthlyBudget) : null,
            spent: summary.spentForBudget,
            period: period,
            today: today,
          );
          cases.add({
            'startDay': startDay,
            'today': _day(today),
            'offset': offset,
            'start': _day(period.start),
            'end': _day(period.end),
            'daysElapsed': period.daysElapsedOn(today),
            'daysLeft': period.daysLeftIncluding(today),
            'summary': summarise(summary),
            'dailyAverage': summary.spent
                .dividedRounded(period.daysElapsedOn(today))
                .paise,
            'carried': carried,
            'safe': switch (safe) {
              NoBudget() => {'kind': 'none'},
              OnTrack(:final left, :final daysLeft, :final perDay) => {
                'kind': 'onTrack',
                'left': left.paise,
                'daysLeft': daysLeft,
                'perDay': perDay.paise,
              },
              Overspent(:final over) => {'kind': 'over', 'over': over.paise},
            },
          });
        }
      }
    }

    final json = const JsonEncoder.withIndent(' ').convert({
      'budgetRooms': budgetRooms.toList(),
      'monthlyBudget': monthlyBudget,
      'transactions': rows,
      'cases': cases,
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
