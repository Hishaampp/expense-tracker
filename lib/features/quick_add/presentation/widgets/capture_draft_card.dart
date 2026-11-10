import 'package:expense_tracker/core/models/capture_draft.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:flutter/material.dart';

/// Shows what a pasted or shared message filled in: who was paid and from
/// which account.
class CaptureDraftCard extends StatelessWidget {
  /// Creates the card for [draft].
  const new({required this.draft, super.key});

  /// What the message proposed.
  final CaptureDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final title = draft.payeeDisplay ?? l10n.quickAddPaymentFallback;
    final account = draft.accountLabel;
    final details = account == null
        ? l10n.quickAddFromMessage
        : l10n.quickAddFromMessageDetails(account);
    return Semantics(
      container: true,
      label: l10n.quickAddFromMessageSemantics(title, details),
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceSunken,
            borderRadius: BorderRadius.circular(metrics.radiusTileLarge),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.all(metrics.spaceMd),
            child: Row(
              children: [
                IconTile(
                  icon: Icons.sms_rounded,
                  color: CategoryColors.of(context).blue,
                ),
                SizedBox(width: metrics.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.bodyLarge),
                      Text(details, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
