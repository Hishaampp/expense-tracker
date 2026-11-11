import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/core/room_tagging.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// One payment waiting for review, with what its card needs.
@immutable
final class ReviewItem {
  /// Creates the item.
  const new({
    required this.transaction,
    required this.accountName,
    required this.choices,
    this.suggested,
    this.room,
    this.roomOffers = const [],
  });

  /// The payment.
  final MoneyTransaction transaction;

  /// Its account's name, such as "HDFC ••1234".
  final String accountName;

  /// The suggested category, if any.
  final Category? suggested;

  /// Up to three categories to offer: the suggestion first, then the most
  /// used.
  final List<Category> choices;

  /// The Room it is in, if any.
  final Room? room;

  /// Rooms to offer when it is in none: overlapping trips, or Rooms that
  /// ask (spec §9.3).
  final List<Room> roomOffers;
}

/// What the review inbox shows.
@immutable
final class ReviewState {
  /// Creates the state.
  const new({required this.items, required this.allCategories});

  /// Waiting payments, newest first.
  final List<ReviewItem> items;

  /// Every expense category, for "More".
  final List<Category> allCategories;

  /// How many already have a suggested category.
  int get suggestedCount => items.where((i) => i.suggested != null).length;
}

/// How a review action ended, for the screen's feedback.
sealed class ReviewDone {
  const new();
}

/// [transaction] was confirmed as [category]; Undo restores it.
final class ReviewConfirmed extends ReviewDone {
  /// Creates the result.
  const new(this.transaction, this.category);

  /// The payment as it was before.
  final MoneyTransaction transaction;

  /// The category it was confirmed as.
  final Category category;
}

/// [transaction] was marked as a transfer; Undo restores it.
final class ReviewTransferred extends ReviewDone {
  /// Creates the result.
  const new(this.transaction);

  /// The payment as it was before.
  final MoneyTransaction transaction;
}

/// [count] suggested payments were confirmed at once.
final class ReviewConfirmedAll extends ReviewDone {
  /// Creates the result.
  const new(this.count);

  /// How many.
  final int count;
}

/// [transaction] was added to [room]; Undo takes it out.
final class ReviewAddedToRoom extends ReviewDone {
  /// Creates the result.
  const new(this.transaction, this.room);

  /// The payment as it was before.
  final MoneyTransaction transaction;

  /// The Room it went to.
  final Room room;
}

/// A review action could not be saved.
final class ReviewFailed extends ReviewDone {
  /// Creates the result.
  const new(this.failure);

  /// Why.
  final StoreFailure failure;
}

/// The review inbox view model (spec §5.7, §11.3). Live.
class ReviewNotifier extends StreamNotifier<ReviewState> {
  /// How many category choices each card offers.
  static const int choiceCount = 3;

  @override
  Stream<ReviewState> build() async* {
    final categories = await ref.watch(categoriesProvider.future);
    final accounts = await ref.watch(accountsProvider.future);
    final now = ref.read(clockProvider).now().toUtc();
    final usage = await ref
        .read(transactionRepositoryProvider)
        .categoryUsageSince(now.subtract(const Duration(days: 90)));
    final expense =
        [
          for (final c in categories)
            if (c.kind == CategoryKind.expense && !c.isArchived) c,
        ]..sort((a, b) {
          final byUse = (usage[b.id] ?? 0).compareTo(usage[a.id] ?? 0);
          return byUse != 0 ? byUse : a.sortOrder.compareTo(b.sortOrder);
        });
    final byId = {for (final c in categories) c.id: c};
    final accountName = {for (final a in accounts) a.id: a.name};
    final rooms = await ref.watch(roomsProvider.future);
    final roomById = {for (final r in rooms) r.id: r};
    yield* ref
        .watch(autoCaptureRepositoryProvider)
        .watchNeedsReview()
        .map(
          (txns) => ReviewState(
            allCategories: expense,
            items: [
              for (final txn in txns)
                _item(
                  txn,
                  byId[txn.categoryId],
                  expense,
                  accountName,
                ).withRooms(txn, roomById, rooms),
            ],
          ),
        );
  }

