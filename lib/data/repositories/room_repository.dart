import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/id_generator.dart';
import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/mappers.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/common.dart';

/// Reads and writes Rooms, and which Room a transaction belongs to.
class RoomRepository {
  /// Creates the repository over [_db].
  new(this._db, this._clock, this._ids, this._log);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _log;

  /// Every Room: active first, then newest first.
  Stream<List<Room>> watchAll() {
    final query = _db.select(_db.rooms)
      ..orderBy([
        (r) => OrderingTerm.asc(r.status),
        (r) => OrderingTerm.desc(r.createdAt),
      ]);
    return query.watch().map(
      (rows) => rows.map(roomFromRow).toList(growable: false),
    );
  }

  /// The Room with [id]; null once it is gone.
  Stream<Room?> watchRoom(String id) {
    final query = _db.select(_db.rooms)..where((r) => r.id.equals(id));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : roomFromRow(row),
    );
  }

  /// The Room's transactions, newest first.
  Stream<List<MoneyTransaction>> watchTransactions(String roomId) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.roomId.equals(roomId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.occurredAt),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch().map(
      (rows) => rows.map(transactionFromRow).toList(growable: false),
    );
  }

  /// Spending per Room in paise (expenses minus refunds, hidden ones left
  /// out), by Room id. Live.
  Stream<Map<String, int>> watchSpentByRoom() {
    final t = _db.transactions;
    final signed = CaseWhenExpression<int>(
      cases: [
        CaseWhen(t.kind.equals('expense'), then: t.amountPaise),
        CaseWhen(t.kind.equals('refund'), then: -t.amountPaise),
      ],
      orElse: const Constant(0),
    );
    final total = signed.sum();
    final query = _db.selectOnly(t)
      ..addColumns([t.roomId, total])
      ..where(t.roomId.isNotNull() & t.isHidden.not())
      ..groupBy([t.roomId]);
    return query.watch().map(
      (rows) => {
        for (final row in rows) row.read(t.roomId)!: row.read(total) ?? 0,
      },
    );
  }

  /// The Room with [id], or null if it does not exist.
  Future<Room?> findById(String id) async {
    final query = _db.select(_db.rooms)..where((r) => r.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : roomFromRow(row);
  }

  /// Every Room, once.
  Future<List<Room>> all() async {
    final rows = await _db.select(_db.rooms).get();
    return rows.map(roomFromRow).toList(growable: false);
  }

  /// Creates a Room and returns it.
  @useResult
  Future<Result<Room, StoreFailure>> create({
    required String name,
    required RoomType type,
    required AutoTagMode autoTagMode,
    String? emoji,
    LocalDay? startDay,
    LocalDay? endDay,
    Money? budget,
    bool countsTowardMonthlyBudget = false,
  }) {
    final room = Room(
      id: _ids.newId(),
      name: name.trim(),
      type: type,
      autoTagMode: autoTagMode,
      createdAt: _clock.now().toUtc(),
      emoji: emoji,
      startDay: startDay,
      endDay: endDay,
      budget: budget,
      countsTowardMonthlyBudget: countsTowardMonthlyBudget,
    );
    return _write('room.create', room, () async {
      await _db.into(_db.rooms).insert(roomToRow(room));
      return true;
    });
  }

  /// Starts a trip today with no end yet (spec §9.4 "Start trip").
  @useResult
  Future<Result<Room, StoreFailure>> startTrip(String name) {
    return create(
      name: name,
      type: RoomType.trip,
      autoTagMode: AutoTagMode.dateWindow,
      startDay: LocalDay.of(_clock.now()),
    );
  }

  /// Saves every field of [room].
  @useResult
  Future<Result<Room, StoreFailure>> save(Room room) {
    return _write('room.save', room, () async {
      final changed = await (_db.update(
        _db.rooms,
      )..where((r) => r.id.equals(room.id))).write(roomToRow(room));
      return changed > 0;
    });
  }

  /// Puts transaction [transactionId] in the Room [roomId], or takes it
  /// out with null. A
  /// transaction belongs to at most one Room (spec §5.1).
  @useResult
  Future<Result<String, StoreFailure>> setRoom(
    String transactionId,
    String? roomId,
  ) async {
    try {
      final changed =
          await (_db.update(
            _db.transactions,
          )..where((t) => t.id.equals(transactionId))).write(
            TransactionsCompanion(
              roomId: Value(roomId),
              updatedAt: Value(_clock.now().toUtc().millisecondsSinceEpoch),
            ),
          );
      return changed > 0
          ? Ok(transactionId)
          : Err(StoreRecordMissing(transactionId));
    } on SqliteException catch (e, st) {
      _log.error('room.assign', e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }

  /// Deletes [room] in one transaction. With [withPayments] its payments
  /// go too; otherwise they stay and leave the Room, back in the normal
  /// month. Payee rules that sent payments to it stop doing so either way.
  @useResult
  Future<Result<Room, StoreFailure>> delete(
    Room room, {
    required bool withPayments,
  }) {
    return _write('room.delete', room, () {
      return _db.transaction(() async {
        // Explicit writes rather than relying on ON DELETE SET NULL, so
        // the change is stamped and queued for sync like any other edit.
        final now = _clock.now().toUtc().millisecondsSinceEpoch;
        if (withPayments) {
          await (_db.delete(
            _db.transactions,
          )..where((t) => t.roomId.equals(room.id))).go();
        } else {
          await (_db.update(
            _db.transactions,
          )..where((t) => t.roomId.equals(room.id))).write(
            TransactionsCompanion(
              roomId: const Value(null),
              updatedAt: Value(now),
            ),
          );
        }
        await (_db.update(_db.payeeRules)
              ..where((r) => r.roomId.equals(room.id)))
            .write(const PayeeRulesCompanion(roomId: Value(null)));
        final removed = await (_db.delete(
          _db.rooms,
        )..where((r) => r.id.equals(room.id))).go();
        return removed > 0;
      });
    });
  }

  Future<Result<Room, StoreFailure>> _write(
    String event,
    Room room,
    Future<bool> Function() action,
  ) async {
    try {
      final found = await action();
      return found ? Ok(room) : Err(StoreRecordMissing(room.id));
    } on SqliteException catch (e, st) {
      _log.error(event, e.runtimeType, st);
      return const Err(StoreWriteFailed());
    }
  }
}
