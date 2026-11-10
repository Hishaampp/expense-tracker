import 'dart:async';

import 'package:expense_tracker/features/unparsed/presentation/unparsed_notifier.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/info_row.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Messages with an amount the app could not read (spec §7.8). Each opens
/// Quick Add with the amount filled in, so the user can add it by hand.
/// Shows the masked text only: account and reference numbers are hidden.
class UnparsedScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final tiles = CategoryColors.of(context);
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(unparsedNotifierProvider);
    final items = async.value;

    final List<Widget> children;
    if (items == null) {
      children = [
        if (async.hasError)
          ErrorStateView(
            message: l10n.failureLoad,
            actionLabel: l10n.tryAgain,
            onAction: () => ref.invalidate(unparsedNotifierProvider),
          )
        else
          PulsingPlaceholder(semanticLabel: l10n.loading),
      ];
    } else if (items.isEmpty) {
      // No action: there is nothing to do when nothing is waiting.
      children = [
        Entrance(
          child: EmptyStateView(
            icon: Icons.mark_email_read_rounded,
            iconColor: tiles.green,
            title: l10n.unparsedEmptyTitle,
            body: l10n.unparsedEmptyBody,
          ),
        ),
      ];
    } else {
      children = [
        Entrance(
          child: Text(
            l10n.unparsedHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Entrance(
          index: 1,
          child: AppCard(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: metrics.spaceLg,
              vertical: metrics.spaceSm,
            ),
            child: Column(
              children: [
                for (final (index, entry) in items.indexed) ...[
                  if (index > 0) const Divider(),
                  Entrance(
                    key: ValueKey(entry.item.id),
                    child: InfoRow(
                      leading: IconTile(
                        icon: Icons.sms_rounded,
                        color: tiles.blue,
                      ),
                      title: entry.item.maskedText,
                      subtitle: formatShortDate(entry.localDay, locale),
                      showChevron: true,
                      semanticLabel: l10n.unparsedItemSemantics(
                        formatShortDate(entry.localDay, locale),
                        entry.item.maskedText,
                      ),
                      onTap: () => unawaited(
                        context.push(Routes.resolveUnparsed(entry.item.id)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ];
    }
    return LargeTitlePage(
      title: Text(l10n.unparsedTitle),
      leading: RoundIconButton(
        icon: Icons.arrow_back_rounded,
        tooltip: l10n.back,
        floating: false,
        color: AppColors.of(context).onSurface,
        onPressed: context.pop,
      ),
      children: children,
    );
  }
}
