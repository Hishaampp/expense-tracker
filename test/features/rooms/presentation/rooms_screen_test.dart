import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  appTest('Rooms says what Rooms are and that they are coming', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Rooms');

    expect(find.text('Trips and events, together'), findsOneWidget);
  });
}
