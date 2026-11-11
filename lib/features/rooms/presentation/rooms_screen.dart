import 'dart:async';

import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/features/rooms/presentation/rooms_notifier.dart';
import 'package:expense_tracker/features/rooms/presentation/widgets/room_card.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Rooms: active Rooms, then History (spec §9.4, §11.7).
class RoomsScreen extends ConsumerWidget {
  /// Creates the Rooms screen.
  const new({super.key});

  Future<void> _startTrip(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(clockProvider).now().toLocal();
    final messenger = ScaffoldMessenger.of(context);
    final name = l10n.tripDefaultName(formatDayMonth(today, locale));
    final result = await ref
        .read(roomsNotifierProvider.notifier)
        .startTrip(name);
    if (!context.mounted) return;
    switch (result) {
      case Ok(:final value):
        unawaited(context.push(Routes.room(value.id)));
      case Err(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final async = ref.watch(roomsNotifierProvider);
    void create() => unawaited(context.push(Routes.newRoom));
    void open(String id) => unawaited(context.push(Routes.room(id)));
    var index = 0;
    Widget enter(Widget child, {Key? key}) =>
        Entrance(key: key, index: index++, child: child);

    final children = switch (async) {
      AsyncData(:final value) when value.isEmpty => [
        enter(
          EmptyStateView(
            icon: Icons.luggage_rounded,
            iconColor: CategoryColors.of(context).blue,
            title: l10n.roomsEmptyTitle,
            body: l10n.roomsEmptyBody,
            actionLabel: l10n.roomsStartTrip,
            onAction: () => unawaited(_startTrip(context, ref)),
          ),
        ),
      ],
      AsyncData(:final value) => [
        for (final e in value.active)
          enter(
            RoomCard(
              room: e.room,
              spent: e.spent,
              onTap: () => open(e.room.id),
            ),
            key: ValueKey(e.room.id),
          ),
        if (value.active.isEmpty)
          enter(
            Align(
              child: FilledButton.icon(
                onPressed: () => unawaited(_startTrip(context, ref)),
                icon: const Icon(Icons.flight_takeoff_rounded),
                label: Text(l10n.roomsStartTrip),
              ),
            ),
          ),
        if (value.archived.isNotEmpty)
          enter(
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: metrics.spaceLg,
                start: metrics.spaceXs,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.roomsHistory,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        for (final e in value.archived)
          enter(
            RoomCard(
              room: e.room,
              spent: e.spent,
              onTap: () => open(e.room.id),
            ),
            key: ValueKey(e.room.id),
          ),
      ],
      AsyncError() => [
        ErrorStateView(
          message: l10n.failureLoad,
          actionLabel: l10n.tryAgain,
          onAction: () => ref.invalidate(roomsNotifierProvider),
        ),
      ],
      _ => [PulsingPlaceholder(semanticLabel: l10n.loading)],
    };

    return LargeTitlePage(
      title: Text(l10n.roomsTitle),
      actions: [
        RoundIconButton(
          icon: Icons.add_rounded,
          tooltip: l10n.roomsNew,
          onPressed: create,
        ),
      ],
      children: children,
    );
  }
}
