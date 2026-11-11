import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Auto-capture status from the native side (spec §6.1 `status()`).
@immutable
final class CaptureStatus {
  /// Creates the status.
  const new({
    required this.platform,
    required this.listenerEnabled,
    required this.smsSupported,
    required this.smsPermission,
    required this.queueSize,
    this.lastCaptureAt,
    this.manufacturer,
  });

  /// `android` or `ios`.
  final String platform;

  /// Whether notification access is granted (Android).
  final bool listenerEnabled;

  /// Whether this build can read SMS (Android sideload).
  final bool smsSupported;

  /// Whether SMS access is granted.
  final bool smsPermission;

  /// Captures waiting to be read.
  final int queueSize;

  /// When the last capture arrived, if ever.
  final DateTime? lastCaptureAt;

  /// The phone maker (Android `Build.MANUFACTURER`).
  final String? manufacturer;

  /// Whether this is an Android phone.
  bool get isAndroid => platform == 'android';
}

/// Apps whose notifications may be read.
typedef CaptureSourceList = ({
  List<String> allowed,
  List<String> defaults,
  String? defaultSms,
});

/// Controls automatic capture on the device. A seam; faked in tests.
abstract interface class CaptureControlService {
  /// The current status.
  Future<CaptureStatus> status();

  /// Opens the system screen that grants notification access (Android).
  Future<void> openCaptureSettings();

  /// Opens the system battery optimisation settings (Android).
  Future<void> openBatterySettings();

  /// Opens this app's system info page ("Allow restricted settings").
  Future<void> openAppSettings();

  /// The apps whose notifications may be read.
  Future<CaptureSourceList> sources();

  /// Saves the apps whose notifications may be read.
  Future<void> setSources(List<String> packages);

  /// Asks for SMS access (sideload build).
  Future<void> requestSmsPermission();

  /// Queues bank SMS from the last [months] months; returns how many.
  Future<int> importSmsHistory(int months);
}

/// Talks to the native side over `app/capture`.
final class MethodChannelCaptureControl implements CaptureControlService {
  /// Creates the service.
  const new();

  static const MethodChannel _channel = MethodChannel('app/capture');

  @override
  Future<CaptureStatus> status() async {
    final map =
        await _channel.invokeMapMethod<String, Object?>('status') ?? const {};
    final last = map['lastCaptureAt'];
    return CaptureStatus(
      platform: map['platform'] as String? ?? 'unknown',
      listenerEnabled: map['listenerEnabled'] as bool? ?? false,
      smsSupported: map['smsSupported'] as bool? ?? false,
      smsPermission: map['smsPermission'] as bool? ?? false,
      queueSize: map['queueSize'] as int? ?? 0,
      lastCaptureAt: last is int
          ? DateTime.fromMillisecondsSinceEpoch(last, isUtc: true)
          : null,
      manufacturer: map['manufacturer'] as String?,
    );
  }

  @override
  Future<void> openCaptureSettings() =>
      _channel.invokeMethod<void>('openCaptureSettings');

  @override
  Future<void> openBatterySettings() =>
      _channel.invokeMethod<void>('openBatterySettings');

  @override
  Future<void> openAppSettings() =>
      _channel.invokeMethod<void>('openAppSettings');

  @override
  Future<CaptureSourceList> sources() async {
    final map =
        await _channel.invokeMapMethod<String, Object?>('getSources') ??
        const {};
    List<String> list(Object? value) =>
        value is List ? value.whereType<String>().toList() : const [];
    return (
      allowed: list(map['allowed']),
      defaults: list(map['defaults']),
      defaultSms: map['defaultSms'] as String?,
    );
  }

  @override
  Future<void> setSources(List<String> packages) =>
      _channel.invokeMethod<void>('setSources', {'packages': packages});

  @override
  Future<void> requestSmsPermission() =>
      _channel.invokeMethod<void>('requestSmsPermission');

  @override
  Future<int> importSmsHistory(int months) async =>
      await _channel.invokeMethod<int>('importSmsHistory', {
        'months': months,
      }) ??
      0;
}
