import 'dart:async';

import 'package:expense_tracker/core/models/notice.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/formatting/relative_time.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The notification inbox: every alert, weekly review and Room suggestion
/// the app sent, newest first. Opening it marks them seen; the ones that
/// were new keep their "New" mark until the screen closes.
class NotificationsScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // The notices that were unread when the screen opened.
  Set<String>? _fresh;

  void _noteFresh(List<Notice> notices) {
    if (_fresh != null) return;
    _fresh = {
      for (final n in notices)
        if (n.isUnread) n.id,
    };
    if (_fresh!.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_markRead());
    });
  }

  Future<void> _markRead() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(noticeRepositoryProvider).markAllRead();
    if (result case Err(:final failure)) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final async = ref.watch(noticesProvider);
    final back = RoundIconButton(
      icon: Icons.arrow_back_rounded,
      tooltip: l10n.back,
      floating: false,
      color: colors.onSurface,
      onPressed: context.pop,
    );
    final notices = async.value;
    if (notices == null) {
      return LargeTitlePage(
        title: Text(l10n.noticesTitle),
        leading: back,
        children: [
          if (async.hasError)
            ErrorStateView(
              message: l10n.failureLoad,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(noticesProvider),
            )
          else
            PulsingPlaceholder(semanticLabel: l10n.loading),
        ],
      );
    }
    _noteFresh(notices);
    final now = ref.watch(clockProvider).now();
    return LargeTitlePage(
      title: Text(l10n.noticesTitle),
      leading: back,
      children: [
        if (notices.isEmpty)
          Entrance(
            child: EmptyStateView(
              icon: Icons.notifications_none_rounded,
              iconColor: CategoryColors.of(context).violet,
              title: l10n.noticesEmptyTitle,
              body: l10n.noticesEmptyBody,
            ),
          )
        else ...[
          for (final (i, notice) in notices.indexed)
            Entrance(
              key: ValueKey(notice.id),
              index: i,
              child: _NoticeCard(
                notice: notice,
                isNew: _fresh?.contains(notice.id) ?? false,
                time: formatTimeAgo(l10n, notice.createdAt, now),
                onOpen: switch (notice.route) {
                  final route? when _opens(route) => () => unawaited(
                    context.push(route),
                  ),
                  _ => null,
                },
              ),
            ),
          Entrance(
            index: notices.length,
            child: Text(
              l10n.noticesKeptFor,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }
}

// Only screens the app itself links to.
bool _opens(String route) =>
    route == Routes.budgets ||
    route == Routes.weeklyReview ||
    route == Routes.review ||
    RegExp(r'^/rooms/[\w-]+$').hasMatch(route);

class _NoticeCard extends StatelessWidget {
  const new({
    required this.notice,
    required this.isNew,
    required this.time,
    required this.onOpen,
  });

  final Notice notice;
  final bool isNew;
  final String time;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final tiles = CategoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (icon, tile) = switch (notice.kind) {
      NoticeKind.budget => (Icons.savings_rounded, tiles.amber),
      NoticeKind.weekly => (Icons.event_repeat_rounded, tiles.violet),
      NoticeKind.room => (Icons.luggage_rounded, tiles.orange),
    };
    return Semantics(
      container: true,
      button: onOpen != null,
      label: isNew
          ? l10n.noticesItemUnreadSemantics(notice.title, notice.body, time)
          : l10n.noticesItemSemantics(notice.title, notice.body, time),
      onTap: onOpen,
      child: ExcludeSemantics(
        child: AppCard(
          onTap: onOpen,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(icon: icon, color: tile),
              SizedBox(width: metrics.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notice.title, style: textTheme.titleMedium),
                    SizedBox(height: metrics.spaceXs),
                    Text(notice.body, style: textTheme.bodyMedium),
                    SizedBox(height: metrics.spaceXs),
                    Text(time, style: textTheme.bodySmall),
                  ],
                ),
              ),
              if (isNew) ...[
                SizedBox(width: metrics.spaceSm),
                // A word, not just a dot, so "new" never rests on colour.
                Text(
                  l10n.noticesNew,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.accentText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
