import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/payee_rule.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// What the Payees screen shows.
@immutable
final class PayeesState {
  /// Creates the state.
  const new({
    required this.entries,
    required this.categories,
    required this.rooms,
  });

  /// Every payee seen, most used first.
  final List<PayeeEntry> entries;

  /// Expense categories, by id.
  final Map<String, Category> categories;

  /// Every Room, by id.
  final Map<String, Room> rooms;
}

/// The merchant book's view model (spec §8).
class PayeesNotifier extends AsyncNotifier<PayeesState> {
  @override
  Future<PayeesState> build() async {
    final entries = await ref.watch(payeeBookProvider.future);
    final categories = await ref.watch(categoriesProvider.future);
    final rooms = await ref.watch(roomsProvider.future);
    return PayeesState(
      entries: entries,
      categories: {
        for (final c in categories)
          if (c.kind == CategoryKind.expense) c.id: c,
      },
      rooms: {for (final r in rooms) r.id: r},
    );
  }

  /// Saves [rule]; an empty rule is forgotten.
  Future<Result<PayeeRule, StoreFailure>> save(PayeeRule rule) async {
    final result = await ref.read(payeeRepositoryProvider).save(rule);
    if (result is Ok) ref.read(hapticsProvider).commit();
    return result;
  }
}

/// Provides [PayeesNotifier].
final AsyncNotifierProvider<PayeesNotifier, PayeesState>
payeesNotifierProvider =
    AsyncNotifierProvider.autoDispose<PayeesNotifier, PayeesState>(
      PayeesNotifier.new,
    );
