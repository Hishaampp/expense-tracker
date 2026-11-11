import 'package:expense_tracker/formatting/relative_time.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:flutter/material.dart';

/// Whether auto-capture is working, and when it last saved a message.
///
/// A live region, so a screen reader hears the change when it turns on.
class CaptureStatusCard extends StatelessWidget {
  /// Creates the card.
  const new({
    required this.on,
    required this.offIcon,
    required this.title,
    required this.lastCaptureAt,
    required this.now,
    super.key,
  });

  /// Whether capture is on.
  final bool on;

  /// The icon shown while capture is off.
  final IconData offIcon;

  /// The status heading.
  final String title;

  /// When a message was last captured, if ever.
  final DateTime? lastCaptureAt;

  /// The current time, for "2 hours ago".
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final tiles = CategoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final last = lastCaptureAt;
    return AppCard(
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Row(
          children: [
            IconTile(
              icon: on ? Icons.bolt_rounded : offIcon,
              color: on ? tiles.green : tiles.grey,
            ),
            SizedBox(width: metrics.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: textTheme.titleMedium),
                  ),
                  Text(
                    last == null
                        ? l10n.autoCaptureNever
                        : l10n.autoCaptureLastCapture(
                            formatTimeAgo(l10n, last, now),
                          ),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
