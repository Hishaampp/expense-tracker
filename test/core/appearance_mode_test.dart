import 'package:expense_tracker/core/models/appearance_mode.dart';
import 'package:test/test.dart';

void main() {
  test('a new user, who has not chosen yet, starts in dark', () {
    expect(AppearanceMode.parse(null), AppearanceMode.dark);
    expect(AppearanceMode.parse('nonsense'), AppearanceMode.dark);
  });

  test('a saved choice is kept', () {
    expect(AppearanceMode.parse('light'), AppearanceMode.light);
    expect(AppearanceMode.parse('system'), AppearanceMode.system);
  });
}
