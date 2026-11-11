import 'package:clock/clock.dart';
import 'package:expense_tracker/core/id_generator.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:expense_tracker/services/clipboard_service.dart';
import 'package:expense_tracker/services/device_auth.dart';
import 'package:expense_tracker/services/file_share.dart';
import 'package:expense_tracker/services/haptics.dart';
import 'package:expense_tracker/services/native/capture_control_service.dart';
import 'package:expense_tracker/services/native/capture_queue_service.dart';
import 'package:expense_tracker/services/notification_service.dart';
import 'package:expense_tracker/services/uuid_id_generator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The source of "now". Override with `Clock.fixed` in tests.
final clockProvider = Provider<Clock>((ref) => const Clock());

/// Makes ids for new records.
final idGeneratorProvider = Provider<IdGenerator>(
  (ref) => const UuidIdGenerator(),
);

/// Local-only diagnostics log.
final appLoggerProvider = Provider<AppLogger>((ref) => const DeveloperLogger());

/// Touch feedback. Override with a fake in tests.
final hapticsProvider = Provider<Haptics>((ref) => const SystemHaptics());

/// The clipboard. Override with a fake in tests.
final clipboardProvider = Provider<ClipboardService>(
  (ref) => const SystemClipboardService(),
);

/// The native capture queue. Override with a fake in tests.
final captureQueueProvider = Provider<CaptureQueueService>(
  (ref) => const MethodChannelCaptureQueue(),
);

/// Native auto-capture controls. Override with a fake in tests.
final captureControlProvider = Provider<CaptureControlService>(
  (ref) => const MethodChannelCaptureControl(),
);

/// Whether auto-capture is on, for the Settings row; null if unknown (iOS,
/// or the platform could not say).
final FutureProvider<bool?> autoCaptureOnProvider =
    FutureProvider.autoDispose<bool?>((ref) async {
      try {
        final status = await ref.watch(captureControlProvider).status();
        return status.isAndroid ? status.listenerEnabled : null;
      } on PlatformException {
        return null;
      } on MissingPluginException {
        return null;
      }
    });

/// Local notifications. Override with a fake in tests.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => LocalNotificationService(
    ref.watch(appLoggerProvider),
    ref.watch(clockProvider),
  ),
);

/// The phone's own lock, for the app lock. Override with a fake in tests.
final deviceAuthProvider = Provider<DeviceAuth>(
  (ref) => LocalDeviceAuth(ref.watch(appLoggerProvider)),
);

/// The share sheet and file picker. Override with a fake in tests.
final fileShareProvider = Provider<FileShare>((ref) => const SystemFileShare());
