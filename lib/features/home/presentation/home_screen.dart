import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Home (month view). Phase 0 placeholder: the empty state only. The real
/// layout is agreed with the owner in Phase 1 (spec §11.1 B).
class HomeScreen extends StatelessWidget {
  /// Creates the Home screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.homeEmptyTitle, style: textTheme.titleLarge),
              Text(l10n.homeEmptyBody, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
