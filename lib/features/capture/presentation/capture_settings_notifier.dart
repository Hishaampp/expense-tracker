import 'package:expense_tracker/core/oem_guidance.dart';
import 'package:expense_tracker/services/native/capture_control_service.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// One app on the capture allowlist, and whether it is on.
typedef SourceToggle = ({String package, bool enabled});

/// What the Auto-capture screen shows.
@immutable
final class CaptureSettingsState {
  /// Creates the state.
  const new({
    required this.status,
    required this.now,
    required this.sources,
    required this.defaultSms,
  });

  /// The native status.
  final CaptureStatus status;

  /// Now, for "captured 2 hours ago".
  final DateTime now;

  /// The apps that can be read, on or off.
  final List<SourceToggle> sources;

  /// The phone's default SMS app, if known.
  final String? defaultSms;

  /// The phone maker's family, for battery steps.
  OemFamily get oem => oemFamilyFor(status.manufacturer);
}

/// The Auto-capture screen's view model (spec §6.2 capture health).
class CaptureSettingsNotifier extends AsyncNotifier<CaptureSettingsState> {
  @override
  Future<CaptureSettingsState> build() async {
    final control = ref.watch(captureControlProvider);
    final status = await control.status();
    var sources = const <SourceToggle>[];
    String? defaultSms;
    if (status.isAndroid) {
      final list = await control.sources();
      defaultSms = list.defaultSms;
      final all = <String>{...list.defaults, ?list.defaultSms, ...list.allowed};
      sources = [
        for (final package in all)
          (package: package, enabled: list.allowed.contains(package)),
      ];
    }
    return CaptureSettingsState(
      status: status,
      now: ref.read(clockProvider).now().toUtc(),
      sources: sources,
      defaultSms: defaultSms,
    );
  }

  /// Reads the status again (after returning from system settings). The
  /// Settings row reads it too, so that refreshes as well.
  void refresh() {
    ref
      ..invalidateSelf()
      ..invalidate(autoCaptureOnProvider);
  }

  /// Turns reading [package] on or off. Returns false if the phone refused.
  Future<bool> setSource(String package, {required bool enabled}) async {
    final current = state.value;
    if (current == null) return false;
    SourceToggle toggled(SourceToggle s) =>
        s.package == package ? (package: package, enabled: enabled) : s;
    final next = current.sources.map(toggled).toList();
    final ok = await _call(
      () => ref.read(captureControlProvider).setSources([
        for (final s in next)
          if (s.enabled) s.package,
      ]),
    );
    if (ok && ref.mounted) {
      state = AsyncData(
        CaptureSettingsState(
          status: current.status,
          now: current.now,
          sources: next,
          defaultSms: current.defaultSms,
        ),
      );
    }
    return ok;
  }

  /// Opens the system notification access screen.
  Future<bool> openAccess() =>
      _call(() => ref.read(captureControlProvider).openCaptureSettings());

  /// Opens the system battery settings.
  Future<bool> openBattery() =>
      _call(() => ref.read(captureControlProvider).openBatterySettings());

  /// Opens this app's system info page.
  Future<bool> openAppInfo() =>
      _call(() => ref.read(captureControlProvider).openAppSettings());

  /// Asks for SMS access.
  Future<bool> requestSms() =>
      _call(() => ref.read(captureControlProvider).requestSmsPermission());

  /// Imports bank SMS from the last [months] months; returns how many, or
  /// null if the phone refused.
  Future<int?> importHistory(int months) async {
    try {
      return await ref.read(captureControlProvider).importSmsHistory(months);
    } on PlatformException catch (e, st) {
      ref.read(appLoggerProvider).error('capture.import', e.runtimeType, st);
      return null;
    } on MissingPluginException catch (e, st) {
      ref.read(appLoggerProvider).error('capture.import', e.runtimeType, st);
      return null;
    }
  }

  // A platform call that may be refused; logs and reports false instead of
  // throwing into a fire-and-forget tap handler.
  Future<bool> _call(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } on PlatformException catch (e, st) {
      ref.read(appLoggerProvider).error('capture.control', e.runtimeType, st);
      return false;
    } on MissingPluginException catch (e, st) {
      ref.read(appLoggerProvider).error('capture.control', e.runtimeType, st);
      return false;
    }
  }
}

/// Provides [CaptureSettingsNotifier].
final AsyncNotifierProvider<CaptureSettingsNotifier, CaptureSettingsState>
captureSettingsNotifierProvider =
    AsyncNotifierProvider.autoDispose<
      CaptureSettingsNotifier,
      CaptureSettingsState
    >(CaptureSettingsNotifier.new);
