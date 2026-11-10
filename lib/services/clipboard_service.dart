import 'package:flutter/services.dart';

/// Reads plain text from the clipboard. A seam, so tests need no platform.
abstract interface class ClipboardService {
  /// The clipboard's text, or null when it holds none.
  Future<String?> readText();
}

/// Reads the platform clipboard.
final class SystemClipboardService implements ClipboardService {
  /// Creates the service.
  const new();

  @override
  Future<String?> readText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
