import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:meta/meta.dart';

/// Which Room an expense should go to (spec §9.3).
@immutable
sealed class RoomTag {
  const new();
}

/// Exactly one date-window Room covers the day: it goes there.
final class RoomAssigned extends RoomTag {
  /// Creates the tag.
  const new(this.room);

  /// The Room.
  final Room room;
}

/// Several date-window Rooms cover the day: the user chooses.
final class RoomChoice extends RoomTag {
  /// Creates the tag.
  const new(this.rooms);

  /// The overlapping Rooms.
  final List<Room> rooms;
}

/// Suggest-mode Rooms that may want it: "Add to Goa trip?".
final class RoomSuggestion extends RoomTag {
  /// Creates the tag.
  const new(this.rooms);

  /// The Rooms to offer.
  final List<Room> rooms;
}

/// No Room applies.
final class NoRoom extends RoomTag {
  /// Creates the tag.
  const new();
}

/// Decides where an expense on [day] goes, from [rooms] (spec §9.3):
/// 1. date-window Rooms covering [day]: one assigns, more ask;
/// 2. otherwise suggest-mode Rooms covering [day] are offered;
/// 3. manual Rooms and archived Rooms are never used.
///
/// Payee rules with a Room mapping (step 2 of §9.3) arrive with the
/// merchant book in Phase 7.
RoomTag tagRoom({required LocalDay day, required Iterable<Room> rooms}) {
  final windows = <Room>[];
  final suggest = <Room>[];
  for (final room in rooms) {
    if (!room.isActive || !room.contains(day)) continue;
    switch (room.autoTagMode) {
      case AutoTagMode.dateWindow:
        if (room.startDay != null) windows.add(room);
      case AutoTagMode.suggest:
        suggest.add(room);
      case AutoTagMode.manual:
        break;
    }
  }
  if (windows.length == 1) return RoomAssigned(windows.single);
  if (windows.length > 1) return RoomChoice(List.unmodifiable(windows));
  if (suggest.isNotEmpty) return RoomSuggestion(List.unmodifiable(suggest));
  return const NoRoom();
}
