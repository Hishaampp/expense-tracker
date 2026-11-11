import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:flutter/material.dart';

/// A gentle note on Home when iPhone auto-capture seems to have stopped
/// (spec §6.3 capture health), with a link to the setup steps.
class CaptureHealthCard extends StatelessWidget {
  /// Creates the card.
  const new({required this.onCheck, super.key});

  /// Opens the setup steps.
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(
            icon: Icons.warning_amber_rounded,
            color: CategoryColors.of(context).amber,
          ),
          SizedBox(width: metrics.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(l10n.healthTitle, style: textTheme.titleMedium),
                ),
                Text(l10n.healthBody, style: textTheme.bodySmall),
                TextButton(onPressed: onCheck, child: Text(l10n.healthAction)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
