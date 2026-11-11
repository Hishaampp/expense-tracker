import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:meta/meta.dart';

/// What kind of Room it is (spec §9.2).
enum RoomType {
  /// A trip: clean dates, everything inside them belongs to it.
  trip,

  /// A wedding: spread over months, mixed with normal life.
  wedding,

  /// Any other event.
  event,

  /// Anything else.
  custom;

  /// How expenses join a new Room of this type (spec §9.2).
  AutoTagMode get defaultMode => switch (this) {
    RoomType.trip => AutoTagMode.dateWindow,
    RoomType.wedding ||
    RoomType.event ||
    RoomType.custom => AutoTagMode.suggest,
  };

  /// Whether a Room of this type must have a start date.
  bool get needsDates => this == RoomType.trip;

  /// Whether the user picks the auto-tag mode, instead of the type fixing it.
  bool get choosesMode => this == RoomType.event || this == RoomType.custom;
}

/// How expenses join a Room (spec §9.3).
enum AutoTagMode {
  /// Every expense inside the dates joins it.
  dateWindow,

  /// Each expense is offered: "Add to Goa trip?".
  suggest,

  /// Only added by hand.
  manual,
}

/// Whether a Room is current or history.
enum RoomStatus {
  /// Shown on Home and offered for new expenses.
  active,

  /// In Rooms → History; still editable.
  archived,
}

/// A trip, wedding or event that collects its own spending, which still
/// counts in the normal month (spec §5.2, §9).
@immutable
final class Room {
  /// Creates a Room.
  const new({
    required this.id,
    required this.name,
    required this.type,
    required this.autoTagMode,
    required this.createdAt,
    this.emoji,
    this.startDay,
    this.endDay,
    this.budget,
    this.countsTowardMonthlyBudget = false,
    this.status = RoomStatus.active,
  });

  /// Stable unique id.
  final String id;

  /// Display name, for example "Goa trip".
  final String name;

  /// What kind of Room it is.
  final RoomType type;

  /// Emoji shown with the name, if chosen.
  final String? emoji;

  /// First day, if dated.
  final LocalDay? startDay;

  /// Last day (inclusive); null while a dated Room is still going.
  final LocalDay? endDay;

  /// The Room's own budget, if set.
  final Money? budget;

  /// How expenses join it.
  final AutoTagMode autoTagMode;

  /// Whether its spending counts toward the monthly budget (default no,
  /// spec §5.2).
  final bool countsTowardMonthlyBudget;

  /// Current or history.
  final RoomStatus status;

  /// When it was created.
  final DateTime createdAt;

  /// Whether it is current.
  bool get isActive => status == RoomStatus.active;

  /// Whether it has dates and no end yet.
  bool get isOngoing => startDay != null && endDay == null;

  /// Whether [day] is inside the Room's dates. Undated Rooms contain every
  /// day; an open end runs on until it is set.
  bool contains(LocalDay day) {
    final start = startDay;
    final end = endDay;
    if (start != null && day.isBefore(start)) return false;
    if (end != null && day.isAfter(end)) return false;
    return true;
  }

  /// A copy with the given fields replaced. Pass [clearEnd] to remove the
  /// end day.
  Room copyWith({
    String? name,
    RoomStatus? status,
    LocalDay? endDay,
    bool clearEnd = false,
  }) {
    return Room(
      id: id,
      name: name ?? this.name,
      type: type,
      autoTagMode: autoTagMode,
      createdAt: createdAt,
      emoji: emoji,
      startDay: startDay,
      endDay: clearEnd ? null : endDay ?? this.endDay,
      budget: budget,
      countsTowardMonthlyBudget: countsTowardMonthlyBudget,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Room &&
      other.id == id &&
      other.name == name &&
      other.type == type &&
      other.emoji == emoji &&
      other.startDay == startDay &&
      other.endDay == endDay &&
      other.budget == budget &&
      other.autoTagMode == autoTagMode &&
      other.countsTowardMonthlyBudget == countsTowardMonthlyBudget &&
      other.status == status &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    emoji,
    startDay,
    endDay,
    budget,
    autoTagMode,
    countsTowardMonthlyBudget,
    status,
    createdAt,
  );
}
