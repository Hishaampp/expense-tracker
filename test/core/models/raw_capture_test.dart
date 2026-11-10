import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:test/test.dart';

void main() {
  RawCapture capture(String text, DateTime at, {String? origin}) => RawCapture(
    id: 'x',
    source: CaptureSource.paste,
    text: text,
    receivedAt: at,
    origin: origin,
  );

  test('the content hash is stable and 16 hex digits', () {
    expect(fnv1a64(''), 'cbf29ce484222325');
    expect(fnv1a64('a'), 'af63dc4c8601ec8c');
    expect(fnv1a64('foobar'), '85944171f73967e8');
  });

  test('same text in the same minute has the same hash', () {
    final a = capture('Rs 5 debited', DateTime.utc(2026, 11, 10, 9, 14, 1));
    final b = capture('Rs 5 debited', DateTime.utc(2026, 11, 10, 9, 14, 59));
    expect(a.contentHash, b.contentHash);
  });

  test('a different minute, text or origin changes the hash', () {
    final at = DateTime.utc(2026, 11, 10, 9, 14);
    final base = capture('Rs 5 debited', at).contentHash;
    expect(
      capture('Rs 5 debited', at.add(const Duration(minutes: 1))).contentHash,
      isNot(base),
    );
    expect(capture('Rs 6 debited', at).contentHash, isNot(base));
    expect(
      capture('Rs 5 debited', at, origin: 'AX-HDFCBK').contentHash,
      isNot(base),
    );
  });

  test('wire names round-trip', () {
    for (final source in CaptureSource.values) {
      expect(CaptureSource.parse(source.wireName), source);
    }
    expect(CaptureSource.parse('nope'), isNull);
  });
}
