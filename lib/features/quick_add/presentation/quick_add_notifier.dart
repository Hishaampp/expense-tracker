import 'dart:async';

import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/keypad_amount.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/capture_draft.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/features/capture/application/capture_ingestion.dart';
import 'package:expense_tracker/features/capture/application/capture_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:meta/meta.dart';
import 'package:txn_parser/txn_parser.dart';

/// What Quick Add was opened for. At most one id is set: none to add, an
/// `editId` to edit, an `unparsedId` to resolve an Unparsed message, or a
/// `captureId` for shared text waiting in `pendingCapturesProvider`.
typedef QuickAddArgs = ({
  String? editId,
  String? unparsedId,
  String? captureId,
});

/// Opening Quick Add to add a new expense.
const QuickAddArgs newExpenseArgs = (
  editId: null,
  unparsedId: null,
  captureId: null,
);

/// How a Quick Add session ended. The screen reacts once, then closes.
sealed class QuickAddOutcome {
  const new();
}

/// A new transaction of [amount] was saved.
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

/// A one-line note about pasted or shared text.
enum QuickAddNotice {
  /// The clipboard had no text.
  clipboardEmpty,

  /// The text had no amount.
  noAmount,

  /// The text is about money but is not a payment (see `droppedClass`).
  notAPayment,

  /// The text could not be read; it is on the Unparsed list.
  unparsed,

  /// This payment was already added.
  duplicate,
}

/// What the Quick Add screen shows.
@immutable
final class QuickAddState {
  /// Creates the state.
  const new({
    required this.categories,
    required this.incomeCategories,
    required this.earliestDate,
    required this.latestDate,
    this.kind = TransactionKind.expense,
    this.amount = KeypadAmount.empty,
    this.categoryId,
    this.occurredAt,
    this.note = '',
    this.draft,
    this.notice,
    this.droppedClass,
    this.unparsedId,
    this.editing,
    this.isMissing = false,
    this.isSaving = false,
    this.rejectCount = 0,
    this.failure,
    this.outcome,
  });

  /// How many categories Quick Add shows before "More".
  static const int quickPickCount = 7;

  /// Expense categories, most used first.
  final List<Category> categories;

  /// Categories for money in (Salary, Other income).
  final List<Category> incomeCategories;

  /// The earliest date the date picker offers.
  final DateTime earliestDate;

  /// The latest date the date picker offers: today.
  final DateTime latestDate;

  /// Expense, money in or refund.
  final TransactionKind kind;

  /// The amount typed so far.
  final KeypadAmount amount;

  /// The chosen category (edit mode), or null.
  final String? categoryId;

  /// The chosen local date and time, or null for "now".
  final DateTime? occurredAt;

  /// The note typed so far.
  final String note;

  /// What a pasted or shared message proposed, if any.
  final CaptureDraft? draft;

  /// A note about pasted or shared text, if any.
  final QuickAddNotice? notice;

  /// For [QuickAddNotice.notAPayment], what the message was.
  final MessageClass? droppedClass;

  /// The Unparsed message this resolves, if any.
  final String? unparsedId;

  /// The transaction being edited, or null when adding.
  final MoneyTransaction? editing;

  /// Whether the transaction to edit no longer exists.
  final bool isMissing;

  /// Whether a save or delete is in flight.
  final bool isSaving;

  /// Counts rejected taps, so the screen can shake once per rejection.
  final int rejectCount;

  /// The last failed save, shown inline until the next attempt.
  final StoreFailure? failure;

  /// Set once when the session ends.
  final QuickAddOutcome? outcome;

  /// Whether an existing transaction is being edited.
  bool get isEditing => editing != null;

  /// Whether the amount can be saved.
  bool get canSave => amount.isValid && !isSaving;

  /// The categories that fit [kind].
  List<Category> get categoriesForKind =>
      kind == TransactionKind.income ? incomeCategories : categories;

  /// The categories shown as tiles: the most used, always including the
  /// selected one.
  List<Category> get quickPicks {
    final all = categoriesForKind;
    final picks = all.take(quickPickCount).toList();
    final selected = categoryId;
    if (selected != null && !picks.any((c) => c.id == selected)) {
      final match = all.where((c) => c.id == selected);
      if (match.isNotEmpty) picks[picks.length - 1] = match.first;
    }
    return picks;
  }

