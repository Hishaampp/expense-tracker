import 'package:expense_tracker/core/capture_health.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime.utc(2026, 11, 20);
  DateTime ago(int days) => now.subtract(Duration(days: days));

  test('never before setup', () {
    expect(
      captureMayBeOff(setupAt: null, lastCaptureAt: null, now: now),
      isFalse,
    );
  });

  test('not in the first five days after setup', () {
    expect(
      captureMayBeOff(setupAt: ago(3), lastCaptureAt: null, now: now),
      isFalse,
    );
  });

  test('on when nothing arrived for five days', () {
    expect(
      captureMayBeOff(setupAt: ago(9), lastCaptureAt: null, now: now),
      isTrue,
    );
    expect(
      captureMayBeOff(setupAt: ago(9), lastCaptureAt: ago(5), now: now),
      isTrue,
    );
  });

  test('off while messages keep arriving', () {
    expect(
      captureMayBeOff(setupAt: ago(30), lastCaptureAt: ago(1), now: now),
      isFalse,
    );
  });
}
