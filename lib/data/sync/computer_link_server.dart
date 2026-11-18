import 'package:expense_tracker/data/sync/computer_link.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A one-time sign-in for a computer, for this phone's own account.
typedef ComputerSignIn = ({String email, String tokenHash});

/// What the phone asks of the server to let a computer in
/// (supabase/migrations/20261117000000_link_computer.sql and
/// 20261119000000_phone_only_web_sign_in.sql).
abstract interface class ComputerLinkServer {
  /// A one-time sign-in for this phone's account, from the link-session
  /// function. Nothing is emailed.
  Future<ComputerSignIn> signIn();

  /// Leaves [sealed] for the request [id].
  Future<void> post(String id, SealedLink sealed);
}

/// [ComputerLinkServer] over the `link-session` function and the
/// `link_requests` table. Only the browser tab holding the request id can
/// collect the handover, for two minutes, and only it can open it.
class SupabaseComputerLinkServer implements ComputerLinkServer {
  /// Creates the server.
  new(this._client);

  final SupabaseClient _client;

  @override
  Future<ComputerSignIn> signIn() async {
    final response = await _client.functions.invoke('link-session');
    final data = response.data;
    if (data is! Map ||
        data['email'] is! String ||
        data['token_hash'] is! String) {
      throw const LinkSignInUnavailable();
    }
    return (
      email: data['email'] as String,
      tokenHash: data['token_hash'] as String,
    );
  }

  @override
  Future<void> post(String id, SealedLink sealed) =>
      _client.from('link_requests').insert({
        'id': id,
        'phone_key': sealed.phoneKey,
        'sealed': sealed.sealed,
      });
}

/// The server could not make a sign-in for a computer (the link-session
/// function is not deployed, or answered with something unexpected).
final class LinkSignInUnavailable implements Exception {
  /// Creates the error.
  const new();
}

/// [ComputerLinkServer] in memory, for tests.
class MemoryComputerLinkServer implements ComputerLinkServer {
  /// What was left, by request id.
  final Map<String, SealedLink> posted = {};

  /// Whether the next call fails as if offline.
  bool offline = false;

  /// The sign-in this fake hands out.
  ComputerSignIn pass = (email: 'asha@example.com', tokenHash: 'pkce_test');

  @override
  Future<ComputerSignIn> signIn() async {
    if (offline) throw const _Offline();
    return pass;
  }

  @override
  Future<void> post(String id, SealedLink sealed) async {
    if (offline) throw const _Offline();
    posted[id] = sealed;
  }
}

final class _Offline implements Exception {
  const new();
}
