/// How long the app may stay in the background before it locks again
/// (spec §13).
const Duration appLockGrace = Duration(minutes: 5);

/// Where the app lock stands, for what is drawn above it (the intro).
enum LockStatus {
  /// No lock, or unlocked.
  open,

  /// Face ID, fingerprint or the passcode is being asked for.
  asking,

  /// Locked and not asking: the lock screen shows its Unlock button.
  locked,
}
