import 'package:expense_tracker/features/quick_add/presentation/quick_add_notifier.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/amount_display.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/capture_draft_card.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/keypad.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/pill_button.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/l10n/notice_messages.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/category/category_grid.dart';
import 'package:flutter/material.dart';

/// The Quick Add layout: big amount, Cash/date/note pills, the most-used
/// categories, and the keypad. Renders [state] and reports taps.
class QuickAddForm extends StatelessWidget {
  /// Creates the form.
  const new({
    required this.state,
    required this.onDigit,
    required this.onPoint,
    required this.onBackspace,
    required this.onPickCategory,
    required this.onMore,
    required this.onPickDate,
    required this.onEditNote,
    required this.onSave,
    super.key,
  });

  /// What to show.
  final QuickAddState state;

  /// Called with the digit pressed.
  final ValueChanged<int> onDigit;

  /// Called when the decimal point is pressed.
  final VoidCallback onPoint;

  /// Called when backspace is pressed.
  final VoidCallback onBackspace;

  /// Called with the category id tapped.
  final ValueChanged<String> onPickCategory;

  /// Opens every category.
  final VoidCallback onMore;

  /// Opens the date picker.
  final VoidCallback onPickDate;

  /// Opens the note editor.
  final VoidCallback onEditNote;

  /// Saves the edits (edit mode).
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final locale = Localizations.localeOf(context).toString();
    final amountText = formatTypedAmount(
      state.amount.wholeDigits,
      state.amount.fractionDigits,
    );
    final occurredAt = state.occurredAt;
    final account = state.draft?.accountLabel ?? l10n.quickAddCash;
    final date = occurredAt == null
        ? l10n.quickAddToday
        : formatShortDate(occurredAt, locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: metrics.spaceXl),
                AmountDisplay(
                  amountText: amountText,
                  semanticLabel: l10n.quickAddAmountSemantics(amountText),
                  rejectCount: state.rejectCount,
                ),
                SizedBox(height: metrics.spaceMd),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: metrics.spaceSm,
                  runSpacing: metrics.spaceSm,
                  children: [
                    PillButton(
                      icon: Icons.payments_rounded,
                      label: account,
                      semanticLabel: account,
                    ),
                    PillButton(
                      icon: Icons.event_rounded,
                      label: date,
                      semanticLabel: l10n.quickAddDateLabel(date),
                      onTap: onPickDate,
                    ),
                    PillButton(
                      icon: Icons.notes_rounded,
                      label: state.note.isEmpty
                          ? l10n.quickAddNote
                          : state.note,
                      semanticLabel: state.note.isEmpty
                          ? l10n.quickAddNote
                          : l10n.quickAddNoteLabel(state.note),
                      onTap: onEditNote,
                    ),
                  ],
                ),
                if (state.draft case final draft?) ...[
                  SizedBox(height: metrics.spaceMd),
                  CaptureDraftCard(draft: draft),
                ],
                SizedBox(height: metrics.spaceLg),
                _Guidance(state: state),
                SizedBox(height: metrics.spaceMd),
                CategoryGrid(
                  categories: state.quickPicks,
                  selectedId: state.categoryId,
                  selectedLabel: l10n.selected,
                  onPick: onPickCategory,
                  moreLabel: state.hasMore ? l10n.quickAddMore : null,
                  onMore: state.hasMore ? onMore : null,
                ),
                SizedBox(height: metrics.spaceMd),
              ],
            ),
          ),
        ),
        Keypad(
          onDigit: onDigit,
          onPoint: onPoint,
          onBackspace: onBackspace,
          pointLabel: l10n.keypadPoint,
          backspaceLabel: l10n.keypadBackspace,
        ),
        if (state.isEditing)
          Padding(
            padding: EdgeInsetsDirectional.only(top: metrics.spaceSm),
            child: FilledButton(
              onPressed: state.canSave ? onSave : null,
              child: Text(l10n.save),
            ),
          ),
      ],
    );
  }
}

/// The line under the pills: a save failure, a hint, or nothing.
class _Guidance extends StatelessWidget {
  const new({required this.state});

  final QuickAddState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final failure = state.failure;
    final notice = state.notice;
    if (failure == null && notice != null) {
      return Semantics(
        liveRegion: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded, color: colors.accent),
            SizedBox(width: metrics.spaceSm),
            Flexible(
              child: Text(
                noticeText(l10n, notice, state.droppedClass),
                style: textTheme.bodySmall?.copyWith(color: colors.onSurface),
              ),
            ),
          ],
        ),
      );
    }
    if (failure != null) {
      return Semantics(
        liveRegion: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.danger),
            SizedBox(width: metrics.spaceSm),
            Flexible(
              child: Text(
                failureMessage(l10n, failure),
                style: textTheme.bodySmall?.copyWith(color: colors.danger),
              ),
            ),
          ],
        ),
      );
    }
    final String? hint;
    if (!state.amount.isValid) {
      hint = l10n.quickAddAmountHint;
    } else {
      hint = state.isEditing ? null : l10n.quickAddPickCategory;
    }
    if (hint == null) return const SizedBox.shrink();
    // After a rejected tap the hint is the message: an icon and colour
    // join the words (colour is never the only sign).
    final rejected = state.rejectCount > 0 && !state.amount.isValid;
    final text = Text(
      hint,
      textAlign: TextAlign.center,
      style: textTheme.bodySmall?.copyWith(
        color: rejected ? colors.danger : colors.onSurfaceMuted,
      ),
    );
    if (!rejected) return text;
    return Semantics(
      liveRegion: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: colors.danger),
          SizedBox(width: metrics.spaceSm),
          Flexible(child: text),
        ],
      ),
    );
  }
}
