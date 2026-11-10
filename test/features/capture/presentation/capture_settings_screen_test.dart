import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

Future<void> _open(WidgetTester tester) async {
  await openTab(tester, 'Settings');
  await tester.tap(find.text('Auto-capture'));
  await tester.pumpAndSettle();
}

void main() {
  appTest('off: the disclosure comes before turning it on', (tester) async {
    final control = FakeCaptureControl();
    await pumpApp(tester, captureControl: control);
    await openTab(tester, 'Settings');
    expect(find.bySemanticsLabel('Auto-capture, off'), findsOneWidget);
    await _open(tester);

    expect(find.text('Auto-capture is off'), findsOneWidget);
    expect(find.text('What the app reads'), findsOneWidget);
    expect(
      find.text('If Android says the setting is restricted'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Turn on auto-capture'));
    await tester.pumpAndSettle();
    expect(control.calls, ['openCaptureSettings']);
  });

  appTest('battery steps match the phone maker', (tester) async {
    await pumpApp(
      tester,
      captureControl: FakeCaptureControl(manufacturer: 'vivo'),
    );
    await _open(tester);
    await tester.scrollUntilVisible(
      find.textContaining('On Vivo and iQOO'),
      200,
    );

    expect(find.textContaining('On Vivo and iQOO'), findsOneWidget);
  });

  appTest('apps can be switched off', (tester) async {
    final control = FakeCaptureControl(listenerEnabled: true);
    await pumpApp(tester, captureControl: control);
    await _open(tester);
    expect(find.text('Auto-capture is on'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('PhonePe'), 200);

    await tester.tap(find.text('PhonePe'));
    await tester.pumpAndSettle();
    expect(control.allowed, ['com.google.android.apps.messaging']);
  });

  appTest('sideload: past SMS can be imported', (tester) async {
    final control = FakeCaptureControl(
      listenerEnabled: true,
      smsSupported: true,
      smsPermission: true,
    );
    await pumpApp(tester, captureControl: control);
    await _open(tester);
    await tester.scrollUntilVisible(find.text('Import past messages'), 200);

    await tester.tap(find.text('Import past messages'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last 3 months'));
    await tester.pumpAndSettle();
    expect(control.calls, contains('import:3'));
    expect(find.text('12 messages imported'), findsOneWidget);
  });

  appTest('iPhone explains what is coming', (tester) async {
    await pumpApp(tester, captureControl: FakeCaptureControl(platform: 'ios'));
    await _open(tester);

    expect(find.text('Auto-capture on iPhone'), findsOneWidget);
  });
}
