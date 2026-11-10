import 'package:expense_tracker/features/home/presentation/home_screen.dart';
import 'package:expense_tracker/features/quick_add/presentation/quick_add_screen.dart';
import 'package:expense_tracker/features/settings/presentation/settings_screen.dart';
import 'package:expense_tracker/features/transactions/presentation/transactions_screen.dart';
import 'package:expense_tracker/routing/app_shell.dart';
import 'package:expense_tracker/routing/not_found_screen.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The app's single router.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.home,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.transactions,
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.addExpense,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: QuickAddScreen()),
      ),
      GoRoute(
        path: Routes.transactionPattern,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: QuickAddScreen(editId: state.pathParameters['id']),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
