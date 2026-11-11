import 'package:expense_tracker/services/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// The phone's own lock: Face ID, fingerprint or the device passcode
/// (spec §13). The app never sees the biometric or the passcode.
abstract interface class DeviceAuth {
  /// Whether the phone has a lock the app can ask for.
  Future<bool> isAvailable();

  /// Asks the user to unlock, explaining why with [reason]. Returns
  /// whether they did.
  Future<bool> unlock(String reason);
}

/// [DeviceAuth] over `local_auth`. Failures count as "not unlocked".
class LocalDeviceAuth implements DeviceAuth {
  /// Creates the service.
  new(this._log, [LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final AppLogger _log;
  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (e, st) {
      _log.error('auth.available', e.runtimeType, st);
      return false;
    }
  }

  @override
  Future<bool> unlock(String reason) async {
    try {
      // The passcode is allowed too, so a phone without a fingerprint
      // still locks.
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e, st) {
      _log.error('auth.unlock', e.runtimeType, st);
      return false;
    } on LocalAuthException catch (e, st) {
      _log.error('auth.unlock', e.runtimeType, st);
      return false;
    }
  }
}
