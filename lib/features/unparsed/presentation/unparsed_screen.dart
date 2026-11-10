import 'dart:async';

import 'package:expense_tracker/features/capture/application/capture_providers.dart';
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
    final colors = AppColors.of(context);
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(unparsedMessagesProvider);
    final items = async.value;
    final back = RoundIconButton(
      icon: Icons.arrow_back_rounded,
      tooltip: l10n.back,
      onPressed: context.pop,
    );

    final List<Widget> children;
    if (items == null) {
      children = [
        if (async.hasError)
          ErrorStateView(
            message: l10n.failureLoad,
            actionLabel: l10n.tryAgain,
            onAction: () => ref.invalidate(unparsedMessagesProvider),
          )
        else
          PulsingPlaceholder(semanticLabel: l10n.loading),
      ];
    } else if (items.isEmpty) {
      children = [
        Entrance(
          child: EmptyStateView(
            icon: Icons.mark_email_read_rounded,
            iconColor: CategoryColors.of(context).green,
            title: l10n.unparsedEmptyTitle,
            body: l10n.unparsedEmptyBody,
          ),
        ),
      ];
    } else {
      children = [
        Text(l10n.unparsedHint, style: Theme.of(context).textTheme.bodySmall),
        for (final (index, item) in items.indexed)
          Entrance(
            key: ValueKey(item.id),
            index: index,
            child: Builder(
              builder: (context) {
                final date = formatShortDate(item.receivedAt.toLocal(), locale);
                return Semantics(
                  button: true,
                  label: l10n.unparsedItemSemantics(date, item.maskedText),
                  child: ExcludeSemantics(
                    child: AppCard(
                      onTap: () => unawaited(
                        context.push(Routes.resolveUnparsed(item.id)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(height: metrics.spaceXs),
                          Text(
                            item.maskedText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ];
    }
    return LargeTitlePage(
      title: Text(l10n.unparsedTitle),
      actions: [back],
      children: children,
    );
  }
}
