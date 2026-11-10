import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('changing the month start day moves the month on Home', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Day 1'), findsOneWidget);

    await tester.tap(find.text('Month starts on'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Day 25'));
    await tester.tap(find.text('Day 25'));
    await tester.pumpAndSettle();
    expect(find.text('Month now starts on day 25'), findsOneWidget);

    // 10 November is before the 25th, so the month runs 25 Oct – 24 Nov.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Oct 25 – Nov 24, 2026'), findsOneWidget);
  });

  appTest('dismissing the picker changes nothing', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Month starts on'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Day 1'), findsOneWidget);
  });
}
