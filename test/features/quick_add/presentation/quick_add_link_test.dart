import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

/// The iPhone lock-screen widget opens the app with expensetracker://add.
void main() {
  appTest('the widget link opens Add', (tester) async {
    final links = FakeAppLinkSource();
    await pumpApp(tester, appLinks: links);
    links.send(Uri.parse('expensetracker://add'));
    await tester.pumpAndSettle();
    expect(find.text('Add expense'), findsWidgets);
    expect(find.text('Money in'), findsOneWidget);
  });

  appTest('launching from the widget opens Add', (tester) async {
    final links = FakeAppLinkSource()
      ..launchedWith = Uri.parse('expensetracker://add');
    await pumpApp(tester, appLinks: links);
    await tester.pumpAndSettle();
    expect(find.text('Money in'), findsOneWidget);
  });

  appTest('other links and the welcome are left alone', (tester) async {
    final links = FakeAppLinkSource();
    await pumpApp(tester, appLinks: links, onboarded: false);
    links.send(Uri.parse('expensetracker://add'));
    await tester.pumpAndSettle();
    expect(find.text('Every payment, written down for you'), findsOneWidget);

    links.send(Uri.parse('expensetracker://login-callback?code=x'));
    await tester.pumpAndSettle();
    expect(find.text('Money in'), findsNothing);
  });
}
