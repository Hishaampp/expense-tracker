/// How long without a Shortcuts capture before Home warns (spec §6.3).
const Duration captureQuietLimit = Duration(days: 5);

/// Whether iPhone auto-capture may have stopped: it was set up more than
/// five days ago and nothing has arrived for five days. Never before setup.
bool captureMayBeOff({
  required DateTime? setupAt,
  required DateTime? lastCaptureAt,
  required DateTime now,
}) {
  if (setupAt == null) return false;
  if (now.difference(setupAt) < captureQuietLimit) return false;
  return lastCaptureAt == null ||
      now.difference(lastCaptureAt) >= captureQuietLimit;
}
