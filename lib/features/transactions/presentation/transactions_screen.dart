import 'dart:async';

import 'package:expense_tracker/features/transactions/presentation/transactions_notifier.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/day_ledger.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/ledger_skeleton.dart';
import 'package:expense_tracker/widgets/month_switcher.dart';
import 'package:expense_tracker/widgets/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Every transaction in a month, grouped by day.
class TransactionsScreen extends ConsumerWidget {
  /// Creates the Transactions screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(transactionsNotifierProvider);
    final offset = ref.read(transactionsMonthOffsetProvider.notifier);
    // Keep the last month on screen while the next one loads.
    final state = async.value;

    final Widget body;
    if (state != null) {
      final month = formatMonthPeriod(state.period, locale);
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonthSwitcher(
            label: month,
            previousLabel: l10n.previousMonth,
            nextLabel: l10n.nextMonth,
            onPrevious: offset.previous,
            onNext: state.canGoNext ? offset.next : null,
          ),
          Expanded(
            child: state.isEmpty
                ? SingleChildScrollView(
                    child: EmptyStateView(
                      title: l10n.transactionsEmptyTitle(month),
                      body: l10n.transactionsEmptyBody,
                      actionLabel: l10n.addExpense,
                      onAction: () =>
                          unawaited(context.push(Routes.addExpense)),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsetsDirectional.only(top: metrics.spaceSm),
                    itemCount: state.days.length,
                    itemBuilder: (context, index) => DayLedger(
                      key: ValueKey(state.days[index].day),
                      group: state.days[index],
                      onOpenTransaction: (id) =>
                          unawaited(context.push(Routes.transaction(id))),
                    ),
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
          onAction: () => ref.invalidate(transactionsNotifierProvider),
        ),
      );
    } else {
      body = LedgerSkeleton(semanticLabel: l10n.loading);
    }
    return Scaffold(body: PageFrame(child: body));
  }
}
