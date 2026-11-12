import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// A UPI app that can take a payment link.
typedef UpiApp = ({String id, String name});

/// How a payment ended, as far as this app can tell (Phase 11).
enum UpiOutcome {
  /// The UPI app reported success (Android).
  success,

  /// The UPI app reported a failure or the payer backed out (Android).
  failure,

  /// The UPI app reported it pending (Android).
  pending,

  /// No answer: always on iPhone, and when an Android app gives none.
  unknown,
}

/// What a payment attempt returned: the outcome and, when given, the
/// UPI reference number.
typedef UpiResult = ({UpiOutcome outcome, String? refNo});

/// Reads a UPI app's answer, such as `Status=SUCCESS&txnRef=…&ApprovalRefNo=…`
/// (Android). Null or unreadable is [UpiOutcome.unknown].
UpiResult parseUpiResponse(String? response) {
  if (response == null || response.trim().isEmpty) {
    return (outcome: UpiOutcome.unknown, refNo: null);
  }
  final fields = <String, String>{};
  for (final part in response.split('&')) {
    final at = part.indexOf('=');
    if (at <= 0) continue;
    fields[part.substring(0, at).trim().toLowerCase()] = Uri.decodeComponent(
      part.substring(at + 1).trim(),
    );
  }
  final status = fields['status']?.toUpperCase();
  final ref = [fields['approvalrefno'], fields['txnref'], fields['txnid']]
      .whereType<String>()
      .where((v) => v.isNotEmpty && v.toLowerCase() != 'null')
      .firstOrNull;
  final outcome = switch (status) {
    'SUCCESS' => UpiOutcome.success,
    'FAILURE' || 'FAILED' => UpiOutcome.failure,
    'SUBMITTED' || 'PENDING' => UpiOutcome.pending,
    _ => UpiOutcome.unknown,
  };
  return (outcome: outcome, refNo: ref);
}

/// Opens UPI apps with a payment link (Phase 11). This app never handles
/// money or the UPI PIN. A seam; faked in tests.
abstract interface class UpiPayService {
  /// Installed UPI apps.
  Future<List<UpiApp>> apps();

  /// Opens [app] with [link] (a `upi://pay` link) and waits for the
  /// payer to come back. Null when the app could not be opened.
  Future<UpiResult?> pay(UpiApp app, Uri link);
}

/// Android: any installed UPI app, through the `app/upi` channel; the app
/// reports how the payment ended.
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
  Future<UpiResult?> pay(UpiApp app, Uri link) async {
    try {
      final response = await _channel.invokeMethod<String>('pay', {
        'uri': link.toString(),
        'app': app.id,
      });
      return parseUpiResponse(response);
    } on PlatformException {
      return null;
    }
  }
}

/// iPhone: the well-known UPI apps by their own link schemes. Apple gives
/// no answer back, so the outcome is always [UpiOutcome.unknown] and the
/// payer is asked.
class IosUpiPayService implements UpiPayService {
  /// Creates the service.
  const new();

  // App id, name, and the link prefix that replaces `upi://pay`.
  static const List<(String, String, String)> _known = [
    ('gpay', 'Google Pay', 'gpay://upi/pay'),
    ('phonepe', 'PhonePe', 'phonepe://pay'),
    ('paytm', 'Paytm', 'paytmmp://pay'),
    ('bhim', 'BHIM', 'bhim://upi/pay'),
  ];

  static Uri _linkFor(String prefix, Uri link) =>
      Uri.parse('$prefix?${link.query}');

  @override
  Future<List<UpiApp>> apps() async {
    final found = <UpiApp>[];
    for (final (id, name, prefix) in _known) {
      if (await canLaunchUrl(Uri.parse('$prefix?pa=x@y'))) {
        found.add((id: id, name: name));
      }
    }
    return found;
  }

  @override
  Future<UpiResult?> pay(UpiApp app, Uri link) async {
    final prefix = _known.where((k) => k.$1 == app.id).firstOrNull?.$3;
    if (prefix == null) return null;
    // Opening returns at once; the answer only makes sense once the payer
    // is back in this app.
    final back = Completer<void>();
    final listener = AppLifecycleListener(
      onResume: () {
        if (!back.isCompleted) back.complete();
      },
    );
    try {
      final opened = await launchUrl(
        _linkFor(prefix, link),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) return null;
      await back.future;
      return (outcome: UpiOutcome.unknown, refNo: null);
    } finally {
      listener.dispose();
    }
  }
}
