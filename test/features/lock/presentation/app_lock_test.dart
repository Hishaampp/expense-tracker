import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('a locked app shows nothing until the user unlocks', (tester) async {
    final auth = FakeDeviceAuth()..allow = false;
    await pumpApp(tester, appLock: true, deviceAuth: auth);

    expect(find.text('Your expenses stay private until you unlock.'), findsOne);
    expect(find.text('Hi!'), findsNothing);
    expect(auth.asked, 1, reason: 'asks at once on open');

    auth.allow = true;
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.text('Hi!'), findsOneWidget);
  });

  appTest('turning the lock on asks the user to prove it is them', (
    tester,
  ) async {
    final auth = FakeDeviceAuth()..allow = false;
    final db = await pumpApp(tester, deviceAuth: auth);
    await openTab(tester, 'Settings');
    await bringIntoView(
      tester,
      find.text('Lock with Face ID, fingerprint or passcode'),
    );

    await tester.tap(find.text('Lock with Face ID, fingerprint or passcode'));
    await tester.pumpAndSettle();
    expect(auth.asked, 1);
    expect(
      (await db.select(db.settings).get()).map((s) => s.key),
      isNot(contains('app_lock')),
    );

    auth.allow = true;
    await tester.tap(find.text('Lock with Face ID, fingerprint or passcode'));
    await tester.pumpAndSettle();
    final lock = (await db.select(db.settings).get()).where(
      (s) => s.key == 'app_lock',
    );
    expect(lock.single.value, 'on');
  });

  appTest('a phone without a screen lock is told what to do', (tester) async {
    final auth = FakeDeviceAuth()..available = false;
    await pumpApp(tester, deviceAuth: auth);
    await openTab(tester, 'Settings');
    await bringIntoView(
      tester,
      find.text('Lock with Face ID, fingerprint or passcode'),
    );
    await tester.tap(find.text('Lock with Face ID, fingerprint or passcode'));
    await tester.pumpAndSettle();
    expect(find.text('Set a screen lock on your phone first.'), findsOneWidget);
  });
}
