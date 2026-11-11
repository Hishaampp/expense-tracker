import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/formatting/room_text.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// Active Rooms as chips, and a one-tap "Start trip" (spec §9.4).
class RoomChips extends StatelessWidget {
  /// Creates the row.
  const new({
    required this.rooms,
    required this.onOpen,
    required this.onStartTrip,
    super.key,
  });

  /// Active Rooms.
  final List<Room> rooms;

  /// Opens a Room by id.
  final ValueChanged<String> onOpen;

  /// Starts a trip today.
  final VoidCallback onStartTrip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    return Semantics(
      container: true,
      label: l10n.homeRoomsLabel,
      explicitChildNodes: true,
      child: Wrap(
        spacing: metrics.spaceSm,
        runSpacing: metrics.spaceSm,
        children: [
          for (final room in rooms)
            _Chip(
              key: ValueKey(room.id),
              icon: null,
              label: roomLabel(room),
              semanticLabel: room.name,
              onTap: () => onOpen(room.id),
            ),
          _Chip(
            icon: Icons.flight_takeoff_rounded,
            label: l10n.homeStartTrip,
            semanticLabel: l10n.homeStartTrip,
            onTap: onStartTrip,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    super.key,
  });

  final IconData? icon;
  final String label;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final icon = this.icon;
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: colors.surface,
          shape: const StadiumBorder(),
          child: Pressable(
            onTap: onTap,
            shape: const StadiumBorder(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: metrics.minTapTarget),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: metrics.spaceLg,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: metrics.iconSize, color: colors.accent),
                      SizedBox(width: metrics.spaceSm),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
