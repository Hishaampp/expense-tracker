import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:expense_tracker/data/sync/sync_engine.dart';
import 'package:expense_tracker/routing/app_router.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/seed.dart';

Future<void> _open(WidgetTester tester) async {
  ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
      .read(routerProvider)
      .go(Routes.account);
  await tester.pumpAndSettle();
}

Future<void> _signIn(WidgetTester tester, {String code = '123456'}) async {
  await tester.enterText(find.byType(TextFormField), 'asha@example.com');
  await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField), code);
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await tester.pumpAndSettle();
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  appTest('the first phone signs in, gets a recovery code and syncs', (
    tester,
  ) async {
    final server = MemorySyncServer();
    final keys = FakeSyncKeyStore();
    final db = await pumpApp(tester, syncServer: server, syncKeys: keys);
    await seedExpense(db, DateTime(2026, 11, 3, 13), 300, payee: 'Swiggy');
    await _open(tester);
    expect(find.text('Keep your data on every phone'), findsOneWidget);

    await _signIn(tester);
    expect(find.text('Write down your recovery code'), findsOneWidget);
    expect(find.text(keys.key!.recoveryCode), findsOneWidget);
    // Everything already on the phone went up, sealed.
    expect(server.stored, isNotEmpty);

    await tester.tap(find.text("I've written it down"));
    await tester.pumpAndSettle();
    expect(find.text('Signed in as asha@example.com'), findsOneWidget);
  });

  appTest('a wrong email code says so', (tester) async {
    await pumpApp(tester);
    await _open(tester);
    await _signIn(tester, code: '000000');
    expect(
      find.text("That code didn't work. Check it, or send a new one."),
      findsOneWidget,
    );
  });

  appTest('a second phone needs the recovery code, then gets the data', (
    tester,
  ) async {
    // The first phone, already syncing.
    final server = MemorySyncServer();
    final firstKeys = FakeSyncKeyStore();
    final first = await pumpApp(
      tester,
      syncServer: server,
      syncKeys: firstKeys,
    );
    await seedExpense(first, DateTime(2026, 11, 3, 13), 300, payee: 'Swiggy');
    await _open(tester);
    await _signIn(tester);
    final code = firstKeys.key!.recoveryCode;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));

    // A new phone, same account.
    final phone = await pumpApp(tester, syncServer: server);
    await _open(tester);
    await _signIn(tester);
    expect(find.text('Enter your recovery code'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'WRONG-CODE');
    await tester.tap(find.text('Unlock my data'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "That code doesn't open this account's data. Check it and try again.",
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), code.toLowerCase());
    await tester.tap(find.text('Unlock my data'));
    await tester.pumpAndSettle();
    expect(find.text('Signed in as asha@example.com'), findsOneWidget);
    final txns = await phone.select(phone.transactions).get();
    expect(txns.single.payeeDisplay, 'Swiggy');
  });

  appTest('signing out keeps the data on the phone', (tester) async {
    final auth = FakeCloudAuth();
    final db = await pumpApp(tester, cloudAuth: auth);
    await seedExpense(db, DateTime(2026, 11, 3, 13), 300);
    await _open(tester);
    await _signIn(tester);
    await tester.tap(find.text("I've written it down"));
    await tester.pumpAndSettle();

    await bringIntoView(tester, find.text('Sign out'));
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(
      find.text('Signed out. Your data stays on this phone.'),
      findsOneWidget,
    );
    expect(auth.signedIn, isNull);
    expect(await db.select(db.transactions).get(), hasLength(1));
    expect(await db.select(db.syncOutbox).get(), isEmpty);
  });
}
