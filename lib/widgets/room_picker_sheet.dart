import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/formatting/room_text.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:expense_tracker/widgets/room_tile.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';

/// What the Room picker returned: a Room id, or null for "No Room". A
/// dismissed sheet returns no pick at all.
typedef RoomPick = ({String? roomId});

/// Lists [rooms] and "No Room"; pops a [RoomPick].
class RoomPickerSheet extends StatelessWidget {
  /// Creates the sheet.
  const new({
    required this.title,
    required this.rooms,
    required this.selectedId,
    this.offerNone = true,
    super.key,
  });

  /// The sheet's heading.
  final String title;

  /// The Rooms to offer.
  final List<Room> rooms;

  /// The current choice, marked with a tick.
  final String? selectedId;

  /// Whether "No Room" is offered.
  final bool offerNone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return SheetFrame(
      title: title,
      child: Column(
        children: [
          for (final room in rooms)
            _Choice(
              key: ValueKey(room.id),
              leading: RoomTile(type: room.type, emoji: room.emoji),
              title: room.name,
              subtitle: roomSubtitle(l10n, room, locale),
              selected: room.id == selectedId,
              onTap: () =>
                  Navigator.of(context).pop<RoomPick>((roomId: room.id)),
            ),
          if (offerNone)
            _Choice(
              leading: const SizedBox.shrink(),
              title: l10n.quickAddNoRoom,
              selected: selectedId == null,
              onTap: () => Navigator.of(context).pop<RoomPick>((roomId: null)),
            ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const new({
    required this.leading,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final subtitle = this.subtitle;
    return Semantics(
      button: true,
      selected: selected,
      label: subtitle == null ? title : '$title, $subtitle',
      onTap: onTap,
      child: ExcludeSemantics(
        child: Pressable(
          onTap: onTap,
          shape: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: metrics.minTapTarget),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: metrics.spaceLg,
                vertical: metrics.spaceSm,
              ),
              child: Row(
                children: [
                  SizedBox(width: metrics.iconTileSize, child: leading),
                  SizedBox(width: metrics.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: textTheme.bodyLarge),
                        if (subtitle != null)
                          Text(subtitle, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_rounded,
                      size: metrics.iconSize,
                      color: colors.accent,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
