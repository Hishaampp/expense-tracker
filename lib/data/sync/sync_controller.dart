import 'dart:async';

import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/sync/supabase_sync_server.dart';
import 'package:expense_tracker/data/sync/sync_crypto.dart';
import 'package:expense_tracker/data/sync/sync_engine.dart';
import 'package:expense_tracker/services/cloud/cloud_auth.dart';
import 'package:expense_tracker/services/cloud/sync_key_store.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Where the optional account and sync stand (Phase 9).
sealed class SyncStatus {
  const new();
}

/// No account on this phone. The app works as before.
final class SyncSignedOut extends SyncStatus {
  /// Creates the status.
  const new();
}

/// Signed in on a phone without the sync key, and the account already
/// has data: the recovery code is needed to read it.
final class SyncNeedsCode extends SyncStatus {
  /// Creates the status for [email].
  const new(this.email);

  /// The account.
  final String email;
}

/// Sync was just set up: the user must write down [recoveryCode] now.
final class SyncNewKey extends SyncStatus {
  /// Creates the status.
  const new(this.email, this.recoveryCode);

  /// The account.
  final String email;

  /// The code to write down.
  final String recoveryCode;
}

/// Syncing.
@immutable
final class SyncOn extends SyncStatus {
  /// Creates the status.
  const new(this.email, {this.lastSynced, this.offline = false});

  /// The account.
  final String email;

  /// When the last sync finished, or null before the first.
  final DateTime? lastSynced;

  /// Whether the last try could not reach the server.
  final bool offline;
}

/// The account and sync's view model (Phase 9).
class SyncController extends AsyncNotifier<SyncStatus> {
  bool _syncing = false;

  CloudAuth get _auth => ref.read(cloudAuthProvider);
  SyncKeyStore get _keys => ref.read(syncKeyStoreProvider);
  SyncServer get _server => ref.read(syncServerProvider);

  SyncEngine _engine(SyncKey key) =>
      SyncEngine(ref.read(appDatabaseProvider), SyncCrypto(key), _server);

  @override
  Future<SyncStatus> build() async {
    // Signing in by tapping the email link happens outside this screen's
    // buttons: Supabase reads the link and signs in, and this picks it up.
    final sub = _auth.email.listen((email) {
      if (email != null && state.value is SyncSignedOut) {
        unawaited(_afterSignIn(email));
      }
    });
    ref.onDispose(sub.cancel);
    final email = _auth.currentEmail;
    if (email == null) return const SyncSignedOut();
    final key = await _keys.read();
    return key == null ? SyncNeedsCode(email) : SyncOn(email);
  }

  /// Opens [provider]'s sign-in page; the result arrives through the
  /// account's email stream.
  Future<CloudAuthProblem?> signInWith(CloudProvider provider) =>
      _auth.signInWith(provider);

  /// Sends a sign-in code to [email].
  Future<CloudAuthProblem?> sendCode(String email) => _auth.sendCode(email);

  /// Signs in with [code], then sets up or joins sync.
  Future<CloudAuthProblem?> verify(String email, String code) async {
    final problem = await _auth.verify(email, code);
    if (problem != null) return problem;
    return await _afterSignIn(_auth.currentEmail ?? email);
  }

  bool _settingUp = false;

  /// Sets up or joins sync once signed in, by code or by link.
  Future<CloudAuthProblem?> _afterSignIn(String signedIn) async {
    if (_settingUp) return null;
    _settingUp = true;
    try {
      return await _setUp(signedIn);
    } finally {
      _settingUp = false;
    }
  }

  Future<CloudAuthProblem?> _setUp(String signedIn) async {
    final key = await _keys.read();
    if (key != null) {
      await _start(signedIn, key);
      return null;
    }
    try {
      final existing = await _server.pull(0);
      if (existing.isNotEmpty) {
        state = AsyncData(SyncNeedsCode(signedIn));
        return null;
      }
    } on Exception {
      return CloudAuthProblem.offline;
    }
    final fresh = SyncKey.generate();
    await _keys.write(fresh);
    await _start(signedIn, fresh);
    state = AsyncData(SyncNewKey(signedIn, fresh.recoveryCode));
    return null;
  }

