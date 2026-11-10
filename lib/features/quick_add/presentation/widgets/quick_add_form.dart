import 'package:expense_tracker/features/quick_add/presentation/quick_add_notifier.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/amount_display.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/category_chips.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/keypad.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';

/// The Quick Add layout: amount, categories, details, keypad (agreed
/// 2026-11-10). Renders [state] and reports taps; holds no logic.
class QuickAddForm extends StatelessWidget {
  /// Creates the form.
  const new({
    required this.state,
    required this.onDigit,
    required this.onPoint,
    required this.onBackspace,
    required this.onPickCategory,
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

  /// Called when the date chip is tapped.
  final VoidCallback onPickDate;

  /// Called when the note chip is tapped.
  final VoidCallback onEditNote;

  /// Called when Save is pressed (edit mode).
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
    final failure = state.failure;
    final occurredAt = state.occurredAt;
    final String? helper;
    if (!state.amount.isValid) {
      helper = l10n.quickAddAmountHint;
    } else {
      helper = state.isEditing ? null : l10n.quickAddPickCategory;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Amount and categories scroll together, so the keypad always
        // fits, even on a small phone at the largest text size.
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: metrics.spaceLg),
                AmountDisplay(
                  amountText: amountText,
                  semanticLabel: l10n.quickAddAmountSemantics(amountText),
                  helperText: helper,
                  errorText: failure == null
                      ? null
                      : failureMessage(l10n, failure),
                ),
                SizedBox(height: metrics.spaceLg),
                CategoryChips(
                  categories: state.categories,
                  selectedId: state.categoryId,
                  onPick: onPickCategory,
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        Wrap(
          spacing: metrics.spaceSm,
          children: [
            ActionChip(
              avatar: const Icon(Icons.event_outlined),
              label: Text(
                occurredAt == null
                    ? l10n.quickAddToday
                    : formatShortDate(occurredAt, locale),
              ),
              tooltip: l10n.quickAddDateLabel(
                occurredAt == null
                    ? l10n.quickAddToday
                    : formatShortDate(occurredAt, locale),
              ),
              onPressed: onPickDate,
            ),
            ActionChip(
              avatar: const Icon(Icons.notes),
              label: Text(state.note.isEmpty ? l10n.quickAddNote : state.note),
              tooltip: state.note.isEmpty
                  ? l10n.quickAddNote
                  : l10n.quickAddNoteLabel(state.note),
              onPressed: onEditNote,
            ),
          ],
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
            padding: EdgeInsetsDirectional.symmetric(vertical: metrics.spaceSm),
            child: FilledButton(
              onPressed: state.canSave ? onSave : null,
              child: Text(l10n.save),
            ),
          ),
      ],
    );
  }
}
