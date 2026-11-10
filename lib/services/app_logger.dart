import 'dart:developer' as developer;

/// Local-only diagnostics. Never pass message text, amounts, account
/// numbers, UPI ids or reference numbers (spec §0): only an event name and
/// the error's type are recorded.
// A seam with one method by design, so tests can capture events.
abstract interface class AppLogger {
  /// Records that [event] failed with an error of type [errorType].
  void error(String event, Type errorType, StackTrace stackTrace);
}

/// Writes to the developer log, which stays on the device.
final class DeveloperLogger implements AppLogger {
  /// Creates the logger.
  const new();

  @override
  void error(String event, Type errorType, StackTrace stackTrace) {
    developer.log(
      '$event: $errorType',
      name: 'app',
      level: 1000,
      stackTrace: stackTrace,
    );
  }
}
