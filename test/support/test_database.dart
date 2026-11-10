import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:expense_tracker/core/id_generator.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/services/app_logger.dart';

/// A fresh in-memory database, seeded like a new install.
AppDatabase openTestDatabase({Clock clock = const Clock()}) {
  return AppDatabase(NativeDatabase.memory(), clock: clock);
}

/// Ids `id-1`, `id-2`, … in order.
final class SequentialIds implements IdGenerator {
  int _next = 0;

  @override
  String newId() => 'id-${++_next}';
}

/// Records logged events instead of printing them.
final class RecordingLogger implements AppLogger {
  /// Event names logged so far.
  final List<String> events = [];

  @override
  void error(String event, Type errorType, StackTrace stackTrace) {
    events.add(event);
  }
}
