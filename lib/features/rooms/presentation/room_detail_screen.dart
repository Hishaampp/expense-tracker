import 'dart:async';

import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/features/rooms/presentation/room_detail_notifier.dart';
import 'package:expense_tracker/features/rooms/presentation/widgets/room_hero.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/formatting/room_text.dart';
import 'package:expense_tracker/formatting/transaction_row_text.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/category_totals_card.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/option_sheet.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/room_tile.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:expense_tracker/widgets/transaction_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A Room: what was spent, its budget, where it went and each day's
/// transactions; add an expense, edit, end a trip or archive (spec §9.4).
class RoomDetailScreen extends ConsumerWidget {
  /// Creates the screen for Room [roomId].
  const new({required this.roomId, super.key});

  /// The Room shown.
  final String roomId;

  Future<void> _act(
    BuildContext context,
    Future<StoreFailure?> Function() action,
    String done,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final failure = await action();
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(failure == null ? done : failureMessage(l10n, failure)),
        ),
      );
  }

  // Asks whether the payments go too, then deletes and leaves the page.
  // Dismissing the sheet changes nothing.
  Future<void> _delete(
    BuildContext context,
    RoomDetailNotifier notifier,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final picked = await showAppSheet<OptionPick>(
      context,
      OptionSheet(
        title: l10n.roomDeleteTitle(name),
        subtitle: l10n.roomDeleteBody,
        options: [
          (
            value: _keepPayments,
            label: l10n.roomDeleteKeep,
            icon: Icons.receipt_long_rounded,
          ),
          (
            value: _withPayments,
            label: l10n.roomDeleteAll,
            icon: Icons.delete_outline_rounded,
          ),
        ],
        selected: null,
      ),
    );
    final value = picked?.value;
    if (value == null || !context.mounted) return;
    final failure = await notifier.delete(withPayments: value == _withPayments);
    if (failure == null && context.mounted) context.pop();
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            failure == null ? l10n.roomDeleted : failureMessage(l10n, failure),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final provider = roomDetailNotifierProvider(roomId);
    final async = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
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
        title: Text(l10n.roomsTitle),
        leading: back,
        children: [
          switch (async) {
            AsyncError() => ErrorStateView(
              message: l10n.failureLoad,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(provider),
            ),
            AsyncData() => Text(l10n.roomMissing),
            _ => PulsingPlaceholder(semanticLabel: l10n.loading),
          },
        ],
      );
    }

    final room = state.room;
    var index = 0;
    Widget enter(Widget child, {Key? key}) =>
        Entrance(key: key, index: index++, child: child);
    final metrics = AppMetrics.of(context);
    final locale = Localizations.localeOf(context).toString();
    return LargeTitlePage(
      title: Text(room.name),
      leading: back,
      actions: [
        RoundIconButton(
          icon: Icons.edit_rounded,
          tooltip: l10n.roomEdit,
          onPressed: () => unawaited(context.push(Routes.editRoom(room.id))),
        ),
      ],
      children: [
        enter(
          Padding(
            padding: EdgeInsetsDirectional.only(start: metrics.spaceXs),
            child: Row(
              children: [
                RoomTile(type: room.type, emoji: room.emoji),
                SizedBox(width: metrics.spaceSm),
                Expanded(
                  child: Text(
                    roomSubtitle(l10n, room, locale),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        enter(RoomHero(summary: state.summary)),
        if (room.isActive)
          enter(
            FilledButton.icon(
              onPressed: () =>
                  unawaited(context.push(Routes.addToRoom(room.id))),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.roomAddExpense),
            ),
          ),
        if (state.categories.isNotEmpty)
          enter(
            CategoryTotalsCard(
              title: l10n.roomWhereItWent,
              totals: state.categories,
            ),
          ),
        if (state.days.isEmpty)
          enter(
            EmptyStateView(
              icon: Icons.receipt_long_rounded,
              iconColor: roomStyle(context, room.type).color,
              title: l10n.roomEmptyTitle,
              body: l10n.roomEmptyBody,
            ),
          ),
        for (final day in state.days)
          enter(
            _DaySection(day: day, state: state),
            key: ValueKey(day.day.value),
          ),
        enter(
          Wrap(
            alignment: WrapAlignment.center,
            spacing: metrics.spaceSm,
            children: [
              if (room.isActive && room.isOngoing)
                TextButton(
                  onPressed: () => unawaited(
                    _act(context, notifier.endToday, l10n.roomEndTrip),
                  ),
                  child: Text(l10n.roomEndTrip),
                ),
              if (room.isActive)
                TextButton(
                  onPressed: () => unawaited(
                    _act(context, notifier.archive, l10n.roomArchived),
                  ),
                  child: Text(l10n.roomArchive),
                )
              else
                TextButton(
                  onPressed: () => unawaited(
                    _act(context, notifier.restore, l10n.roomRestored),
                  ),
                  child: Text(l10n.roomRestore),
                ),
              TextButton(
                onPressed: () =>
                    unawaited(_delete(context, notifier, room.name)),
                child: Text(
                  l10n.roomDelete,
                  style: TextStyle(color: colors.danger),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// The delete sheet's choices.
const String _keepPayments = 'keep';
const String _withPayments = 'all';

/// One day: a heading with the day's total, then its rows in a card.
class _DaySection extends StatelessWidget {
  const new({required this.day, required this.state});

  final RoomDay day;
  final RoomDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final heading = switch (state.today.since(day.day)) {
      0 => l10n.today,
      1 => l10n.yesterday,
      _ => formatDayHeading(day.day.date, locale),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: metrics.spaceXs,
            vertical: metrics.spaceSm,
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: metrics.spaceMd,
            children: [
              Semantics(
                header: true,
                child: Text(heading, style: textTheme.titleMedium),
              ),
              if (day.spent.isPositive)
                Text(
                  l10n.daySpent(formatMoney(day.spent)),
                  style: textTheme.bodySmall,
                ),
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: metrics.spaceLg,
            vertical: metrics.spaceSm,
          ),
          child: Column(
            children: [
              for (final item in day.items)
                TransactionRow(
                  key: ValueKey(item.transaction.id),
                  text: describeTransaction(item, l10n, locale),
                  onTap: () => unawaited(
                    context.push(Routes.transaction(item.transaction.id)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
