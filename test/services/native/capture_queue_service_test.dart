import 'dart:convert';

import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/services/native/capture_queue_service.dart';
import 'package:test/test.dart';

void main() {
  test('reads a capture in the native contract (spec §6.1)', () {
    final capture = decodeRawCapture(
      jsonEncode({
        'id': 'abc',
        'source': 'share',
        'origin': null,
        'title': null,
        'text': 'Rs 5 debited',
        'receivedAt': 1762765800000,
      }),
    );
    expect(capture, isNotNull);
    expect(capture!.source, CaptureSource.share);
    expect(capture.text, 'Rs 5 debited');
    expect(capture.receivedAt, DateTime.utc(2025, 11, 10, 9, 10));
  });

  test('a broken line is skipped, not fatal', () {
    expect(decodeRawCapture('not json'), isNull);
    expect(decodeRawCapture('[]'), isNull);
    expect(decodeRawCapture(jsonEncode({'id': 'x'})), isNull);
    expect(
      decodeRawCapture(
        jsonEncode({
          'id': 'x',
          'source': 'carrier-pigeon',
          'text': 't',
          'receivedAt': 1,
        }),
      ),
      isNull,
    );
  });
}
