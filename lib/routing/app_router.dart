import 'package:expense_tracker/features/activity/presentation/activity_screen.dart';
import 'package:expense_tracker/features/home/presentation/home_screen.dart';
import 'package:expense_tracker/features/quick_add/presentation/quick_add_screen.dart';
import 'package:expense_tracker/features/review/presentation/review_screen.dart';
import 'package:expense_tracker/features/rooms/presentation/rooms_screen.dart';
import 'package:expense_tracker/features/settings/presentation/settings_screen.dart';
import 'package:expense_tracker/features/unparsed/presentation/unparsed_screen.dart';
import 'package:expense_tracker/routing/app_shell.dart';
import 'package:expense_tracker/routing/fading_branches.dart';
import 'package:expense_tracker/routing/not_found_screen.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The app's single router.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.home,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      StatefulShellRoute(
        builder: (context, state, shell) => shell,
        navigatorContainerBuilder: (context, shell, children) => AppShell(
          navigationShell: shell,
          body: FadingBranches(index: shell.currentIndex, children: children),
        ),
        branches: [
          _branch(Routes.home, const HomeScreen()),
          _branch(Routes.activity, const ActivityScreen()),
          _branch(Routes.rooms, const RoomsScreen()),
          _branch(Routes.settings, const SettingsScreen()),
        ],
      ),
      GoRoute(
        path: Routes.addExpense,
        pageBuilder: (context, state) =>
            _slideUpPage(context, state, const QuickAddScreen()),
      ),
      GoRoute(
        path: Routes.sharedPattern,
        pageBuilder: (context, state) => _slideUpPage(
          context,
          state,
          QuickAddScreen(
            args: (
              editId: null,
              unparsedId: null,
              captureId: state.pathParameters['id'],
            ),
          ),
        ),
      ),
      GoRoute(
        path: Routes.review,
        builder: (context, state) => const ReviewScreen(),
      ),
      GoRoute(
        path: Routes.unparsed,
        builder: (context, state) => const UnparsedScreen(),
      ),
      GoRoute(
        path: Routes.resolveUnparsedPattern,
        pageBuilder: (context, state) => _slideUpPage(
          context,
          state,
          QuickAddScreen(
            args: (
              editId: null,
              unparsedId: state.pathParameters['id'],
              captureId: null,
            ),
          ),
        ),
      ),
      GoRoute(
        path: Routes.transactionPattern,
        pageBuilder: (context, state) => _slideUpPage(
          context,
          state,
          QuickAddScreen(
            args: (
              editId: state.pathParameters['id'],
              unparsedId: null,
              captureId: null,
            ),
          ),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, state) => screen)],
  );
}

// Quick Add rises from the bottom with a fade, and sinks back on close.
// Instant under reduced motion.
Page<void> _slideUpPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  final motion = AppMotion.of(context);
  final duration = resolveMotion(context, motion.slow);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    fullscreenDialog: true,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: motion.enter,
        reverseCurve: motion.exit,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
