import 'package:expense_tracker/core/models/appearance_mode.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';

/// The label for [mode].
String appearanceLabel(AppLocalizations l10n, AppearanceMode mode) {
  return switch (mode) {
    AppearanceMode.system => l10n.themeSystem,
    AppearanceMode.light => l10n.themeLight,
    AppearanceMode.dark => l10n.themeDark,
  };
}

/// Lets the user choose light, dark or system. Pops with the choice, or null
/// when dismissed.
class AppearanceSheet extends StatelessWidget {
  /// Creates the sheet with [selected] marked.
  const new({required this.selected, super.key});

  /// The current choice; marked with a tick.
  final AppearanceMode selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SheetFrame(
      title: l10n.settingsAppearance,
      child: Column(
        children: [
          for (final mode in AppearanceMode.values)
            Semantics(
              button: true,
              selected: mode == selected,
              label: appearanceLabel(l10n, mode),
              onTap: () => Navigator.of(context).pop(mode),
              child: ExcludeSemantics(
                child: Pressable(
                  onTap: () => Navigator.of(context).pop(mode),
                  shape: const StadiumBorder(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: metrics.minTapTarget,
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: metrics.spaceLg,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              appearanceLabel(l10n, mode),
                              style: textTheme.bodyLarge,
                            ),
                          ),
                          if (mode == selected)
                            Icon(Icons.check_rounded, color: colors.accent),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Opens the appearance choice; returns it, or null when dismissed.
Future<AppearanceMode?> showAppearanceSheet(
  BuildContext context,
  AppearanceMode selected,
) {
  return showAppSheet<AppearanceMode>(
    context,
    AppearanceSheet(selected: selected),
  );
}
