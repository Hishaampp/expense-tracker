import 'dart:async';

import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/keypad_amount.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:meta/meta.dart';

/// How a Quick Add session ended. The screen reacts once, then closes.
sealed class QuickAddOutcome {
  const new();
}

/// A new expense of [amount] was saved.
final class ExpenseAdded extends QuickAddOutcome {
  /// Creates the outcome.
  const new(this.amount);

  /// The saved amount.
  final Money amount;
}

/// The edited expense was saved.
final class ExpenseUpdated extends QuickAddOutcome {
  /// Creates the outcome.
  const new();
}

/// The expense was deleted; [deleted] lets the screen offer Undo.
final class ExpenseDeleted extends QuickAddOutcome {
  /// Creates the outcome.
  const new(this.deleted);

  /// The removed transaction.
  final MoneyTransaction deleted;
}

/// What the Quick Add screen shows.
@immutable
final class QuickAddState {
  /// Creates the state.
  const new({
    required this.categories,
    required this.earliestDate,
    required this.latestDate,
    this.amount = KeypadAmount.empty,
    this.categoryId,
    this.occurredAt,
    this.note = '',
    this.editing,
    this.isMissing = false,
    this.isSaving = false,
    this.failure,
    this.outcome,
  });

  /// Expense categories to choose from, in picker order.
  final List<Category> categories;

  /// The earliest date the date picker offers.
  final DateTime earliestDate;

  /// The latest date the date picker offers: today.
  final DateTime latestDate;

  /// The amount typed so far.
  final KeypadAmount amount;

  /// The chosen category (edit mode), or null.
  final String? categoryId;

  /// The chosen local date and time, or null for "now".
  final DateTime? occurredAt;

  /// The note typed so far.
  final String note;

  /// The transaction being edited, or null when adding.
  final MoneyTransaction? editing;

  /// Whether the transaction to edit no longer exists.
  final bool isMissing;

  /// Whether a save or delete is in flight.
  final bool isSaving;

  /// The last failed save, shown inline until the next attempt.
  final StoreFailure? failure;

  /// Set once when the session ends.
  final QuickAddOutcome? outcome;

  /// Whether an existing transaction is being edited.
  bool get isEditing => editing != null;

  /// Whether the amount can be saved.
  bool get canSave => amount.isValid && !isSaving;

  /// A copy with the given fields replaced. The failure is cleared unless
  /// one is passed, because any new input makes it stale.
  QuickAddState copyWith({
    KeypadAmount? amount,
    String? categoryId,
    DateTime? occurredAt,
    String? note,
    bool? isSaving,
    StoreFailure? failure,
    QuickAddOutcome? outcome,
  }) {
    return QuickAddState(
      categories: categories,
      earliestDate: earliestDate,
      latestDate: latestDate,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note ?? this.note,
      editing: editing,
      isMissing: isMissing,
      isSaving: isSaving ?? this.isSaving,
      failure: failure,
      outcome: outcome ?? this.outcome,
    );
  }
}

/// The Quick Add view model. With an [editId] it edits that transaction;
/// without one it adds a cash expense in two steps: amount, then category.
class QuickAddNotifier extends AsyncNotifier<QuickAddState> {
  /// Creates the notifier for [editId] (null to add).
  new(this.editId);

  /// Id of the transaction to edit, or null to add a new one.
  final String? editId;

  /// How many years back the date picker reaches.
  static const int firstYearsBack = 5;

  @override
  Future<QuickAddState> build() async {
    // Read once: a category change mid-entry must not reset typed input.
    final all = await ref.read(categoriesProvider.future);
    final categories = [
      for (final c in all)
        if (c.kind == CategoryKind.expense && !c.isArchived) c,
    ];
    final today = ref.read(clockProvider).now().toLocal();
    final latest = DateTime(today.year, today.month, today.day);
    final earliest = DateTime(latest.year - firstYearsBack);
    QuickAddState base({bool isMissing = false}) => QuickAddState(
      categories: categories,
      earliestDate: earliest,
      latestDate: latest,
      isMissing: isMissing,
    );
    final id = editId;
    if (id == null) return base();

    final txn = await ref.read(transactionRepositoryProvider).findById(id);
    if (txn == null) return base(isMissing: true);
    return QuickAddState(
      categories: categories,
      earliestDate: earliest,
      latestDate: latest,
      amount: KeypadAmount.fromMoney(txn.amount),
      categoryId: txn.categoryId,
      occurredAt: txn.occurredAt.toLocal(),
      note: txn.note ?? '',
      editing: txn,
    );
  }

