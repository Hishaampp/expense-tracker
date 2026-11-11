import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

Future<void> _createRoom(WidgetTester tester, String name) async {
  await openTab(tester, 'Rooms');
  await tester.tap(find.byTooltip('New Room'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).first, name);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  final save = find.widgetWithText(FilledButton, 'Save');
  await tester.ensureVisible(save);
  await tester.pumpAndSettle();
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  appTest('no Rooms yet: say what they are and offer a trip', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Rooms');

    expect(find.text("Keep a trip's spending together"), findsOneWidget);
    await tester.tap(find.text('Start a trip'));
    await tester.pumpAndSettle();
    expect(find.text('Trip from Nov 10'), findsWidgets);
    expect(find.text("You've spent ₹0 on Trip from Nov 10."), findsOneWidget);
  });

  appTest('a new trip collects the expenses added to it', (tester) async {
    final db = await pumpApp(tester);
    await _createRoom(tester, 'Goa');
    expect(find.text("You've spent ₹0 on Goa."), findsOneWidget);

    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    expect(find.text('✈️ Goa'), findsOneWidget, reason: 'Room pre-selected');
    await typeAmount(tester, '340');
    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();

    expect(find.text("You've spent ₹340 on Goa."), findsOneWidget);
    final rooms = await db.select(db.rooms).get();
    final txns = await db.select(db.transactions).get();
    expect(txns.single.roomId, rooms.single.id);
  });

  appTest('during a trip, Quick Add puts expenses in it', (tester) async {
    final db = await pumpApp(tester);
    await _createRoom(tester, 'Goa');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await openTab(tester, 'Home');
    expect(find.text('✈️ Goa'), findsOneWidget, reason: 'Home Room chip');

    await addExpense(tester, '120', 'Food & Dining');
    final txn = (await db.select(db.transactions).get()).single;
    expect(txn.roomId, isNotNull);
  });

  appTest('an expense can be left out of the trip', (tester) async {
    final db = await pumpApp(tester);
    await _createRoom(tester, 'Goa');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await openTab(tester, 'Home');

    await tester.tap(find.byTooltip('Add expense').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('✈️ Goa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No Room'));
    await tester.pumpAndSettle();
    await typeAmount(tester, '90');
    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();

    expect((await db.select(db.transactions).get()).single.roomId, isNull);
  });

  appTest('a trip needs a start date; a name is required', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Rooms');
    await tester.tap(find.byTooltip('New Room'));
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Give the Room a name'), findsOneWidget);
  });

  appTest('a Room can move to history and back', (tester) async {
    await pumpApp(tester);
    await _createRoom(tester, 'Goa');
    final archive = find.text('Move to history');
    await tester.ensureVisible(archive);
    await tester.pumpAndSettle();
    await tester.tap(archive);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Goa'), findsOneWidget);
  });
}
