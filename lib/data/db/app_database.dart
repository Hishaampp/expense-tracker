import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/data/db/app_database.steps.dart';
import 'package:expense_tracker/data/db/seed.dart';
import 'package:expense_tracker/data/db/tables.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the database on the executor `e`; `clock` stamps seeded rows.
  new(super.e, {this._clock = const Clock()});

  /// Opens the app's database file in app-private storage.
  factory open({Clock clock = const Clock()}) {
    return AppDatabase(
      driftDatabase(
        name: 'expenses',
        native: DriftNativeOptions(
          setup: (raw) {
            raw
              ..execute('PRAGMA journal_mode = WAL;')
              ..execute('PRAGMA synchronous = FULL;')
              ..execute('PRAGMA busy_timeout = 5000;');
          },
        ),
      ),
      clock: clock,
    );
  }

  final Clock _clock;

  @override
  int get schemaVersion => 2;

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
