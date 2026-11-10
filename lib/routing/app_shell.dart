import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/floating_tab_bar.dart';
import 'package:expense_tracker/routing/window_size_class.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The tab shell: a floating pill tab bar on phones, a side rail on wider
/// windows.
class AppShell extends ConsumerWidget {
  /// Wraps [body] (the branch container) in the navigation chrome.
  const new({required this.navigationShell, required this.body, super.key});

  /// The router's branch state.
  final StatefulNavigationShell navigationShell;

  /// The branch container to show.
  final Widget body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sizeClass = windowSizeClassFor(MediaQuery.sizeOf(context).width);
    final destinations = <TabDestination>[
      (
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: l10n.navHome,
      ),
      (
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long_rounded,
        label: l10n.navActivity,
      ),
      (
        icon: Icons.luggage_outlined,
        selectedIcon: Icons.luggage_rounded,
        label: l10n.navRooms,
      ),
      (
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        label: l10n.navSettings,
      ),
    ];
    void select(int index) {
      if (index != navigationShell.currentIndex) {
        ref.read(hapticsProvider).select();
      }
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    if (sizeClass == WindowSizeClass.compact) {
      return Scaffold(
        extendBody: true,
        body: body,
        bottomNavigationBar: FloatingTabBar(
          destinations: destinations,
          selectedIndex: navigationShell.currentIndex,
          onSelect: select,
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: select,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final tab in destinations)
                  NavigationRailDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
                    label: Text(tab.label),
                  ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
