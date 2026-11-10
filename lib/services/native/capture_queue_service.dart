import 'dart:convert';

import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:flutter/services.dart';

/// The native capture queue (spec §6.1): drain what is waiting, then ack
/// what was handled. Delivery is at-least-once; callers de-duplicate.
abstract interface class CaptureQueueService {
  /// Captures waiting in the native queue, oldest first. Not removed yet.
  Future<List<RawCapture>> drain();

  /// Removes the captures with [ids] from the native queue.
  Future<void> ack(List<String> ids);

  /// Fires when something may have been queued (a share arrived, or the
  /// app came back to the foreground).
  Stream<void> get changes;
}

/// Talks to the native queue over `app/capture` and `app/capture/events`.
final class MethodChannelCaptureQueue implements CaptureQueueService {
  /// Creates the service.
  const new();

  static const MethodChannel _methods = MethodChannel('app/capture');
  static const EventChannel _events = EventChannel('app/capture/events');

  @override
  Future<List<RawCapture>> drain() async {
    final lines =
        await _methods.invokeListMethod<String>('drainQueue') ?? const [];
    return [for (final line in lines) ?decodeRawCapture(line)];
  }

  @override
  Future<void> ack(List<String> ids) async {
    if (ids.isEmpty) return;
    await _methods.invokeMethod<void>('ack', {'ids': ids});
  }

  @override
  Stream<void> get changes => _events.receiveBroadcastStream().map((_) {});
}

/// Reads one queued capture from its JSON line (spec §6.1). Returns null
/// for a line that is not a valid capture, so one bad line cannot block
/// the queue.
RawCapture? decodeRawCapture(String line) {
  final Object? decoded;
  try {
    decoded = jsonDecode(line);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, Object?>) return null;
  final id = decoded['id'];
  final text = decoded['text'];
  final receivedAt = decoded['receivedAt'];
  final source = CaptureSource.parse(decoded['source'] as String?);
  if (id is! String || text is! String || receivedAt is! int) return null;
  if (source == null) return null;
  final origin = decoded['origin'];
  final title = decoded['title'];
  return RawCapture(
    id: id,
    source: source,
    text: text,
    origin: origin is String ? origin : null,
    title: title is String ? title : null,
    receivedAt: DateTime.fromMillisecondsSinceEpoch(receivedAt, isUtc: true),
  );
}
