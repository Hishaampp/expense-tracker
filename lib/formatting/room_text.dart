import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';

/// The name of a Room type.
String roomTypeName(AppLocalizations l10n, RoomType type) => switch (type) {
  RoomType.trip => l10n.roomTypeTrip,
  RoomType.wedding => l10n.roomTypeWedding,
  RoomType.event => l10n.roomTypeEvent,
  RoomType.custom => l10n.roomTypeCustom,
};

/// A Room's dates: "8 Nov – 10 Nov", "From 8 Nov", or null when undated.
String? roomDates(AppLocalizations l10n, Room room, String locale) {
  final start = room.startDay;
  if (start == null) return null;
  final from = formatDayMonth(start.date, locale);
  final end = room.endDay;
  if (end == null) return l10n.roomFrom(from);
  if (end == start) return from;
  return l10n.roomRange(from, formatDayMonth(end.date, locale));
}

/// The line under a Room's name: its type, then its dates if any.
String roomSubtitle(AppLocalizations l10n, Room room, String locale) {
  final type = roomTypeName(l10n, room.type);
  final dates = roomDates(l10n, room, locale);
  return dates == null ? type : l10n.listPair(type, dates);
}

/// How a Room's name reads with its emoji.
String roomLabel(Room room) {
  final emoji = room.emoji;
  return emoji == null ? room.name : '$emoji ${room.name}';
}