  void _update(QuickAddState Function(QuickAddState) change) {
    final current = state.value;
    if (current == null || current.isSaving) return;
    state = AsyncData(change(current));
  }

  /// Types [digit] (0–9).
  void digit(int digit) {
    ref.read(hapticsProvider).select();
    _update((s) => s.copyWith(amount: s.amount.appendDigit(digit)));
  }

  /// Types the decimal point.
  void point() {
    ref.read(hapticsProvider).select();
    _update((s) => s.copyWith(amount: s.amount.appendPoint()));
  }

  /// Removes the last typed character.
  void backspace() {
    ref.read(hapticsProvider).select();
    _update((s) => s.copyWith(amount: s.amount.backspace()));
  }

  /// Sets the date; the time of day stays as it was (or now).
  void setDate(DateTime localDay) {
    final now = ref.read(clockProvider).now().toLocal();
    _update((s) {
      final time = s.occurredAt ?? now;
      return s.copyWith(
        occurredAt: DateTime(
          localDay.year,
          localDay.month,
          localDay.day,
          time.hour,
          time.minute,
          time.second,
        ),
      );
    });
  }

  /// Sets the note.
  void setNote(String note) => _update((s) => s.copyWith(note: note));

  /// Picks a category. When adding, this saves the expense; when editing,
  /// it only selects, and [save] commits.
  void pickCategory(String categoryId) {
    final current = state.value;
    if (current == null || current.isSaving) return;
    if (current.isEditing) {
      ref.read(hapticsProvider).select();
      state = AsyncData(current.copyWith(categoryId: categoryId));
      return;
    }
    if (!current.amount.isValid) {
      ref.read(hapticsProvider).reject();
      return;
    }
    unawaited(_persist(current.copyWith(categoryId: categoryId)));
  }

  /// Saves the edits (edit mode).
  void save() {
    final current = state.value;
    if (current == null || !current.canSave) return;
    unawaited(_persist(current));
  }

  /// Deletes the transaction being edited.
  void delete() {
    final current = state.value;
    final txn = current?.editing;
    if (current == null || txn == null || current.isSaving) return;
    unawaited(
      _run(
        current,
        () => ref.read(transactionRepositoryProvider).delete(txn),
        ExpenseDeleted.new,
      ),
    );
  }

  Future<void> _persist(QuickAddState draft) {
    final repository = ref.read(transactionRepositoryProvider);
    final txn = draft.editing;
    final money = draft.amount.money;
    if (txn == null) {
      return _run(
        draft,
        () => repository.addExpense(
          amount: money,
          accountId: Account.cashId,
          categoryId: draft.categoryId,
          occurredAt: draft.occurredAt,
          note: draft.note,
        ),
        (saved) => ExpenseAdded(saved.amount),
      );
    }
    return _run(
      draft,
      () => repository.edit(
        txn,
        amount: money,
        occurredAt: draft.occurredAt ?? txn.occurredAt,
        accountId: txn.accountId,
        categoryId: draft.categoryId,
        note: draft.note,
      ),
      (_) => const ExpenseUpdated(),
    );
  }

  // Persist first; publish the outcome only after the commit returns.
  Future<void> _run(
    QuickAddState draft,
    Future<Result<MoneyTransaction, StoreFailure>> Function() write,
    QuickAddOutcome Function(MoneyTransaction) onOk,
  ) async {
    state = AsyncData(draft.copyWith(isSaving: true));
    final result = await write();
    if (!ref.mounted) return;
    switch (result) {
      case Ok(:final value):
        ref.read(hapticsProvider).commit();
        state = AsyncData(
          draft.copyWith(isSaving: false, outcome: onOk(value)),
        );
      case Err(:final failure):
        ref.read(hapticsProvider).reject();
        state = AsyncData(draft.copyWith(isSaving: false, failure: failure));
    }
  }
}

/// Provides [QuickAddNotifier], keyed by the id being edited (null to add).
final AsyncNotifierProviderFamily<QuickAddNotifier, QuickAddState, String?>
quickAddNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<QuickAddNotifier, QuickAddState, String?>(QuickAddNotifier.new);
