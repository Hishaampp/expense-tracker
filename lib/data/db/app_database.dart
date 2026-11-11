import 'dart:io';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/notice.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/data/db/app_database.steps.dart';
import 'package:expense_tracker/data/db/seed.dart';
import 'package:expense_tracker/data/db/tables.dart';
import 'package:sqlite3/common.dart';

part 'app_database.g.dart';

/// The on-device database: the single source of truth (spec §5.1).
@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Rooms,
    Transactions,
    Settings,
    RawCaptures,
    TransactionSources,
    UnparsedMessages,
    Budgets,
    FiredAlerts,
    Notices,
    PayeeRules,
    SyncMeta,
    SyncOutbox,
    SyncState,
  ],
  include: {'sync.drift'},
)
class AppDatabase extends _$AppDatabase {
  /// Opens the database on the executor `e`; `clock` stamps seeded rows.
  new(super.e, {this._clock = const Clock()});

  /// Opens the app's database file at [path] in app-private storage,
  /// encrypted with [hexKey] (spec §13). A database from before encryption
  /// ([wasPlain]) is encrypted in place on this first open.
  factory open({
    required String path,
    required String hexKey,
    required bool wasPlain,
    Clock clock = const Clock(),
  }) {
    assert(RegExp(r'^[0-9a-f]{64}$').hasMatch(hexKey), 'hex key expected');
    return AppDatabase(
      driftDatabase(
        name: 'expenses',
        native: DriftNativeOptions(
          databasePath: () async => path,
          setup: (raw) => unlock(raw, hexKey: hexKey, wasPlain: wasPlain),
        ),
      ),
      clock: clock,
    );
  }

  /// Unlocks a freshly opened connection with [hexKey], encrypting a
  /// database from before encryption ([wasPlain]) in place, then sets the
  /// connection pragmas. Throws at once if the key is wrong.
  static void unlock(
    CommonDatabase raw, {
    required String hexKey,
    required bool wasPlain,
  }) {
    if (wasPlain) {
      // Rekeying needs a rollback journal; WAL comes back below.
      raw
        ..execute('PRAGMA journal_mode = DELETE;')
        ..execute("PRAGMA hexrekey = '$hexKey';");
    } else {
      raw.execute("PRAGMA hexkey = '$hexKey';");
    }
    raw
      ..execute('SELECT count(*) FROM sqlite_master;')
      ..execute('PRAGMA journal_mode = WAL;')
      ..execute('PRAGMA synchronous = FULL;')
      ..execute('PRAGMA busy_timeout = 5000;');
  }

  /// Whether the file at [path] is an unencrypted SQLite database: its
  /// first 16 bytes are SQLite's own header, which encryption hides.
  static Future<bool> isPlain(String path) async {
    final file = File(path);
    if (!file.existsSync()) return false;
    final handle = await file.open();
    try {
      final head = await handle.read(16);
      return String.fromCharCodes(head) == 'SQLite format 3\u0000';
    } finally {
      await handle.close();
    }
  }

  final Clock _clock;

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // Forward-only, one step per version. Never edit a shipped step.
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // Phase 2: capture tables for paste and share (spec §12).
        await m.createTable(schema.rawCaptures);
        await m.createTable(schema.transactionSources);
        await m.createTable(schema.unparsed);
        await m.createIndex(schema.transactionSourcesTransaction);
      },
      from2To3: (m, schema) async {
        // Phase 6: budgets and the alerts already shown (spec §10).
        await m.createTable(schema.budgets);
        await m.createTable(schema.firedAlerts);
      },
      from3To4: (m, schema) async {
        // Phase 6: the in-app notification inbox.
        await m.createTable(schema.notices);
        await m.createIndex(schema.noticesCreatedAt);
      },
      from4To5: (m, schema) async {
        // Phase 7: learned payee rules and the merchant book (spec §8).
        await m.createTable(schema.payeeRules);
      },
      from5To6: (m, schema) async {
        // Phase 9: sync state and the change triggers (sync.drift).
        await m.createTable(schema.syncMeta);
        await m.createTable(schema.syncOutbox);
        await m.createTable(schema.syncState);
        for (final trigger in schema.entities.whereType<Trigger>()) {
          await m.createTrigger(trigger);
        }
      },
    ),
    beforeOpen: (details) async {
      // Per-connection, not stored in the file: assert on every open.
      await customStatement('PRAGMA foreign_keys = ON;');
      if (details.wasCreated) {
        await seedDatabase(this, _clock.now().toUtc().millisecondsSinceEpoch);
      }
    },
  );
}
