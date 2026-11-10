import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Lets the user pick the day a month starts on. Pops with the chosen day,
/// or null when dismissed.
class MonthStartDayDialog extends StatelessWidget {
  /// Creates the dialog with [selectedDay] marked.
  const new({required this.selectedDay, super.key});

  /// The currently saved day.
  final int selectedDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleDialog(
      title: Text(l10n.settingsMonthStart),
      children: [
        for (var day = 1; day <= MonthPeriod.maxStartDaySetting; day++)
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(day),
            child: Row(
              children: [
                Expanded(child: Text(l10n.settingsMonthStartValue(day))),
                if (day == selectedDay)
                  Icon(Icons.check, semanticLabel: l10n.selected),
              ],
            ),
          ),
      ],
    );
  }
}
