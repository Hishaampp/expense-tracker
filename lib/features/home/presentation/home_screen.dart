import 'dart:async';

import 'package:expense_tracker/features/home/presentation/home_notifier.dart';
import 'package:expense_tracker/features/home/presentation/widgets/home_month_view.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/ledger_skeleton.dart';
import 'package:expense_tracker/widgets/month_switcher.dart';
import 'package:expense_tracker/widgets/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home: one month's spending at a glance (layout agreed 2026-11-10).
class HomeScreen extends ConsumerWidget {
  /// Creates the Home screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(homeNotifierProvider);
    final offset = ref.read(homeMonthOffsetProvider.notifier);
    // Keep the last month on screen while the next one loads.
    final state = async.value;

    final Widget body;
    if (state != null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonthSwitcher(
            label: formatMonthPeriod(state.period, locale),
            previousLabel: l10n.previousMonth,
            nextLabel: l10n.nextMonth,
            onPrevious: offset.previous,
            onNext: state.canGoNext ? offset.next : null,
          ),
          Expanded(
            child: HomeMonthView(
              state: state,
              onAddExpense: () => unawaited(context.push(Routes.addExpense)),
              onSeeAll: () => context.go(Routes.transactions),
              onOpenTransaction: (id) =>
                  unawaited(context.push(Routes.transaction(id))),
            ),
          ),
          if (!state.isEmpty)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: metrics.spaceSm,
              ),
              child: FilledButton.icon(
                onPressed: () => unawaited(context.push(Routes.addExpense)),
                icon: const Icon(Icons.add),
                label: Text(l10n.addExpense),
              ),
            ),
        ],
      );
    } else if (async.hasError) {
      body = Center(
        child: ErrorStateView(
          message: l10n.failureLoad,
          actionLabel: l10n.tryAgain,
          onAction: () => ref.invalidate(homeNotifierProvider),
        ),
      );
    } else {
      body = LedgerSkeleton(semanticLabel: l10n.loading);
    }
    return Scaffold(body: PageFrame(child: body));
  }
}
