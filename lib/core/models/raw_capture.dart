import 'package:meta/meta.dart';

/// Where captured text came from (spec §6.1).
enum CaptureSource {
  /// An Android notification (Phase 3).
  androidNotification('android_notification'),

  /// An SMS read directly (Android sideload build, Phase 3).
  androidSms('android_sms'),

  /// An iOS Shortcuts automation (Phase 4).
  iosShortcut('ios_shortcut'),

  /// Text shared into the app from another app.
  share('share'),

  /// Text pasted in Quick Add.
  paste('paste');

  new(this.wireName);

  /// The name used by the native queue and the database.
  final String wireName;

  /// The source called [wireName], or null for an unknown name.
  static CaptureSource? parse(String? wireName) {
    for (final source in values) {
      if (source.wireName == wireName) return source;
    }
    return null;
  }
}

/// Raw text received from a source, before parsing (spec §6.1).
@immutable
final class RawCapture {
  /// Creates a capture.
  const new({
    required this.id,
    required this.source,
    required this.text,
    required this.receivedAt,
    this.origin,
    this.title,
  });

  /// Unique id (from the native queue, or made by the app).
  final String id;

  /// Where it came from.
  final CaptureSource source;

  /// App package or SMS sender ID, if known.
  final String? origin;

  /// Notification title, if any.
  final String? title;

  /// The message text. Never logged.
  final String text;

  /// When it was received, as a UTC instant.
  final DateTime receivedAt;

  /// The de-duplication key: a hash of origin, text and the minute it was
  /// received (spec §6.1), as 16 hex digits.
  String get contentHash {
    final minute = receivedAt.toUtc().millisecondsSinceEpoch ~/ 60000;
    return fnv1a64('${origin ?? ''}\u0000$text\u0000$minute');
  }

  @override
  bool operator ==(Object other) =>
      other is RawCapture &&
      other.id == id &&
      other.source == source &&
      other.origin == origin &&
      other.title == title &&
      other.text == text &&
      other.receivedAt == receivedAt;

  @override
  int get hashCode => Object.hash(id, source, origin, title, text, receivedAt);
}

/// 64-bit FNV-1a hash of [input]'s UTF-16 code units, as 16 hex digits.
/// Stable across runs and platforms; not for security.
String fnv1a64(String input) {
  // Two 32-bit halves, so the arithmetic is exact on every platform.
  var hi = 0xcbf29ce4;
  var lo = 0x84222325;
  for (final unit in input.codeUnits) {
    lo ^= unit;
    // Multiply the 64-bit value by the FNV prime 0x100000001b3.
    final loMul = lo * 0x1b3;
    final carry = loMul ~/ 0x100000000;
    final newLo = loMul & 0xffffffff;
    final newHi = (hi * 0x1b3 + lo * 0x100 + carry) & 0xffffffff;
    hi = newHi;
    lo = newLo;
  }
  return hi.toRadixString(16).padLeft(8, '0') +
      lo.toRadixString(16).padLeft(8, '0');
}
