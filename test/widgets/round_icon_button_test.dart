import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Offset> _iconCentre(WidgetTester tester, int count) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(Brightness.light),
      home: Scaffold(
        body: Center(
          child: RoundIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            floating: false,
            badgeCount: count,
            onPressed: () {},
          ),
        ),
      ),
    ),
  );
  final button = tester.getCenter(find.byType(RoundIconButton));
  return tester.getCenter(find.byType(Icon)) - button;
}

void main() {
  testWidgets('the icon stays centred when a count badge shows', (
    tester,
  ) async {
    final plain = await _iconCentre(tester, 0);
    final counted = await _iconCentre(tester, 1);
    expect(plain, Offset.zero);
    expect(counted, Offset.zero);
    expect(find.text('1'), findsOneWidget);
  });
}
