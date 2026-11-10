import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Edits the note. Pops with the text, or null when cancelled.
class NoteDialog extends StatefulWidget {
  /// Creates the dialog showing [initialNote].
  const new({required this.initialNote, super.key});

  /// The note to start from.
  final String initialNote;

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialNote,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.quickAddNote),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: MoneyTransaction.noteMaxLength,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(hintText: l10n.quickAddNoteHint),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
