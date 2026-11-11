import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:flutter/material.dart';

/// A Room type's glyph and tile colour.
typedef RoomStyle = ({IconData icon, Color color});

/// The glyph and colour for [type]. The colour follows the type, so Rooms
/// of one kind look alike.
RoomStyle roomStyle(BuildContext context, RoomType type) {
  final tiles = CategoryColors.of(context);
  return switch (type) {
    RoomType.trip => (icon: Icons.flight_takeoff_rounded, color: tiles.blue),
    RoomType.wedding => (icon: Icons.favorite_rounded, color: tiles.pink),
    RoomType.event => (icon: Icons.celebration_rounded, color: tiles.violet),
    RoomType.custom => (icon: Icons.folder_special_rounded, color: tiles.teal),
  };
}

/// A Room's square tile: its emoji, or its type's glyph when it has none.
class RoomTile extends StatelessWidget {
  /// Creates the tile for a Room of [type].
  const new({required this.type, this.emoji, this.large = false, super.key});

  /// The Room's type, for the colour and fallback glyph.
  final RoomType type;

  /// The Room's emoji, if any.
  final String? emoji;

  /// Whether to use the large size.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final style = roomStyle(context, type);
    final side = large ? metrics.iconTileLargeSize : metrics.iconTileSize;
    final text = emoji;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: side,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: style.color,
            borderRadius: BorderRadius.circular(
              large ? metrics.radiusTileLarge : metrics.radiusTile,
            ),
          ),
          child: Center(
            child: text == null
                ? Icon(
                    style.icon,
                    size: large ? metrics.iconLargeSize : metrics.iconSize,
                    color: CategoryColors.of(context).onTile,
                  )
                // An emoji keeps its own colours; it scales with text size
                // only as far as the tile allows.
                : MediaQuery.withNoTextScaling(
                    child: Text(
                      text,
                      style: large
                          ? Theme.of(context).textTheme.headlineSmall
                          : Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
