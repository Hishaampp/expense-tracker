import 'dart:async';

import 'package:expense_tracker/routing/app_router.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/seed.dart';

Future<void> _openGoa(WidgetTester tester) async {
  final router = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(routerProvider)..go(Routes.rooms);
  await tester.pumpAndSettle();
  unawaited(router.push(Routes.room('goa')));
  await tester.pumpAndSettle();
  await bringIntoView(tester, find.text('Delete Room'));
  await tester.tap(find.text('Delete Room'));
  await tester.pumpAndSettle();
  expect(find.text('Delete Goa trip?'), findsOneWidget);
}

void main() {
  appTest('deleting a Room can keep its payments in the month', (tester) async {
    final db = await pumpApp(tester);
    await seedRoom(db, id: 'goa', name: 'Goa trip', type: 'trip');
    await seedExpense(db, DateTime(2026, 11, 4, 13), 1500, roomId: 'goa');
    await _openGoa(tester);

    await tester.tap(find.text('Delete the Room, keep its payments'));
    await tester.pumpAndSettle();

    expect(find.text('Room deleted'), findsOneWidget);
    expect(await db.select(db.rooms).get(), isEmpty);
    final txn = (await db.select(db.transactions).get()).single;
    expect(txn.roomId, isNull);
  });

  appTest('deleting a Room can take its payments with it', (tester) async {
    final db = await pumpApp(tester);
    await seedRoom(db, id: 'goa', name: 'Goa trip', type: 'trip');
    await seedExpense(db, DateTime(2026, 11, 4, 13), 1500, roomId: 'goa');
    await seedExpense(db, DateTime(2026, 11, 5, 13), 200);
    await _openGoa(tester);

    await tester.tap(find.text('Delete the Room and its payments'));
    await tester.pumpAndSettle();

    expect(await db.select(db.rooms).get(), isEmpty);
    final left = await db.select(db.transactions).get();
    expect(left.single.roomId, isNull);
    expect(left.single.amountPaise, 20000);
  });

  appTest('dismissing the sheet deletes nothing', (tester) async {
    final db = await pumpApp(tester);
    await seedRoom(db, id: 'goa', name: 'Goa trip', type: 'trip');
    await _openGoa(tester);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(await db.select(db.rooms).get(), hasLength(1));
  });
}
