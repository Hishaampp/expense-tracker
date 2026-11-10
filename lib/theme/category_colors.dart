import 'package:expense_tracker/theme/primitives.dart';
import 'package:flutter/material.dart';

/// Fills of the small square icon tiles that mark categories and settings.
/// Each takes a white glyph at 3:1 or better, in light and dark.
@immutable
class CategoryColors extends ThemeExtension<CategoryColors> {
  /// Creates the set; use [CategoryColors.standard].
  const new({
    required this.orange,
    required this.green,
    required this.blue,
    required this.red,
    required this.purple,
    required this.amber,
    required this.violet,
    required this.teal,
    required this.pink,
    required this.grey,
    required this.onTile,
  });

  /// The tile colours, shared by both brightnesses.
  static const CategoryColors standard = CategoryColors(
    orange: Primitives.tileOrange64,
    green: Primitives.tileGreen59,
    blue: Primitives.tileBlue53,
    red: Primitives.tileRed59,
    purple: Primitives.tilePurple56,
    amber: Primitives.tileAmber62,
    violet: Primitives.tileViolet54,
    teal: Primitives.tileTeal57,
    pink: Primitives.tilePink56,
    grey: Primitives.tileGrey56,
    onTile: Primitives.white100,
  );

  /// Orange tile.
  final Color orange;

  /// Green tile.
  final Color green;

  /// Blue tile.
  final Color blue;

  /// Red tile.
  final Color red;

  /// Purple tile.
  final Color purple;

  /// Amber tile.
  final Color amber;

  /// Violet tile.
  final Color violet;

  /// Teal tile.
  final Color teal;

  /// Pink tile.
  final Color pink;

  /// Grey tile.
  final Color grey;

  /// The glyph on every tile.
  final Color onTile;

  /// Reads the tile colours from the theme; asserts if missing.
  static CategoryColors of(BuildContext context) {
    final extension = Theme.of(context).extension<CategoryColors>();
    assert(extension != null, 'CategoryColors missing: use buildAppTheme().');
    return extension!;
  }

  @override
  CategoryColors copyWith({
    Color? orange,
    Color? green,
    Color? blue,
    Color? red,
    Color? purple,
    Color? amber,
    Color? violet,
    Color? teal,
    Color? pink,
    Color? grey,
    Color? onTile,
  }) {
    return CategoryColors(
      orange: orange ?? this.orange,
      green: green ?? this.green,
      blue: blue ?? this.blue,
      red: red ?? this.red,
      purple: purple ?? this.purple,
      amber: amber ?? this.amber,
      violet: violet ?? this.violet,
      teal: teal ?? this.teal,
      pink: pink ?? this.pink,
      grey: grey ?? this.grey,
      onTile: onTile ?? this.onTile,
    );
  }

  @override
  CategoryColors lerp(CategoryColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? b;
    return CategoryColors(
      orange: mix(orange, other.orange),
      green: mix(green, other.green),
      blue: mix(blue, other.blue),
      red: mix(red, other.red),
      purple: mix(purple, other.purple),
      amber: mix(amber, other.amber),
      violet: mix(violet, other.violet),
      teal: mix(teal, other.teal),
      pink: mix(pink, other.pink),
      grey: mix(grey, other.grey),
      onTile: mix(onTile, other.onTile),
    );
  }
}
