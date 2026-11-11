import 'package:expense_tracker/data/sync/sync_crypto.dart';
import 'package:expense_tracker/data/sync/sync_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [SyncServer] over the project's `sync_records` table and its
/// `push_records` function (supabase/migrations). Row-level security keeps
/// each user to their own rows; the rows are ciphertext either way.
class SupabaseSyncServer implements SyncServer {
  /// Creates the server.
  new(this._client);

  final SupabaseClient _client;

  static const int _page = 500;

  @override
  Future<void> push(List<SealedRecord> records) async {
    for (var i = 0; i < records.length; i += _page) {
      final chunk = records.skip(i).take(_page);
      await _client.rpc<void>(
        'push_records',
        params: {
          'records': [
            for (final r in chunk)
              {'id': r.id, 'changed_at': r.changedAt, 'blob': r.blob},
          ],
        },
      );
    }
  }

  @override
  Future<List<PulledRecord>> pull(int after) async {
    final out = <PulledRecord>[];
    var cursor = after;
    while (true) {
      final rows = await _client
          .from('sync_records')
          .select('seq, id, changed_at, blob')
          .gt('seq', cursor)
          .order('seq')
          .limit(_page);
      for (final row in rows) {
        out.add((
          seq: row['seq'] as int,
          record: (
            id: row['id'] as String,
            changedAt: row['changed_at'] as int,
            blob: row['blob'] as String,
          ),
        ));
      }
      if (rows.length < _page) return out;
      cursor = out.last.seq;
    }
  }
}
