import 'dart:async';

import 'package:expense_tracker/features/quick_add/presentation/quick_add_notifier.dart';
import 'package:expense_tracker/features/quick_add/presentation/undo_delete_notifier.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/note_dialog.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/quick_add_form.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/ledger_skeleton.dart';
import 'package:expense_tracker/widgets/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Quick Add: keypad first, then a category tap saves a cash expense.
/// With an [editId] it edits or deletes that transaction instead.
class QuickAddScreen extends ConsumerWidget {
  /// Creates the screen; pass [editId] to edit an existing transaction.
  const new({this.editId, super.key});

  /// Id of the transaction to edit, or null to add a new one.
  final String? editId;

  void _onOutcome(BuildContext context, WidgetRef ref, QuickAddOutcome done) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context)..clearSnackBars();
    final motion = AppMotion.of(context);
    final window = MediaQuery.accessibleNavigationOf(context)
        ? motion.undoWindowAccessible
        : motion.undoWindow;
    final undo = ref.read(undoDeleteProvider.notifier);
    switch (done) {
      // Home already shows the new row, so a snackbar would only cover the
      // Add expense button. Tell screen readers instead.
      case ExpenseAdded(:final amount):
        _announce(context, l10n.quickAddSaved(formatMoney(amount)));
      case ExpenseUpdated():
        _announce(context, l10n.quickAddUpdated);
      case ExpenseDeleted(:final deleted):
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.quickAddDeleted),
            duration: window,
            action: SnackBarAction(
              label: l10n.undo,
              onPressed: () => undo.restore(deleted),
            ),
          ),
        );
    }
    context.pop();
  }

  static void _announce(BuildContext context, String message) {
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        message,
        Directionality.of(context),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    QuickAddState state,
  ) async {
    final notifier = ref.read(quickAddNotifierProvider(editId).notifier);
    final picked = await showDatePicker(
      context: context,
      initialDate: state.occurredAt ?? state.latestDate,
      firstDate: state.earliestDate,
      lastDate: state.latestDate,
    );
    // Null means dismissed: keep the date.
    if (picked != null) notifier.setDate(picked);
  }

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref,
    QuickAddState state,
  ) async {
    final notifier = ref.read(quickAddNotifierProvider(editId).notifier);
    final note = await showDialog<String>(
      context: context,
      builder: (_) => NoteDialog(initialNote: state.note),
    );
    // Null means cancelled: keep the note.
    if (note != null) notifier.setNote(note);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = quickAddNotifierProvider(editId);
    ref.listen(provider.select((s) => s.value?.outcome), (previous, next) {
      if (next != null) _onOutcome(context, ref, next);
    });
    final async = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final state = async.value;

    final Widget body;
    if (state != null && !state.isMissing) {
      body = QuickAddForm(
        state: state,
        onDigit: notifier.digit,
        onPoint: notifier.point,
        onBackspace: notifier.backspace,
        onPickCategory: notifier.pickCategory,
        onPickDate: () => unawaited(_pickDate(context, ref, state)),
        onEditNote: () => unawaited(_editNote(context, ref, state)),
        onSave: notifier.save,
      );
    } else if (state != null) {
      body = Center(
        child: ErrorStateView(
          message: l10n.quickAddMissing,
          actionLabel: l10n.quickAddBack,
          onAction: context.pop,
        ),
      );
    } else if (async.hasError) {
      body = Center(
        child: ErrorStateView(
          message: l10n.failureLoad,
          actionLabel: l10n.tryAgain,
          onAction: () => ref.invalidate(provider),
        ),
      );
    } else {
      body = LedgerSkeleton(semanticLabel: l10n.loading, rowCount: 3);
    }
    final canDelete = state != null && state.isEditing && !state.isSaving;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          tooltip: l10n.close,
          icon: const Icon(Icons.close),
        ),
        title: Text(
          editId == null ? l10n.quickAddTitle : l10n.quickAddEditTitle,
        ),
        actions: [
          if (editId != null)
            IconButton(
              onPressed: canDelete ? notifier.delete : null,
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: PageFrame(child: body),
    );
  }
}
