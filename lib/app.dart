import 'package:expense_tracker/core/app_identity.dart';
import 'package:expense_tracker/features/home/presentation/home_screen.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Root widget: localization and (from Phase 1) theme and router wiring.
class App extends StatelessWidget {
  /// Creates the root widget.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: appDisplayName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeScreen(),
    );
  }
}
