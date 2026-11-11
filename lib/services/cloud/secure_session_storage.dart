import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Keeps the Supabase login session in the Keystore or Keychain instead of
/// plain app preferences.
class SecureSessionStorage extends LocalStorage {
  /// Creates the storage.
  const new([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const String _key = 'supabase_session_v1';

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: _key);

  @override
  Future<String?> accessToken() => _storage.read(key: _key);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _key);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _key, value: persistSessionString);
}
