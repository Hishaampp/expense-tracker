import 'package:drift/drift.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/sync/sync_crypto.dart';
import 'package:meta/meta.dart';

/// A record pulled from the server, with the server's running number.
typedef PulledRecord = ({int seq, SealedRecord record});

/// The server side of sync (Phase 9). It stores sealed records it cannot
/// read: an opaque id, a change time and ciphertext, per user.
abstract interface class SyncServer {
  /// Stores [records], keeping per id only the one with the newest change
  /// time.
  Future<void> push(List<SealedRecord> records);

  /// Every record stored after the running number [after], oldest first.
  Future<List<PulledRecord>> pull(int after);
}

/// What one sync did.
typedef SyncReport = ({int pushed, int pulled, int applied});

/// Two-way sync of this phone's database through a [SyncServer] (Phase
/// 9). The phone's database stays the source of truth: changes made here
/// are queued by triggers (sync.drift) and uploaded sealed; changes from
/// other phones are applied when newer than what this phone has (the last
/// edit wins, per record). Message text never syncs.
class SyncEngine {
  /// Creates the engine.
  new(this._db, this._crypto, this._server);

  final AppDatabase _db;
  final SyncCrypto _crypto;
  final SyncServer _server;

  /// Synced tables and their key column, parents first. Must match the
  /// triggers in sync.drift.
  @visibleForTesting
  static const Map<String, String> tables = {
    'accounts': 'id',
    'categories': 'id',
    'rooms': 'id',
    'transactions': 'id',
    'budgets': 'id',
    'payee_rules': 'payee_key',
    'settings': 'key',
  };

  /// Settings that follow the user to another phone; the rest (app lock,
  /// onboarding, sync itself) belong to one phone.
  @visibleForTesting
  static const Set<String> syncedSettings = {
    'month_start_day',
    'watch_category',
  };

  static int _now() => DateTime.now().toUtc().millisecondsSinceEpoch;

  /// Whether sync is on for this phone.
  Future<bool> isEnabled() async => await _meta('enabled') != null;

  /// Turns sync on and queues every existing record for the first upload.
  Future<void> enable() => _db.transaction(() async {
    await _setMeta('enabled', 'yes');
    final now = _now();
    for (final MapEntry(key: table, value: column) in tables.entries) {
      final where = table == 'settings'
          ? ' WHERE "key" IN (${syncedSettings.map((k) => "'$k'").join(', ')})'
          : '';
      await _db.customStatement(
        'INSERT OR REPLACE INTO sync_outbox (record_table, record_key, '
        'changed_at) SELECT ?, "$column", ? FROM $table$where',
        [table, now],
      );
    }
  });

  /// Turns sync off and forgets its state on this phone. The phone keeps
  /// all its data.
  Future<void> disable() => _db.transaction(() async {
    await _db.customStatement('DELETE FROM sync_meta');
    await _db.customStatement('DELETE FROM sync_outbox');
    await _db.customStatement('DELETE FROM sync_state');
  });

  /// Uploads this phone's changes, then applies newer ones from the
  /// server.
  Future<SyncReport> sync() async {
    final pushed = await _push();
    final (pulled, applied) = await _pull();
    return (pushed: pushed, pulled: pulled, applied: applied);
  }

  Future<int> _push() async {
    final queued = await _db.select(_db.syncOutbox).get();
    if (queued.isEmpty) return 0;
    final sealed = <SealedRecord>[];
    for (final entry in queued) {
      final column = tables[entry.recordTable];
      if (column == null) continue;
      final rows = await _db
          .customSelect(
            'SELECT * FROM ${entry.recordTable} WHERE "$column" = ?',
            variables: [Variable(entry.recordKey)],
          )
          .get();
      sealed.add(
        await _crypto.seal((
          table: entry.recordTable,
          key: entry.recordKey,
          changedAt: entry.changedAt,
          row: rows.isEmpty ? null : rows.single.data,
        )),
      );
    }
    await _server.push(sealed);
    await _db.transaction(() async {
      for (final (i, entry) in queued.indexed) {
        // Only if not changed again while uploading.
        await _db.customStatement(
          'DELETE FROM sync_outbox WHERE record_table = ? AND record_key = ? '
          'AND changed_at = ?',
          [entry.recordTable, entry.recordKey, entry.changedAt],
        );
        await _remember(sealed[i].id, entry.changedAt);
      }
    });
    return sealed.length;
  }

