import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a web page (the privacy policy, the terms) in the phone's browser.
/// Opening a page is not network access by the app: the browser loads it.
abstract interface class WebLinkService {
  /// Opens [url]; false when no browser could open it.
  Future<bool> open(Uri url);
}

/// [WebLinkService] over url_launcher, in the default browser.
class BrowserWebLinkService implements WebLinkService {
  /// Creates the service.
  const new();

  @override
  Future<bool> open(Uri url) async {
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }
}

/// The web link service. Override with a fake in tests.
final webLinkServiceProvider = Provider<WebLinkService>(
  (ref) => const BrowserWebLinkService(),
);
