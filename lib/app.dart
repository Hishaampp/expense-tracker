import 'package:expense_tracker/core/app_identity.dart';
import 'package:expense_tracker/core/models/appearance_mode.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/features/capture/application/capture_inbox.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/app_router.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget: theme, localization and the router.
class App extends ConsumerWidget {
  /// Creates the root widget.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = switch (ref.watch(appearanceProvider)) {
      AsyncData(:final value) => value,
      _ => ref.watch(initialAppearanceProvider),
    };
    return MaterialApp.router(
      title: appDisplayName,
      routerConfig: ref.watch(routerProvider),
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: switch (appearance) {
        AppearanceMode.system => ThemeMode.system,
        AppearanceMode.light => ThemeMode.light,
        AppearanceMode.dark => ThemeMode.dark,
      },
      themeAnimationStyle: AnimationStyle.noAnimation,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          CaptureInbox(child: child ?? const SizedBox.shrink()),
    );
  }
}
