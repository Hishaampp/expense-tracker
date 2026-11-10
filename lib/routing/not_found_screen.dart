import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shown for a location that matches no route.
class NotFoundScreen extends StatelessWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsetsDirectional.all(AppMetrics.of(context).spaceLg),
            child: ErrorStateView(
              message: l10n.notFoundTitle,
              actionLabel: l10n.notFoundAction,
              onAction: () => context.go(Routes.home),
            ),
          ),
        ),
      ),
    );
  }
}
