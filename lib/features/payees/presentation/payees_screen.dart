import 'dart:async';

import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/payee_rule.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/features/payees/presentation/widgets/payee_sheet.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/category_style.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// What the Payees screen shows.
@immutable
final class PayeesState {
  /// Creates the state.
  const new({
    required this.entries,
    required this.categories,
    required this.rooms,
  });

  /// Every payee seen, most used first.
  final List<PayeeEntry> entries;

  /// Expense categories, by id.
  final Map<String, Category> categories;

  /// Every Room, by id.
  final Map<String, Room> rooms;
}

/// The merchant book's view model (spec §8).
class PayeesNotifier extends AsyncNotifier<PayeesState> {
  @override
  Future<PayeesState> build() async {
    final entries = await ref.watch(payeeBookProvider.future);
    final categories = await ref.watch(categoriesProvider.future);
    final rooms = await ref.watch(roomsProvider.future);
    return PayeesState(
      entries: entries,
      categories: {
        for (final c in categories)
          if (c.kind == CategoryKind.expense) c.id: c,
      },
      rooms: {for (final r in rooms) r.id: r},
    );
  }

  /// Saves [rule]; an empty rule is forgotten.
  Future<Result<PayeeRule, StoreFailure>> save(PayeeRule rule) async {
    final result = await ref.read(payeeRepositoryProvider).save(rule);
    if (result is Ok) ref.read(hapticsProvider).commit();
    return result;
  }
}

/// Provides [PayeesNotifier].
final AsyncNotifierProvider<PayeesNotifier, PayeesState>
payeesNotifierProvider =
    AsyncNotifierProvider.autoDispose<PayeesNotifier, PayeesState>(
      PayeesNotifier.new,
    );

/// Settings → Payees & rules: every payee, its name, and what it always
/// gets. Tapping one opens its rule.
class PayeesScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    PayeesState state,
    PayeeEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final edit = await showAppSheet<PayeeEdit>(
      context,
      PayeeSheet(
        entry: entry,
        categories: [
          for (final c in state.categories.values)
            if (!c.isArchived) c,
        ],
        rooms: [
          for (final r in state.rooms.values)
            if (r.isActive) r,
        ],
      ),
    );
    if (edit == null) return;
    final result = await ref
        .read(payeesNotifierProvider.notifier)
        .save(edit.rule);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(switch (result) {
            Ok(:final value) when value.isEmpty => l10n.payeesForgotten,
            Ok(:final value) => l10n.payeesSaved(
              value.displayName ?? entry.name,
            ),
            Err(:final failure) => failureMessage(l10n, failure),
          }),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final async = ref.watch(payeesNotifierProvider);
    final state = async.value;
    final back = RoundIconButton(
      icon: Icons.arrow_back_rounded,
      tooltip: l10n.back,
      floating: false,
      color: colors.onSurface,
      onPressed: context.pop,
    );
    if (state == null) {
      return LargeTitlePage(
        title: Text(l10n.payeesTitle),
        leading: back,
        children: [
          if (async.hasError)
            ErrorStateView(
              message: l10n.failureLoad,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(payeesNotifierProvider),
            )
          else
            PulsingPlaceholder(semanticLabel: l10n.loading),
        ],
      );
    }
    return LargeTitlePage(
      title: Text(l10n.payeesTitle),
      leading: back,
      children: [
        if (state.entries.isEmpty)
          Entrance(
            child: EmptyStateView(
              icon: Icons.storefront_rounded,
              iconColor: CategoryColors.of(context).orange,
              title: l10n.payeesEmptyTitle,
              body: l10n.payeesEmptyBody,
            ),
          )
        else ...[
          Entrance(
            child: Text(
              l10n.payeesHelp,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Entrance(
            index: 1,
            child: AppCard(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: AppMetrics.of(context).spaceSm,
              ),
              child: Column(
                children: [
                  for (final entry in state.entries)
                    _PayeeRow(
                      key: ValueKey(entry.payeeKey),
                      entry: entry,
                      category: state.categories[entry.rule?.categoryId],
                      room: state.rooms[entry.rule?.roomId],
                      onTap: () => unawaited(_edit(context, ref, state, entry)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PayeeRow extends StatelessWidget {
  const new({
    required this.entry,
    required this.category,
    required this.room,
    required this.onTap,
    super.key,
  });

  final PayeeEntry entry;
  final Category? category;
  final Room? room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final ruled = category;
    final roomed = room;
    final style = categoryStyle(context, ruled?.iconKey ?? 'more');
    final rule = [
      if (ruled != null) l10n.payeesRuleCategory(ruled.name),
      if (roomed != null) l10n.payeesRuleRoom(roomed.name),
    ];
    final ruleText = rule.isEmpty ? l10n.payeesNoRule : rule.join(' · ');
    final count = l10n.payeesCount(entry.count);
    return Semantics(
      container: true,
      button: true,
      label: l10n.payeesRowSemantics(entry.name, ruleText, count),
      onTap: onTap,
      child: ExcludeSemantics(
        child: Pressable(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: metrics.spaceLg,
              vertical: metrics.spaceSm,
            ),
            child: Row(
              children: [
                IconTile(icon: style.icon, color: style.color),
                SizedBox(width: metrics.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.name, style: textTheme.bodyLarge),
                      Text(ruleText, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                SizedBox(width: metrics.spaceSm),
                Text(count, style: textTheme.bodySmall),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
