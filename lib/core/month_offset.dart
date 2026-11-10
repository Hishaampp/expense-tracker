import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How many months back from the current one a screen is showing: 0 for the
/// current month, negative for earlier ones. Never positive.
class MonthOffsetNotifier extends Notifier<int> {
  /// How far back the month picker reaches.
  static const int pickerMonths = 12;

  @override
  int build() => 0;

  /// Shows the month [offset] months back (clamped to the picker's range).
  void set(int offset) => state = offset.clamp(1 - pickerMonths, 0);
}
