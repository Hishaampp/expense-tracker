import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/category_total.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/core/room_summary.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:meta/meta.dart';

/// One day of a Room: what was spent and the transactions.
typedef RoomDay = ({LocalDay day, Money spent, List<TransactionItem> items});

/// What a Room's detail screen shows.
@immutable
final class RoomDetailState {
  /// Creates the state.
  const new({
    required this.summary,
    required this.categories,
    required this.days,
    required this.today,
  });

  /// The Room's totals (and the Room itself).
  final RoomSummary summary;

  /// Spending per category, largest first.
  final List<CategoryTotal> categories;

  /// Days with transactions, newest first.
  final List<RoomDay> days;

  /// Today, for "Today" and "Yesterday" headings.
  final LocalDay today;

  /// The Room.
  Room get room => summary.room;
}

/// A Room's detail view model, keyed by Room id. Null state means the Room
/// is gone. Live.
class RoomDetailNotifier extends AsyncNotifier<RoomDetailState?> {
  /// Creates the view model for Room [roomId].
  new(this.roomId);

  /// The Room shown.
  final String roomId;

  @override
  Future<RoomDetailState?> build() async {
    final room = await ref.watch(_roomProvider(roomId).future);
    if (room == null) return null;
    final txns = await ref.watch(_roomTransactionsProvider(roomId).future);
    final categories = await ref.watch(categoriesProvider.future);
    final accounts = await ref.watch(accountsProvider.future);
    final today = LocalDay.of(ref.watch(clockProvider).now());
    final summary = RoomSummary.of(room, txns, today: today);
    final visible = txns.where((t) => !t.isHidden);
    final items = joinTransactions(visible, categories, accounts);
    final spentOn = {for (final d in summary.byDay) d.day: d.spent};
    final days = <RoomDay>[];
    for (final item in items) {
      final day = LocalDay.of(item.transaction.occurredAt);
      if (days.isEmpty || days.last.day != day) {
        days.add((day: day, spent: spentOn[day] ?? Money.zero, items: []));
      }
      days.last.items.add(item);
    }
    return RoomDetailState(
      summary: summary,
      categories: categoryTotals(summary.byCategory, categories, summary.spent),
      days: days,
      today: today,
    );
  }

  Future<StoreFailure?> _save(Room Function(Room) change) async {
    final room = state.value?.room;
    if (room == null) return null;
    final result = await ref.read(roomRepositoryProvider).save(change(room));
    switch (result) {
      case Ok():
        ref.read(hapticsProvider).commit();
        return null;
      case Err(:final failure):
        return failure;
    }
  }

  /// Ends an ongoing trip today. Returns the failure, or null.
  Future<StoreFailure?> endToday() => _save(
    (r) => r.copyWith(endDay: LocalDay.of(ref.read(clockProvider).now())),
  );

  /// Moves the Room to History. Returns the failure, or null.
  Future<StoreFailure?> archive() =>
      _save((r) => r.copyWith(status: RoomStatus.archived));

  /// Deletes the Room; with [withPayments] its payments too. Returns the
  /// failure, or null.
  Future<StoreFailure?> delete({required bool withPayments}) async {
    final room = state.value?.room;
    if (room == null) return null;
    final result = await ref
        .read(roomRepositoryProvider)
        .delete(room, withPayments: withPayments);
    switch (result) {
      case Ok():
        ref.read(hapticsProvider).commit();
        return null;
      case Err(:final failure):
        return failure;
    }
  }

  /// Moves the Room back to active. Returns the failure, or null.
  Future<StoreFailure?> restore() =>
      _save((r) => r.copyWith(status: RoomStatus.active));
}

final StreamProviderFamily<Room?, String> _roomProvider = StreamProvider
    .autoDispose
    .family<Room?, String>(
      (ref, id) => ref.watch(roomRepositoryProvider).watchRoom(id),
    );

final StreamProviderFamily<List<MoneyTransaction>, String>
_roomTransactionsProvider = StreamProvider.autoDispose
    .family<List<MoneyTransaction>, String>(
      (ref, id) => ref.watch(roomRepositoryProvider).watchTransactions(id),
    );

/// Provides [RoomDetailNotifier], keyed by Room id.
final AsyncNotifierProviderFamily<RoomDetailNotifier, RoomDetailState?, String>
roomDetailNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<RoomDetailNotifier, RoomDetailState?, String>(
      RoomDetailNotifier.new,
    );
