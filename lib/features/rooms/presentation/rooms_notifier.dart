import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// A Room with what has been spent in it.
typedef RoomEntry = ({Room room, Money spent});

/// What the Rooms tab shows.
@immutable
final class RoomsState {
  /// Creates the state.
  const new({required this.active, required this.archived});

  /// Current Rooms, newest first.
  final List<RoomEntry> active;

  /// Rooms → History.
  final List<RoomEntry> archived;

  /// Whether there are no Rooms at all.
  bool get isEmpty => active.isEmpty && archived.isEmpty;
}

/// The Rooms tab's view model. Live.
class RoomsNotifier extends AsyncNotifier<RoomsState> {
  @override
  Future<RoomsState> build() async {
    final rooms = await ref.watch(roomsProvider.future);
    final spent = await ref.watch(roomSpentProvider.future);
    RoomEntry entry(Room r) => (room: r, spent: Money(spent[r.id] ?? 0));
    return RoomsState(
      active: [
        for (final r in rooms)
          if (r.isActive) entry(r),
      ],
      archived: [
        for (final r in rooms)
          if (!r.isActive) entry(r),
      ],
    );
  }
}

/// Provides [RoomsNotifier].
final AsyncNotifierProvider<RoomsNotifier, RoomsState> roomsNotifierProvider =
    AsyncNotifierProvider.autoDispose<RoomsNotifier, RoomsState>(
      RoomsNotifier.new,
    );
