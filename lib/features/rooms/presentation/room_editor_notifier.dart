import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:meta/meta.dart';

/// Why a Room's dates cannot be saved.
enum RoomDateError {
  /// A trip, or a Room that takes every expense in its dates, has no start.
  startRequired,

  /// The end is before the start.
  endBeforeStart,
}

/// The Room form's choices. The name and budget are typed in text fields
/// the screen owns.
@immutable
final class RoomEditorState {
  /// Creates the state.
  const new({
    required this.type,
    required this.mode,
    this.original,
    this.emoji,
    this.start,
    this.end,
    this.countsInBudget = false,
    this.dateError,
    this.isSaving = false,
    this.failure,
    this.savedId,
  });

  /// Emoji the form offers.
  static const List<String> emojis = [
    '✈️',
    '🏖️',
    '🏔️',
    '💍',
    '🎉',
    '🎂',
    '🏠',
    '🎓',
  ];

  /// The Room being edited, or null when creating.
  final Room? original;

  /// The chosen type.
  final RoomType type;

  /// How expenses join it.
  final AutoTagMode mode;

  /// The chosen emoji, if any.
  final String? emoji;

  /// First day, if set.
  final LocalDay? start;

  /// Last day, if set.
  final LocalDay? end;

  /// Whether its spending counts toward the monthly budget.
  final bool countsInBudget;

  /// The dates problem to show, if any.
  final RoomDateError? dateError;

  /// Whether a save is in flight.
  final bool isSaving;

  /// The last failed save.
  final StoreFailure? failure;

  /// Set once saved: the Room's id. The screen then closes.
  final String? savedId;

  /// Whether an existing Room is being edited.
  bool get isEditing => original != null;

  /// A copy with the given fields replaced. The errors clear unless passed.
  RoomEditorState copyWith({
    RoomType? type,
    AutoTagMode? mode,
    String? emoji,
    bool clearEmoji = false,
    LocalDay? start,
    LocalDay? end,
    bool clearEnd = false,
    bool? countsInBudget,
    RoomDateError? dateError,
    bool? isSaving,
    StoreFailure? failure,
    String? savedId,
  }) {
    return RoomEditorState(
      original: original,
      type: type ?? this.type,
      mode: mode ?? this.mode,
      emoji: clearEmoji ? null : emoji ?? this.emoji,
      start: start ?? this.start,
      end: clearEnd ? null : end ?? this.end,
      countsInBudget: countsInBudget ?? this.countsInBudget,
      dateError: dateError,
      isSaving: isSaving ?? this.isSaving,
      failure: failure,
      savedId: savedId ?? this.savedId,
    );
  }
}

/// Most rupee digits a budget takes (₹99,99,99,999).
const int maxBudgetDigits = 9;

/// Parses a whole-rupee budget; null when empty or not a number.
Money? parseBudget(String text) {
  final rupees = int.tryParse(text.trim());
  if (rupees == null || rupees <= 0) return null;
  return Money(rupees * Currency.inr.minorPerMajor);
}

/// The Room form's view model, keyed by the Room id (null to create).
class RoomEditorNotifier extends AsyncNotifier<RoomEditorState> {
  /// Creates the view model for Room [roomId], or a new Room when null.
  new(this.roomId);

  /// The Room edited, or null.
  final String? roomId;

  @override
  Future<RoomEditorState> build() async {
    final id = roomId;
    if (id != null) {
      final room = await ref.read(roomRepositoryProvider).findById(id);
      if (room != null) {
        return RoomEditorState(
          original: room,
          type: room.type,
          mode: room.autoTagMode,
          emoji: room.emoji,
          start: room.startDay,
          end: room.endDay,
          countsInBudget: room.countsTowardMonthlyBudget,
        );
      }
    }
    return RoomEditorState(
      type: RoomType.trip,
      mode: RoomType.trip.defaultMode,
      emoji: RoomEditorState.emojis.first,
      start: LocalDay.of(ref.read(clockProvider).now()),
    );
  }

  void _update(RoomEditorState Function(RoomEditorState) change) {
    final current = state.value;
    if (current == null || current.isSaving) return;
    state = AsyncData(change(current));
  }

  /// Chooses the type; a type with a fixed mode sets it (spec §9.2).
  void setType(RoomType type) => _update(
    (s) => s.copyWith(
      type: type,
      mode: type.choosesMode && s.type.choosesMode ? s.mode : type.defaultMode,
    ),
  );

  /// Chooses how expenses join (Event and Other only).
  void setMode(AutoTagMode mode) => _update((s) => s.copyWith(mode: mode));

  /// Chooses an emoji, or none with null.
  void setEmoji(String? emoji) =>
      _update((s) => s.copyWith(emoji: emoji, clearEmoji: emoji == null));

  /// Sets the first day.
  void setStart(DateTime localDay) =>
      _update((s) => s.copyWith(start: LocalDay.of(localDay)));

  /// Sets the last day, or clears it with null.
  void setEnd(DateTime? localDay) => _update(
    (s) => localDay == null
        ? s.copyWith(clearEnd: true)
        : s.copyWith(end: LocalDay.of(localDay)),
  );

  /// Sets whether it counts toward the monthly budget.
  void setCountsInBudget({required bool value}) =>
      _update((s) => s.copyWith(countsInBudget: value));

  /// Saves the Room as [name] with [budgetText] (whole rupees, optional).
  /// The name is already validated by the form.
  Future<void> save({required String name, required String budgetText}) async {
    final s = state.value;
    if (s == null || s.isSaving) return;
    final start = s.start;
    final end = s.end;
    final needsStart = s.type.needsDates || s.mode == AutoTagMode.dateWindow;
    if (needsStart && start == null) {
      state = AsyncData(s.copyWith(dateError: RoomDateError.startRequired));
      ref.read(hapticsProvider).reject();
      return;
    }
    if (start != null && end != null && end.isBefore(start)) {
      state = AsyncData(s.copyWith(dateError: RoomDateError.endBeforeStart));
      ref.read(hapticsProvider).reject();
      return;
    }
    state = AsyncData(s.copyWith(isSaving: true));
    final repository = ref.read(roomRepositoryProvider);
    final budget = parseBudget(budgetText);
    final original = s.original;
    final result = original == null
        ? await repository.create(
            name: name,
            type: s.type,
            autoTagMode: s.mode,
            emoji: s.emoji,
            startDay: start,
            endDay: end,
            budget: budget,
            countsTowardMonthlyBudget: s.countsInBudget,
          )
        : await repository.save(
            Room(
              id: original.id,
              name: name.trim(),
              type: s.type,
              autoTagMode: s.mode,
              createdAt: original.createdAt,
              emoji: s.emoji,
              startDay: start,
              endDay: end,
              budget: budget,
              countsTowardMonthlyBudget: s.countsInBudget,
              status: original.status,
            ),
          );
    if (!ref.mounted) return;
    switch (result) {
      case Ok(:final value):
        ref.read(hapticsProvider).commit();
        state = AsyncData(s.copyWith(savedId: value.id));
      case Err(:final failure):
        ref.read(hapticsProvider).reject();
        state = AsyncData(s.copyWith(failure: failure));
    }
  }
}

/// Provides [RoomEditorNotifier], keyed by Room id (null to create).
final AsyncNotifierProviderFamily<RoomEditorNotifier, RoomEditorState, String?>
roomEditorNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<RoomEditorNotifier, RoomEditorState, String?>(
      RoomEditorNotifier.new,
    );