  /// Whether a "More" tile is needed.
  bool get hasMore => categoriesForKind.length > quickPickCount;

  /// A copy with the given fields replaced. The failure and notice are
  /// cleared unless passed, because any new input makes them stale.
  QuickAddState copyWith({
    TransactionKind? kind,
    KeypadAmount? amount,
    String? categoryId,
    DateTime? occurredAt,
    String? note,
    CaptureDraft? draft,
    QuickAddNotice? notice,
    MessageClass? droppedClass,
    bool? isSaving,
    int? rejectCount,
    StoreFailure? failure,
    QuickAddOutcome? outcome,
  }) {
    return QuickAddState(
      categories: categories,
      incomeCategories: incomeCategories,
      earliestDate: earliestDate,
      latestDate: latestDate,
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note ?? this.note,
      draft: draft ?? this.draft,
      notice: notice,
      droppedClass: droppedClass,
      unparsedId: unparsedId,
      editing: editing,
      isMissing: isMissing,
      isSaving: isSaving ?? this.isSaving,
      rejectCount: rejectCount ?? this.rejectCount,
      failure: failure,
      outcome: outcome ?? this.outcome,
    );
  }
}

/// The Quick Add view model. Adds a cash expense in two steps (amount,
/// then category); edits or deletes a transaction; fills itself from a
/// pasted or shared message; or resolves an Unparsed message.
class QuickAddNotifier extends AsyncNotifier<QuickAddState> {
  /// Creates the notifier for [args].
  new(this.args);

  /// What Quick Add was opened for.
  final QuickAddArgs args;

  /// How many years back the date picker reaches.
  static const int firstYearsBack = 5;

  /// How far back category use is counted to order the tiles.
  static const int usageWindowDays = 90;

  @override
  Future<QuickAddState> build() async {
    final base = await _base();
    final editId = args.editId;
    if (editId != null) {
      final txn = await ref
          .read(transactionRepositoryProvider)
          .findById(editId);
      if (txn == null) return _missing(base);
      return QuickAddState(
        categories: base.categories,
        incomeCategories: base.incomeCategories,
        earliestDate: base.earliestDate,
        latestDate: base.latestDate,
        kind: txn.kind,
        amount: KeypadAmount.fromMoney(txn.amount),
        categoryId: txn.categoryId,
        occurredAt: txn.occurredAt.toLocal(),
        note: txn.note ?? '',
        editing: txn,
      );
    }
    final unparsedId = args.unparsedId;
    if (unparsedId != null) {
      final item = await ref
          .read(captureRepositoryProvider)
          .findUnparsed(unparsedId);
      if (item == null) return _missing(base);
      final parsed = ref.read(txnParserProvider).parse(item.maskedText);
      final paise = switch (parsed) {
        ParsedTransaction(:final fields) => fields.amountPaise,
        UnparsedMessage(:final amountPaise) => amountPaise,
        DroppedMessage() || NoAmount() => null,
      };
      return QuickAddState(
        categories: base.categories,
        incomeCategories: base.incomeCategories,
        earliestDate: base.earliestDate,
        latestDate: base.latestDate,
        amount: paise == null
            ? KeypadAmount.empty
            : KeypadAmount.fromMoney(Money(paise)),
        occurredAt: item.receivedAt.toLocal(),
        unparsedId: unparsedId,
      );
    }
    final captureId = args.captureId;
    if (captureId != null) {
      final capture = ref
          .read(pendingCapturesProvider.notifier)
          .take(captureId);
      if (capture != null) return await _applyIngestion(base, capture);
    }
    return base;
  }

  // Categories and date bounds every mode starts from. Read once: a change
  // mid-entry must not reset typed input.
  Future<QuickAddState> _base() async {
    final all = await ref.read(categoriesProvider.future);
    final today = ref.read(clockProvider).now().toLocal();
    final usage = await ref
        .read(transactionRepositoryProvider)
        .categoryUsageSince(
          today.toUtc().subtract(const Duration(days: usageWindowDays)),
        );
    final expense =
        [
          for (final c in all)
            if (c.kind == CategoryKind.expense && !c.isArchived) c,
        ]..sort((a, b) {
          final byUse = (usage[b.id] ?? 0).compareTo(usage[a.id] ?? 0);
          return byUse != 0 ? byUse : a.sortOrder.compareTo(b.sortOrder);
        });
    final latest = DateTime(today.year, today.month, today.day);
    return QuickAddState(
      categories: expense,
      incomeCategories: [
        for (final c in all)
          if (_incomeCategoryIds.contains(c.id)) c,
      ],
      earliestDate: DateTime(latest.year - firstYearsBack),
      latestDate: latest,
    );
  }