  Future<(int, int)> _pull() async {
    final cursor = int.tryParse(await _meta('cursor') ?? '') ?? 0;
    final pulled = await _server.pull(cursor);
    if (pulled.isEmpty) return (0, 0);
    var applied = 0;
    final touched = <String>{};
    await _db.transaction(() async {
      // A transaction may arrive before its account; checked at commit.
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      await _setMeta('applying', 'yes');
      for (final item in pulled) {
        final payload = await _crypto.open(item.record);
        if (payload == null || !_allowed(payload)) continue;
        if (await _isNewer(item.record.id, payload)) {
          await _apply(payload);
          await _remember(item.record.id, payload.changedAt);
          touched.add(payload.table);
          applied++;
        }
      }
      await _db.customStatement("DELETE FROM sync_meta WHERE key = 'applying'");
      await _setMeta('cursor', '${pulled.last.seq}');
    });
    // Every screen showing these tables re-reads them.
    _db.notifyUpdates({
      for (final table in _db.allTables)
        if (touched.contains(table.actualTableName))
          TableUpdate.onTable(table, kind: UpdateKind.update),
    });
    return (pulled.length, applied);
  }

  // A record from the server names its table and columns; only known
  // tables and real columns are written, so a bad record cannot run SQL.
  bool _allowed(RecordPayload payload) {
    if (!tables.containsKey(payload.table)) return false;
    if (payload.table == 'settings' && !syncedSettings.contains(payload.key)) {
      return false;
    }
    return payload.row?.keys.every(_isIdentifier) ?? true;
  }

  static bool _isIdentifier(String name) =>
      RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(name);

  Future<bool> _isNewer(String recordId, RecordPayload payload) async {
    final known = await _db
        .customSelect(
          'SELECT max(coalesce((SELECT changed_at FROM sync_state '
          'WHERE record_id = ?), 0), coalesce((SELECT changed_at FROM '
          'sync_outbox WHERE record_table = ? AND record_key = ?), 0)) AS at',
          variables: [
            Variable(recordId),
            Variable(payload.table),
            Variable(payload.key),
          ],
        )
        .getSingle();
    return payload.changedAt > known.read<int>('at');
  }

  Future<void> _apply(RecordPayload payload) async {
    final column = tables[payload.table]!;
    final row = payload.row;
    // The newer remote version replaces any change still queued here.
    await _db.customStatement(
      'DELETE FROM sync_outbox WHERE record_table = ? AND record_key = ?',
      [payload.table, payload.key],
    );
    if (row == null) {
      await _db.customStatement(
        'DELETE FROM ${payload.table} WHERE "$column" = ?',
        [payload.key],
      );
      return;
    }
    final known = {
      for (final c
          in await _db
              .customSelect('PRAGMA table_info(${payload.table})')
              .get())
        c.read<String>('name'),
    };
    final columns = row.keys.where(known.contains).toList();
    final updates = [
      for (final c in columns)
        if (c != column) '"$c" = excluded."$c"',
    ];
    // An upsert, never a replace: replacing a parent would run its
    // ON DELETE rules on the children.
    await _db.customInsert(
      'INSERT INTO ${payload.table} '
      '(${columns.map((c) => '"$c"').join(', ')}) '
      'VALUES (${List.filled(columns.length, '?').join(', ')}) '
      'ON CONFLICT("$column") DO '
      '${updates.isEmpty ? 'NOTHING' : 'UPDATE SET ${updates.join(', ')}'}',
      variables: [for (final c in columns) Variable<Object>(row[c])],
    );
  }

  Future<void> _remember(String recordId, int changedAt) => _db.customStatement(
    'INSERT INTO sync_state (record_id, changed_at) VALUES (?, ?) '
    'ON CONFLICT(record_id) DO UPDATE SET changed_at = '
    'max(changed_at, excluded.changed_at)',
    [recordId, changedAt],
  );

  Future<String?> _meta(String key) async {
    final row = await (_db.select(
      _db.syncMeta,
    )..where((m) => m.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _setMeta(String key, String value) => _db
      .into(_db.syncMeta)
      .insertOnConflictUpdate(SyncMetaCompanion.insert(key: key, value: value));
}

/// A [SyncServer] held in memory, for tests and for two phones in one
/// test.
class MemorySyncServer implements SyncServer {
  final List<PulledRecord> _log = [];
  final Map<String, int> _newest = {};
  int _seq = 0;

  /// Every record as stored, for checking what the server can see.
  List<SealedRecord> get stored => [for (final p in _log) p.record];

  @override
  Future<void> push(List<SealedRecord> records) async {
    for (final record in records) {
      if ((_newest[record.id] ?? -1) >= record.changedAt) continue;
      _newest[record.id] = record.changedAt;
      _log
        ..removeWhere((p) => p.record.id == record.id)
        ..add((seq: ++_seq, record: record));
    }
  }

  @override
  Future<List<PulledRecord>> pull(int after) async => [
    for (final p in _log)
      if (p.seq > after) p,
  ];
}