  /// Joins sync with the recovery [code] from the first phone. Returns
  /// false when the code is mistyped or belongs to another account.
  Future<bool> enterCode(String code) async {
    final current = state.value;
    if (current is! SyncNeedsCode) return false;
    final key = SyncKey.fromRecoveryCode(code);
    if (key == null) return false;
    final records = await _server.pull(0);
    if (records.isNotEmpty &&
        await SyncCrypto(key).open(records.first.record) == null) {
      return false;
    }
    await _keys.write(key);
    await _start(current.email, key);
    return true;
  }

  /// The recovery code has been written down.
  void confirmCodeSaved() {
    if (state.value case SyncNewKey(:final email)) {
      state = AsyncData(
        SyncOn(email, lastSynced: ref.read(clockProvider).now()),
      );
    }
  }

  /// The recovery code, to show again (after the phone lock).
  Future<String?> recoveryCode() async => (await _keys.read())?.recoveryCode;

  /// Syncs now, if on. Never throws: an unreachable server only marks the
  /// status offline.
  Future<void> syncNow() async {
    final current = state.value;
    if (current is! SyncOn || _syncing) return;
    final key = await _keys.read();
    if (key == null) return;
    _syncing = true;
    try {
      await _engine(key).sync();
      state = AsyncData(
        SyncOn(current.email, lastSynced: ref.read(clockProvider).now()),
      );
    } on Exception catch (e, st) {
      ref.read(appLoggerProvider).error('sync.run', e.runtimeType, st);
      state = AsyncData(
        SyncOn(current.email, lastSynced: current.lastSynced, offline: true),
      );
    } finally {
      _syncing = false;
    }
  }

  /// Signs out and stops sync on this phone. Its data stays.
  Future<void> signOut() async {
    if (await _keys.read() case final key?) await _engine(key).disable();
    await _keys.delete();
    await _auth.signOut();
    state = const AsyncData(SyncSignedOut());
  }

  /// Deletes the account and its cloud copy. This phone's data stays.
  Future<CloudAuthProblem?> deleteAccount() async {
    final problem = await _auth.deleteAccount();
    if (problem != null) return problem;
    if (await _keys.read() case final key?) await _engine(key).disable();
    await _keys.delete();
    state = const AsyncData(SyncSignedOut());
    return null;
  }

  Future<void> _start(String email, SyncKey key) async {
    final engine = _engine(key);
    if (!await engine.isEnabled()) await engine.enable();
    state = AsyncData(SyncOn(email));
    await syncNow();
  }
}

/// Provides [SyncController].
final AsyncNotifierProvider<SyncController, SyncStatus> syncControllerProvider =
    AsyncNotifierProvider<SyncController, SyncStatus>(SyncController.new);

/// The sign-in providers turned on in the project. Apple is offered on
/// iPhone only.
final cloudProvidersProvider = FutureProvider<List<CloudProvider>>((ref) async {
  final on = await ref.watch(cloudAuthProvider).providers();
  final ios = defaultTargetPlatform == TargetPlatform.iOS;
  return [
    if (ios && on.contains(CloudProvider.apple)) CloudProvider.apple,
    if (on.contains(CloudProvider.google)) CloudProvider.google,
  ];
});

/// The account service. Override with a fake in tests.
final cloudAuthProvider = Provider<CloudAuth>(
  (ref) =>
      SupabaseCloudAuth(Supabase.instance.client, ref.watch(appLoggerProvider)),
);

/// Where the sync key is kept. Override with a fake in tests.
final syncKeyStoreProvider = Provider<SyncKeyStore>(
  (ref) => const SecureSyncKeyStore(),
);

/// The sync server. Override with a [MemorySyncServer] in tests.
final syncServerProvider = Provider<SyncServer>(
  (ref) => SupabaseSyncServer(Supabase.instance.client),
);