  static const Set<String> _incomeCategoryIds = {
    'cat_salary',
    'cat_other_income',
  };

  QuickAddState _missing(QuickAddState base) => QuickAddState(
    categories: base.categories,
    incomeCategories: base.incomeCategories,
    earliestDate: base.earliestDate,
    latestDate: base.latestDate,
    isMissing: true,
  );

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

  /// Reads a payment message from the clipboard and fills the form from it.
  void paste() => unawaited(_paste());

  Future<void> _paste() async {
    final text = await ref.read(clipboardProvider).readText();
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null || current.isSaving) return;
    if (text == null || text.trim().isEmpty) {
      ref.read(hapticsProvider).reject();
      state = AsyncData(
        current.copyWith(notice: QuickAddNotice.clipboardEmpty),
      );
      return;
    }
    final capture = RawCapture(
      id: ref.read(idGeneratorProvider).newId(),
      source: CaptureSource.paste,
      text: text,
      receivedAt: ref.read(clockProvider).now().toUtc(),
    );
    final next = await _applyIngestion(current, capture);
    if (!ref.mounted) return;
    ref.read(hapticsProvider).select();
    state = AsyncData(next);
  }

  // Parses [capture] and returns [current] filled from it, or with a note
  // saying why it could not be.
  Future<QuickAddState> _applyIngestion(
    QuickAddState current,
    RawCapture capture,
  ) async {
    final result = await ref.read(captureIngestionProvider).ingest(capture);
    return switch (result) {
      Err(:final failure) => current.copyWith(failure: failure),
      Ok(:final value) => switch (value) {
        IngestedDraft(:final draft) => current.copyWith(
          draft: draft,
          kind: draft.kind,
          amount: KeypadAmount.fromMoney(draft.amount),
          occurredAt: draft.occurredAt,
        ),
        IngestedDropped(:final messageClass) => current.copyWith(
          notice: QuickAddNotice.notAPayment,
          droppedClass: messageClass,
        ),
        IngestedUnparsed(:final amount) => current.copyWith(
          notice: QuickAddNotice.unparsed,
          amount: amount == null ? null : KeypadAmount.fromMoney(amount),
        ),
        IngestedDuplicate() => current.copyWith(
          notice: QuickAddNotice.duplicate,
        ),
        IngestedNoAmount() => current.copyWith(notice: QuickAddNotice.noAmount),
      },
    };
  }

  /// Picks a category. When adding, this saves the transaction; when
  /// editing, it only selects, and [save] commits.
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
      state = AsyncData(current.copyWith(rejectCount: current.rejectCount + 1));
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

  Future<void> _persist(QuickAddState s) {
    final repository = ref.read(transactionRepositoryProvider);
    final money = s.amount.money;
    final txn = s.editing;
    final draft = s.draft;
    if (txn != null) {
      return _run(
        s,
        () => repository.edit(
          txn,
          amount: money,
          occurredAt: s.occurredAt ?? txn.occurredAt,
          accountId: txn.accountId,
          categoryId: s.categoryId,
          note: s.note,
        ),
        (_) => const ExpenseUpdated(),
      );
    }
    if (draft != null) {
      return _run(
        s,
        () => repository.addFromCapture(
          draft: draft,
          amount: money,
          kind: s.kind,
          categoryId: s.categoryId,
          occurredAt: s.occurredAt,
          note: s.note,
        ),
        (saved) => ExpenseAdded(saved.amount),
      );
    }
    return _run(
      s,
      () => repository.addExpense(
        amount: money,
        accountId: Account.cashId,
        categoryId: s.categoryId,
        kind: s.kind,
        occurredAt: s.occurredAt,
        note: s.note,
        unparsedId: s.unparsedId,
      ),
      (saved) => ExpenseAdded(saved.amount),
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

/// Provides [QuickAddNotifier], keyed by what it was opened for.
final AsyncNotifierProviderFamily<QuickAddNotifier, QuickAddState, QuickAddArgs>
quickAddNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<QuickAddNotifier, QuickAddState, QuickAddArgs>(
      QuickAddNotifier.new,
    );
