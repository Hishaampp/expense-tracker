import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The database encryption key, kept in the Android Keystore or the iOS
/// Keychain (spec §13). It never leaves the phone and is never logged.
class DatabaseKeyStore {
  /// Creates the store.
  const new([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const String _name = 'database_key_v1';

  /// The key as 64 hex digits, made on first use from 32 random bytes.
  Future<String> readOrCreate() async {
    final known = await _storage.read(key: _name);
    if (known != null && _isHexKey(known)) return known;
    final random = Random.secure();
    final key = [
      for (var i = 0; i < 32; i++)
        random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
    await _storage.write(key: _name, value: key);
    return key;
  }

  static bool _isHexKey(String value) =>
      RegExp(r'^[0-9a-f]{64}$').hasMatch(value);
}
