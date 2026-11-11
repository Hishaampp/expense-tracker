import 'dart:async';

import 'package:expense_tracker/core/cloud_config.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Why signing in did not work.
enum CloudAuthProblem {
  /// The code is wrong or expired.
  badCode,

  /// Too many tries; wait and try again.
  tooMany,

  /// No connection to the server.
  offline,
}

/// The optional account (Phase 9): sign in with a code sent by email, or
/// by tapping the link in that email on this phone. No password is ever
/// stored by the app.
abstract interface class CloudAuth {
  /// The signed-in email, or null. Live.
  Stream<String?> get email;

  /// The signed-in email now, or null.
  String? get currentEmail;

  /// Sends a sign-in code to [address]. Returns null, or what went wrong.
  Future<CloudAuthProblem?> sendCode(String address);

  /// Signs in with the [code] sent to [address]. Returns null, or what
  /// went wrong.
  Future<CloudAuthProblem?> verify(String address, String code);

  /// Signs out on this phone.
  Future<void> signOut();

  /// Deletes the account and every record on the server.
  Future<CloudAuthProblem?> deleteAccount();
}

/// [CloudAuth] over Supabase Auth.
class SupabaseCloudAuth implements CloudAuth {
  /// Creates the service.
  new(this._client, this._log);

  final SupabaseClient _client;
  final AppLogger _log;

  @override
  Stream<String?> get email async* {
    yield currentEmail;
    yield* _client.auth.onAuthStateChange.map((s) => s.session?.user.email);
  }

  @override
  String? get currentEmail => _client.auth.currentUser?.email;

  @override
  Future<CloudAuthProblem?> sendCode(String address) => _guard(
    'cloud.send_code',
    () => _client.auth.signInWithOtp(
      email: address.trim(),
      emailRedirectTo: CloudConfig.loginRedirect,
    ),
  );

  @override
  Future<CloudAuthProblem?> verify(String address, String code) => _guard(
    'cloud.verify',
    () => _client.auth.verifyOTP(
      email: address.trim(),
      token: code.trim(),
      type: OtpType.email,
    ),
  );

  @override
  Future<void> signOut() async {
    final _ = await _guard('cloud.sign_out', () => _client.auth.signOut());
  }

  @override
  Future<CloudAuthProblem?> deleteAccount() async {
    final problem = await _guard(
      'cloud.delete',
      () => _client.rpc<void>('delete_my_account'),
    );
    if (problem == null) await signOut();
    return problem;
  }

  Future<CloudAuthProblem?> _guard(
    String event,
    Future<Object?> Function() action,
  ) async {
    try {
      await action();
      return null;
    } on AuthException catch (e, st) {
      _log.error(event, e.runtimeType, st);
      return e.statusCode == '429'
          ? CloudAuthProblem.tooMany
          : CloudAuthProblem.badCode;
    } on PostgrestException catch (e, st) {
      _log.error(event, e.runtimeType, st);
      return CloudAuthProblem.offline;
    } on Exception catch (e, st) {
      // Socket and timeout errors come in many types; all mean offline.
      _log.error(event, e.runtimeType, st);
      return CloudAuthProblem.offline;
    }
  }
}
