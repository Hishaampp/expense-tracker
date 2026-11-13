import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// A UPI app the payer can open.
typedef UpiApp = ({String id, String name});

/// Opens UPI apps for Scan & Record (Phase 11). The payment itself is made
/// with the UPI app's own scanner: UPI apps refuse or limit payments that
/// another app starts, so this app only opens them. It never handles money
/// or the UPI PIN. A seam; faked in tests.
abstract interface class UpiPayService {
  /// UPI apps on this phone.
  Future<List<UpiApp>> apps();

  /// Opens [app] and waits until the payer is back in this app. False
  /// when it could not be opened.
  Future<bool> open(UpiApp app);
}

// Opening returns at once; the payer is only done once back in this app.
Future<bool> _openAndWait(Future<bool> Function() opening) async {
  final back = Completer<void>();
  final listener = AppLifecycleListener(
    onResume: () {
      if (!back.isCompleted) back.complete();
    },
  );
  try {
    if (!await opening()) return false;
    await back.future;
    return true;
  } finally {
    listener.dispose();
  }
}

/// Android: any installed UPI app, through the `app/upi` channel.
class AndroidUpiPayService implements UpiPayService {
  /// Creates the service.
  const new([this._channel = const MethodChannel('app/upi')]);

  final MethodChannel _channel;

  @override
  Future<List<UpiApp>> apps() async {
    final list = await _channel.invokeListMethod<Map<Object?, Object?>>('apps');
    return [
      for (final m in list ?? const <Map<Object?, Object?>>[])
        if (m case {'id': final String id, 'name': final String name})
          (id: id, name: name),
    ];
  }

  @override
  Future<bool> open(UpiApp app) => _openAndWait(() async {
    try {
      return await _channel.invokeMethod<bool>('open', {'app': app.id}) ??
          false;
    } on PlatformException {
      return false;
    }
  });
}

/// iPhone: the well-known UPI apps, opened by their own link schemes.
class IosUpiPayService implements UpiPayService {
  /// Creates the service.
  const new();

  // App id, name, and the scheme that opens it.
  static const List<(String, String, String)> _known = [
    ('gpay', 'Google Pay', 'gpay://'),
    ('phonepe', 'PhonePe', 'phonepe://'),
    ('paytm', 'Paytm', 'paytmmp://'),
    ('bhim', 'BHIM', 'bhim://'),
  ];

  @override
  Future<List<UpiApp>> apps() async {
    final found = <UpiApp>[];
    for (final (id, name, scheme) in _known) {
      if (await canLaunchUrl(Uri.parse(scheme))) {
        found.add((id: id, name: name));
      }
    }
    return found;
  }

  @override
  Future<bool> open(UpiApp app) {
    final scheme = _known.where((k) => k.$1 == app.id).firstOrNull?.$3;
    if (scheme == null) return Future.value(false);
    return _openAndWait(
      () => launchUrl(Uri.parse(scheme), mode: LaunchMode.externalApplication),
    );
  }
}
