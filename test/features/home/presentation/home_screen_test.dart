import 'package:expense_tracker/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home shows the empty state', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.text('Payments you make will show up here.'), findsOneWidget);
  });
}
