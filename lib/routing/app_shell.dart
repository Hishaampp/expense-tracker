import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/window_size_class.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The tab shell: a bottom bar on phones, a side rail on wider windows.
class AppShell extends StatelessWidget {
  /// Wraps the active branch in the navigation chrome.
  const new({required this.navigationShell, super.key});

  /// The branch container supplied by the router.
  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sizeClass = windowSizeClassFor(MediaQuery.sizeOf(context).width);
    final destinations = [
      (Icons.home_outlined, l10n.navHome),
      (Icons.receipt_long_outlined, l10n.navTransactions),
      (Icons.settings_outlined, l10n.navSettings),
    ];
    if (sizeClass == WindowSizeClass.compact) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _select,
          destinations: [
            for (final (icon, label) in destinations)
              NavigationDestination(icon: Icon(icon), label: label),
          ],
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final (icon, label) in destinations)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    label: Text(label),
                  ),
              ],
            ),
            const VerticalDivider(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}
