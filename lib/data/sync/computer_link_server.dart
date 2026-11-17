import 'package:expense_tracker/data/sync/computer_link.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Where the phone leaves a sealed key for a computer to pick up
/// (supabase/migrations/20261117000000_link_computer.sql).
abstract interface class ComputerLinkServer {
  /// Leaves [sealed] for the request [id].
  Future<void> post(String id, SealedLink sealed);
}

/// [ComputerLinkServer] over the `link_requests` table. Row-level security
/// lets only this account's own computer read it, for two minutes.
class SupabaseComputerLinkServer implements ComputerLinkServer {
  /// Creates the server.
  new(this._client);

  final SupabaseClient _client;

  @override
  Future<void> post(String id, SealedLink sealed) =>
      _client.from('link_requests').insert({
        'id': id,
        'phone_key': sealed.phoneKey,
        'sealed': sealed.sealed,
      });
}

/// [ComputerLinkServer] in memory, for tests.
class MemoryComputerLinkServer implements ComputerLinkServer {
  /// What was left, by request id.
  final Map<String, SealedLink> posted = {};

  /// Whether the next post fails as if offline.
  bool offline = false;

  @override
  Future<void> post(String id, SealedLink sealed) async {
    if (offline) throw const _Offline();
    posted[id] = sealed;
  }
}

final class _Offline implements Exception {
  const new();
}
