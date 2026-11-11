import 'package:expense_tracker/core/budget_input.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// What the amount sheet returns: the new amount, or null to remove the
/// budget. The sheet itself pops null when dismissed.
typedef BudgetEdit = ({Money? amount});

/// A sheet to type a whole-rupee budget. Offers "Remove budget" when one
/// is already set.
class BudgetAmountSheet extends StatefulWidget {
  /// Creates the sheet.
  const new({required this.title, this.current, super.key});

  /// The sheet's heading.
  final String title;

  /// The budget now, if any.
  final Money? current;

  @override
  State<BudgetAmountSheet> createState() => _BudgetAmountSheetState();
}

class _BudgetAmountSheetState extends State<BudgetAmountSheet> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final TextEditingController _amount = TextEditingController(
    text: widget.current == null ? '' : '${widget.current!.wholeRupees}',
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop<BudgetEdit>((amount: parseBudget(_amount.text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    return Padding(
      // Stays above the keyboard.
      padding: EdgeInsetsDirectional.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SheetFrame(
        title: widget.title,
        spreadContent: true,
        child: Form(
          key: _form,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amount,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(maxBudgetDigits),
                ],
                decoration: InputDecoration(
                  labelText: l10n.budgetsAmountLabel,
                  prefixText: rupeeFieldPrefix,
                ),
                validator: (text) => parseBudget(text ?? '') == null
                    ? l10n.budgetsAmountInvalid
                    : null,
                onFieldSubmitted: (_) => _save(),
              ),
              SizedBox(height: metrics.spaceLg),
              FilledButton(onPressed: _save, child: Text(l10n.budgetsSave)),
              if (widget.current != null) ...[
                SizedBox(height: metrics.spaceSm),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop<BudgetEdit>((amount: null)),
                  child: Text(l10n.budgetsRemove),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
