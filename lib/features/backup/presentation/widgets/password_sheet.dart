import 'package:expense_tracker/data/backup/backup_codec.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';

/// Asks for the backup password: twice, with a minimum length, when
/// [isNew]; once to open a backup. Pops the password, or null when
/// dismissed. The password is never stored or logged.
class PasswordSheet extends StatefulWidget {
  /// Creates the sheet.
  const new({required this.isNew, super.key});

  /// Whether a new password is being set.
  final bool isNew;

  @override
  State<PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<PasswordSheet> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _repeat = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  void _done() {
    if (_form.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SheetFrame(
        title: widget.isNew ? l10n.backupPasswordNew : l10n.backupPasswordOpen,
        spreadContent: true,
        child: Form(
          key: _form,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _password,
                autofocus: true,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                autofillHints: [
                  if (widget.isNew)
                    AutofillHints.newPassword
                  else
                    AutofillHints.password,
                ],
                textInputAction: widget.isNew
                    ? TextInputAction.next
                    : TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.backupPasswordLabel,
                ),
                validator: (text) =>
                    widget.isNew &&
                        (text ?? '').length < BackupCodec.minPasswordLength
                    ? l10n.backupPasswordShort(BackupCodec.minPasswordLength)
                    : null,
                onFieldSubmitted: widget.isNew ? null : (_) => _done(),
              ),
              if (widget.isNew) ...[
                SizedBox(height: metrics.spaceMd),
                TextFormField(
                  controller: _repeat,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.backupPasswordRepeat,
                  ),
                  validator: (text) => text != _password.text
                      ? l10n.backupPasswordMismatch
                      : null,
                  onFieldSubmitted: (_) => _done(),
                ),
              ],
              SizedBox(height: metrics.spaceLg),
              FilledButton(onPressed: _done, child: Text(l10n.backupContinue)),
            ],
          ),
        ),
      ),
    );
  }
}
