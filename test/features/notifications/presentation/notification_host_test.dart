import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/seed.dart';

/// Walks the app through the lifecycle states in the order the platform
/// reports them.
void _lifecycle(WidgetTester tester, List<AppLifecycleState> states) =>
    states.forEach(tester.binding.handleAppLifecycleStateChanged);

void _toBackground(WidgetTester tester) => _lifecycle(tester, const [
  AppLifecycleState.resumed,
  AppLifecycleState.inactive,
  AppLifecycleState.hidden,
  AppLifecycleState.paused,
]);

void _toForeground(WidgetTester tester) => _lifecycle(tester, const [
  AppLifecycleState.hidden,
  AppLifecycleState.inactive,
  AppLifecycleState.resumed,
]);

void main() {
  appTest('a payment captured in the background offers its Room', (
    tester,
  ) async {
    final notifications = FakeNotifications();
    final db = await pumpApp(tester, notifications: notifications);
    await seedRoom(db, id: 'wedding', name: "Asha's wedding");
    await tester.pumpAndSettle();

    _toBackground(tester);
    await seedExpense(
      db,
      DateTime(2026, 11, 10, 9),
      2500,
      payee: 'Tanishq',
      reviewStatus: 'needsReview',
      origin: 'auto',
    );
    await tester.pumpAndSettle();

    expect(notifications.shown, ['room:₹2,500 at Tanishq']);
    expect(
      notifications.buttons['₹2,500 at Tanishq']!.single.label,
      "Add to Asha's wedding",
    );

    _toForeground(tester);
    notifications.tap('₹2,500 at Tanishq', actionId: 'room_0');
    await tester.pumpAndSettle();

    final rows = await db.select(db.transactions).get();
    expect(rows.single.roomId, 'wedding');
    expect(find.text("Asha's wedding"), findsWidgets);
  });

  appTest('nothing is offered while the app is open', (tester) async {
    final notifications = FakeNotifications();
    final db = await pumpApp(tester, notifications: notifications);
    _lifecycle(tester, const [AppLifecycleState.resumed]);
    await seedRoom(db, id: 'wedding', name: 'Wedding');
    await seedExpense(
      db,
      DateTime(2026, 11, 10, 9),
      2500,
      reviewStatus: 'needsReview',
      origin: 'auto',
    );
    await tester.pumpAndSettle();

    expect(notifications.shown, isEmpty);
  });
}
