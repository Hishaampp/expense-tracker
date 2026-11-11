import 'dart:convert';

import 'package:expense_tracker/data/sync/sync_crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the sync key in the Keystore or Keychain (Phase 9).
abstract interface class SyncKeyStore {
  /// The key, or null when this phone has none.
  Future<SyncKey?> read();

  /// Saves [key].
  Future<void> write(SyncKey key);

  /// Forgets the key (on sign-out).
  Future<void> delete();
}

/// [SyncKeyStore] over `flutter_secure_storage`.
class SecureSyncKeyStore implements SyncKeyStore {
  /// Creates the store.
  const new([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const String _name = 'sync_key_v1';

  @override
  Future<SyncKey?> read() async {
    final value = await _storage.read(key: _name);
    if (value == null) return null;
    return SyncKey.fromBytes(base64.decode(value));
  }

  @override
  Future<void> write(SyncKey key) =>
      _storage.write(key: _name, value: base64.encode(key.bytes));

  @override
  Future<void> delete() => _storage.delete(key: _name);
}
