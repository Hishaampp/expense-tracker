import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';

/// Lets the user pick the day a month starts on, as a grid of round day
/// buttons. Pops with the chosen day, or null when dismissed.
class MonthStartDaySheet extends StatelessWidget {
  /// Creates the sheet with [selectedDay] marked.
  const new({required this.selectedDay, super.key});

  /// The currently saved day.
  final int selectedDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    return SheetFrame(
      title: l10n.settingsMonthStart,
      subtitle: l10n.settingsMonthStartHelp,
      spreadContent: true,
      child: Wrap(
        spacing: metrics.spaceSm,
        runSpacing: metrics.spaceSm,
        children: [
          for (var day = 1; day <= MonthPeriod.maxStartDaySetting; day++)
            _DayButton(
              day: day,
              selected: day == selectedDay,
              semanticLabel: l10n.settingsMonthStartValue(day),
            ),
        ],
      ),
    );
  }
}

/// Opens the day picker; returns the chosen day, or null when dismissed.
Future<int?> showMonthStartDaySheet(BuildContext context, int selectedDay) {
  return showAppSheet<int>(
    context,
    MonthStartDaySheet(selectedDay: selectedDay),
  );
}

class _DayButton extends StatelessWidget {
  const new({
    required this.day,
    required this.selected,
    required this.semanticLabel,
  });

  final int day;
  final bool selected;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    void choose() => Navigator.of(context).pop(day);
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      onTap: choose,
      child: ExcludeSemantics(
        child: Material(
          color: selected ? colors.accentFill : colors.surfaceSunken,
          shape: const CircleBorder(),
          child: Pressable(
            onTap: choose,
            shape: const CircleBorder(),
            child: SizedBox.square(
              dimension: metrics.minTapTarget,
              child: Center(
                child: Text(
                  '$day',
                  // Selected: filled and bold, not colour alone.
                  style:
                      (selected
                              ? Theme.of(context).textTheme.titleMedium
                              : Theme.of(context).textTheme.labelLarge)
                          ?.copyWith(
                            color: selected
                                ? colors.onAccentFill
                                : colors.onSurface,
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