  ReviewItem _item(
    MoneyTransaction txn,
    Category? suggested,
    List<Category> expense,
    Map<String, String> accountName,
  ) {
    return ReviewItem(
      transaction: txn,
      accountName: accountName[txn.accountId] ?? '',
      suggested: suggested,
      choices: [
        ?suggested,
        ...expense
            .where((c) => c.id != suggested?.id)
            .take(choiceCount - (suggested == null ? 0 : 1)),
      ],
    );
  }

  /// Puts [item] in [room].
  Future<ReviewDone> addToRoom(ReviewItem item, Room room) async {
    ref.read(hapticsProvider).commit();
    final result = await ref
        .read(roomRepositoryProvider)
        .setRoom(item.transaction.id, room.id);
    return switch (result) {
      Ok() => ReviewAddedToRoom(item.transaction, room),
      Err(:final failure) => ReviewFailed(failure),
    };
  }

  /// Confirms [item] as [category].
  Future<ReviewDone> confirm(ReviewItem item, Category category) async {
    ref.read(hapticsProvider).commit();
    final result = await ref
        .read(autoCaptureRepositoryProvider)
        .confirm(item.transaction.id, category.id);
    return switch (result) {
      Ok() => ReviewConfirmed(item.transaction, category),
      Err(:final failure) => ReviewFailed(failure),
    };
  }

  /// Marks [item] as a transfer between the user's own accounts.
  Future<ReviewDone> markTransfer(ReviewItem item) async {
    ref.read(hapticsProvider).commit();
    final result = await ref
        .read(autoCaptureRepositoryProvider)
        .markTransfer(item.transaction.id);
    return switch (result) {
      Ok() => ReviewTransferred(item.transaction),
      Err(:final failure) => ReviewFailed(failure),
    };
  }

  /// Confirms every payment that has a suggestion.
  Future<ReviewDone> confirmAllSuggested() async {
    ref.read(hapticsProvider).commit();
    final result = await ref
        .read(autoCaptureRepositoryProvider)
        .confirmAllSuggested();
    return switch (result) {
      Ok(:final value) => ReviewConfirmedAll(value),
      Err(:final failure) => ReviewFailed(failure),
    };
  }

  /// Puts [transaction] back as it was before a confirm or transfer.
  /// Returns the failure, or null when it worked.
  Future<StoreFailure?> undo(MoneyTransaction transaction) async {
    final result = await ref
        .read(autoCaptureRepositoryProvider)
        .restoreReview(transaction);
    return switch (result) {
      Ok() => null,
      Err(:final failure) => failure,
    };
  }
}

extension on ReviewItem {
  // Adds the Room it is in, or the Rooms to offer for an expense in none.
  ReviewItem withRooms(
    MoneyTransaction txn,
    Map<String, Room> roomById,
    List<Room> rooms,
  ) {
    final roomId = txn.roomId;
    final offers = roomId != null || txn.kind != TransactionKind.expense
        ? const <Room>[]
        : switch (tagRoom(day: LocalDay.of(txn.occurredAt), rooms: rooms)) {
            RoomChoice(:final rooms) || RoomSuggestion(:final rooms) => rooms,
            // A trip made after the payment was saved: offer it.
            RoomAssigned(:final room) => [room],
            NoRoom() => const <Room>[],
          };
    return ReviewItem(
      transaction: transaction,
      accountName: accountName,
      choices: choices,
      suggested: suggested,
      room: roomById[roomId],
      roomOffers: offers,
    );
  }
}

/// Provides [ReviewNotifier].
final StreamNotifierProvider<ReviewNotifier, ReviewState>
reviewNotifierProvider =
    StreamNotifierProvider.autoDispose<ReviewNotifier, ReviewState>(
      ReviewNotifier.new,
    );
