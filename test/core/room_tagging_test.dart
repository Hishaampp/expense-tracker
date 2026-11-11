import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/room_tagging.dart';
import 'package:test/test.dart';

final _today = LocalDay.of(DateTime(2026, 11, 10, 14));

Room _room(
  String id, {
  RoomType type = RoomType.trip,
  AutoTagMode? mode,
  int? from,
  int? to,
  RoomStatus status = RoomStatus.active,
}) => Room(
  id: id,
  name: id,
  type: type,
  autoTagMode: mode ?? type.defaultMode,
  createdAt: DateTime.utc(2026),
  startDay: from == null ? null : _today.plus(from),
  endDay: to == null ? null : _today.plus(to),
  status: status,
);

void main() {
  test('one trip covering the day takes the expense', () {
    final tag = tagRoom(day: _today, rooms: [_room('goa', from: -1, to: 2)]);
    expect(tag, isA<RoomAssigned>().having((t) => t.room.id, 'id', 'goa'));
  });

  test('the first and last days of a trip are inside it', () {
    final trip = _room('goa', from: 0, to: 2);
    expect(tagRoom(day: _today, rooms: [trip]), isA<RoomAssigned>());
    expect(tagRoom(day: _today.plus(2), rooms: [trip]), isA<RoomAssigned>());
    expect(tagRoom(day: _today.plus(3), rooms: [trip]), isA<NoRoom>());
    expect(tagRoom(day: _today.plus(-1), rooms: [trip]), isA<NoRoom>());
  });

  test('overlapping trips ask instead of guessing', () {
    final tag = tagRoom(
      day: _today,
      rooms: [_room('goa', from: -2, to: 1), _room('work', from: 0, to: 0)],
    );
    expect(
      tag,
      isA<RoomChoice>().having((t) => t.rooms.map((r) => r.id), 'ids', [
        'goa',
        'work',
      ]),
    );
  });

  test('a trip with no end yet runs on', () {
    final tag = tagRoom(day: _today.plus(30), rooms: [_room('goa', from: 0)]);
    expect(tag, isA<RoomAssigned>());
  });

  test('a wedding across two months is suggested in both', () {
    final wedding = _room('w', type: RoomType.wedding, from: -40, to: 20);
    expect(
      tagRoom(day: _today.plus(-35), rooms: [wedding]),
      isA<RoomSuggestion>(),
    );
    expect(
      tagRoom(day: _today.plus(15), rooms: [wedding]),
      isA<RoomSuggestion>(),
    );
  });

  test('a trip beats a suggestion', () {
    final tag = tagRoom(
      day: _today,
      rooms: [
        _room('w', type: RoomType.wedding),
        _room('goa', from: 0, to: 1),
      ],
    );
    expect(tag, isA<RoomAssigned>());
  });

  test('manual and archived Rooms are never used', () {
    final tag = tagRoom(
      day: _today,
      rooms: [
        _room('m', type: RoomType.event, mode: AutoTagMode.manual),
        _room('old', from: -1, to: 1, status: RoomStatus.archived),
      ],
    );
    expect(tag, isA<NoRoom>());
  });

  test('type defaults follow the spec', () {
    expect(RoomType.trip.defaultMode, AutoTagMode.dateWindow);
    expect(RoomType.wedding.defaultMode, AutoTagMode.suggest);
    expect(RoomType.event.defaultMode, AutoTagMode.suggest);
    expect(RoomType.trip.needsDates, isTrue);
    expect(RoomType.wedding.needsDates, isFalse);
  });
}
