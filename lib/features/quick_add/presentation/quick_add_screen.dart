import 'dart:async';

import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/features/quick_add/presentation/quick_add_notifier.dart';
import 'package:expense_tracker/features/quick_add/presentation/undo_delete_notifier.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/note_dialog.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/quick_add_form.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/widgets/category/all_categories_sheet.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/room_picker_sheet.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Quick Add: keypad first, then a category tap saves a cash expense.
/// [args] can instead open it to edit a transaction, to resolve an
/// Unparsed message, or to finish a shared message.
class QuickAddScreen extends ConsumerWidget {
  /// Creates the screen for [args].
  const new({this.args = newExpenseArgs, super.key});

  /// What Quick Add was opened for.
  final QuickAddArgs args;

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
    final notifier = ref.read(quickAddNotifierProvider(args).notifier);
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
    final notifier = ref.read(quickAddNotifierProvider(args).notifier);
    final note = await showDialog<String>(
      context: context,
      builder: (_) => NoteDialog(initialNote: state.note),
    );
    // Null means cancelled: keep the note.
    if (note != null) notifier.setNote(note);
  }

  Future<void> _pickRoom(
    BuildContext context,
    WidgetRef ref,
    QuickAddState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(quickAddNotifierProvider(args).notifier);
    final picked = await showAppSheet<RoomPick>(
      context,
      RoomPickerSheet(
        title: l10n.quickAddPickRoom,
        rooms: state.rooms,
        selectedId: state.roomId,
      ),
    );
    // Null means dismissed: keep the Room.
    if (picked != null) notifier.setRoom(picked.roomId);
  }

  Future<void> _showAllCategories(
    BuildContext context,
    WidgetRef ref,
    QuickAddState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(quickAddNotifierProvider(args).notifier);
    final picked = await showAppSheet<String>(
      context,
      AllCategoriesSheet(
        title: l10n.quickAddAllCategories,
        categories: state.categoriesForKind,
        selectedId: state.categoryId,
        selectedLabel: l10n.selected,
      ),
    );
    // Null means dismissed: nothing picked.
    if (picked != null) notifier.pickCategory(picked);
  }

  String _title(AppLocalizations l10n, QuickAddState? state) {
    if (args.editId != null) return l10n.quickAddEditTitle;
    return switch (state?.kind) {
      TransactionKind.income => l10n.quickAddIncomeTitle,
      TransactionKind.refund => l10n.quickAddRefundTitle,
      TransactionKind.expense ||
      TransactionKind.transfer ||
      null => l10n.quickAddTitle,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final provider = quickAddNotifierProvider(args);
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
        onMore: () => unawaited(_showAllCategories(context, ref, state)),
        onPickDate: () => unawaited(_pickDate(context, ref, state)),
        onEditNote: () => unawaited(_editNote(context, ref, state)),
        onPickRoom: () => unawaited(_pickRoom(context, ref, state)),
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
      body = Center(child: PulsingPlaceholder(semanticLabel: l10n.loading));
    }
    final canDelete = state != null && state.isEditing && !state.isSaving;
    // Every way out (Close, Go back, the back gesture, saving) pops this
    // route, so the shared text is released in one place.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) notifier.releaseCapture();
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: metrics.readableWidth),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: metrics.spaceLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        RoundIconButton(
                          icon: Icons.close_rounded,
                          tooltip: l10n.close,
                          floating: false,
                          color: colors.onSurface,
                          onPressed: context.pop,
                        ),
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(
                              _title(l10n, state),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                        if (args.editId != null)
                          RoundIconButton(
                            icon: Icons.delete_outline_rounded,
                            tooltip: l10n.delete,
                            floating: false,
                            color: colors.danger,
                            onPressed: canDelete ? notifier.delete : null,
                          )
                        else if (args.unparsedId == null)
                          RoundIconButton(
                            icon: Icons.content_paste_rounded,
                            tooltip: l10n.quickAddPaste,
                            floating: false,
                            color: colors.accent,
                            onPressed: state == null || state.isSaving
                                ? null
                                : notifier.paste,
                          )
                        else
                          SizedBox.square(dimension: metrics.minTapTarget),
                      ],
                    ),
                    Expanded(child: body),
                    SizedBox(height: metrics.spaceSm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
