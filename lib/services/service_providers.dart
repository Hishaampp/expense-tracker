import 'package:clock/clock.dart';
import 'package:expense_tracker/core/id_generator.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:expense_tracker/services/clipboard_service.dart';
import 'package:expense_tracker/services/haptics.dart';
import 'package:expense_tracker/services/uuid_id_generator.dart';
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
