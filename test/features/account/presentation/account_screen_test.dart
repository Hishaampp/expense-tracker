import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:expense_tracker/data/sync/computer_link.dart';
import 'package:expense_tracker/data/sync/computer_link_server.dart';
import 'package:expense_tracker/data/sync/sync_controller.dart';
import 'package:expense_tracker/data/sync/sync_crypto.dart';
import 'package:expense_tracker/data/sync/sync_engine.dart';
import 'package:expense_tracker/features/account/presentation/account_screen.dart';
import 'package:expense_tracker/features/account/presentation/link_computer_screen.dart';
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

  appTest('a lost code: start over with the phone records and a new code', (
    tester,
  ) async {
    // The first phone synced, then its code was lost.
    final server = MemorySyncServer();
    final oldKeys = FakeSyncKeyStore();
    final first = await pumpApp(tester, syncServer: server, syncKeys: oldKeys);
    await seedExpense(first, DateTime(2026, 11, 3, 13), 300, payee: 'Swiggy');
    await _open(tester);
    await _signIn(tester);
    final oldKey = oldKeys.key!;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));

    // A new phone, same account, its records restored from a backup.
    final keys = FakeSyncKeyStore();
    final phone = await pumpApp(tester, syncServer: server, syncKeys: keys);
    await seedExpense(phone, DateTime(2026, 11, 4, 9), 120, payee: 'Chai');
    await _open(tester);
    await _signIn(tester);
    expect(find.text('Enter your recovery code'), findsOneWidget);

    // Backing out of the warning changes nothing.
    await tester.tap(find.text('Lost your code? Start over'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your recovery code'), findsOneWidget);
    expect(keys.key, isNull);

    await tester.tap(find.text('Lost your code? Start over'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Start over'));
    await tester.pumpAndSettle();
    expect(find.text('Write down your recovery code'), findsOneWidget);
    expect(find.text(keys.key!.recoveryCode), findsOneWidget);

    // The cloud now holds only this phone's records, under the new key.
    final records = server.stored;
    expect(records, isNotEmpty);
    for (final record in records) {
      expect(await SyncCrypto(keys.key!).open(record), isNotNull);
      expect(await SyncCrypto(oldKey).open(record), isNull);
    }
    final txns = await phone.select(phone.transactions).get();
    expect(txns.single.payeeDisplay, 'Chai');
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

  appTest('tapping the email link signs in and shows the recovery code', (
    tester,
  ) async {
    final auth = FakeCloudAuth();
    final keys = FakeSyncKeyStore();
    await pumpApp(tester, cloudAuth: auth, syncKeys: keys);
    await _open(tester);
    await tester.enterText(find.byType(TextFormField), 'asha@example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await tester.pumpAndSettle();

    auth.signInByLink('asha@example.com');
    await tester.pumpAndSettle();
    expect(find.text('Write down your recovery code'), findsOneWidget);
    expect(find.text(keys.key!.recoveryCode), findsOneWidget);
  });

  group('Link a computer', () {
    // The website's half, in Dart: a one-time key pair and its QR.
    Future<(SimpleKeyPair, ComputerLink)> website() async {
      final pair = await X25519().newKeyPair();
      final public = (await pair.extractPublicKey()).bytes;
      final key = base64Url.encode(public).replaceAll('=', '');
      return (pair, ComputerLink.tryParse('AMPLE2:${'5e' * 16}:$key')!);
    }

    Future<List<int>> open(
      SimpleKeyPair web,
      ComputerLink link,
      SealedLink s,
    ) async {
      final shared = await X25519().sharedSecretKey(
        keyPair: web,
        remotePublicKey: SimplePublicKey(
          base64.decode(s.phoneKey),
          type: KeyPairType.x25519,
        ),
      );
      final boxKey = await Hkdf(
        hmac: Hmac.sha256(),
        outputLength: 32,
      ).deriveKey(secretKey: shared, info: utf8.encode('ample-link-v2'));
      final bytes = base64.decode(s.sealed);
      return await AesGcm.with256bits().decrypt(
        SecretBox(
          bytes.sublist(12, bytes.length - 16),
          nonce: bytes.sublist(0, 12),
          mac: Mac(bytes.sublist(bytes.length - 16)),
        ),
        secretKey: boxKey,
        aad: utf8.encode(link.id),
      );
    }

    LinkOutcome? outcome;

    Future<void> link(WidgetTester tester, ComputerLink computer) async {
      // A Consumer widget's element is its WidgetRef.
      final element = tester.element(find.byType(AccountScreen));
      final done = confirmAndLink(
        element,
        element as WidgetRef,
        computer,
      ).then((value) => outcome = value);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in computer'));
      await tester.pumpAndSettle();
      await done;
    }

    appTest('a syncing phone hands its key to that computer only', (
      tester,
    ) async {
      final keys = FakeSyncKeyStore();
      final links = MemoryComputerLinkServer();
      await pumpApp(tester, syncKeys: keys, linkServer: links);
      await _open(tester);
      await _signIn(tester);
      await tester.tap(find.text("I've written it down"));
      await tester.pumpAndSettle();
      expect(find.text('Link a computer'), findsOneWidget);

      final (web, computer) = await website();
      await link(tester, computer);
      expect(outcome, LinkOutcome.linked);
      expect(
        find.text('Computer signed in. Your records are opening there now.'),
        findsOneWidget,
      );
      final sealed = links.posted[computer.id]!;
      final pass = jsonDecode(
        utf8.decode(await open(web, computer, sealed)),
      ) as Map<String, dynamic>;
      expect(base64.decode(pass['key'] as String), keys.key!.bytes);
      expect(pass['email'], 'asha@example.com');
      expect(pass['token'], 'pkce_test');
    });

    appTest('without sync there is no key to give', (tester) async {
      final links = MemoryComputerLinkServer();
      await pumpApp(tester, linkServer: links);
      await _open(tester);
      final (_, computer) = await website();
      await link(tester, computer);
      expect(outcome, LinkOutcome.notSyncing);
      expect(links.posted, isEmpty);
    });

    appTest('offline, it says so and leaves nothing behind', (tester) async {
      final links = MemoryComputerLinkServer()..offline = true;
      await pumpApp(tester, linkServer: links);
      await _open(tester);
      await _signIn(tester);
      await tester.tap(find.text("I've written it down"));
      await tester.pumpAndSettle();
      final (_, computer) = await website();
      await link(tester, computer);
      expect(outcome, LinkOutcome.failed);
      expect(
        find.text(
          "Couldn't reach the server. Check your connection and scan again.",
        ),
        findsOneWidget,
      );
    });
  });
}
