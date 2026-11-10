import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Every foreground/background pair the app draws text with.
List<(String, Color, Color)> _textPairs(AppColors c) => [
  ('onSurface on background', c.onSurface, c.background),
  ('onSurface on surface', c.onSurface, c.surface),
  ('onSurface on surfaceSunken', c.onSurface, c.surfaceSunken),
  ('onSurfaceMuted on background', c.onSurfaceMuted, c.background),
  ('onSurfaceMuted on surface', c.onSurfaceMuted, c.surface),
  ('onSurfaceMuted on surfaceSunken', c.onSurfaceMuted, c.surfaceSunken),
  ('accentText on surface', c.accentText, c.surface),
  ('accentText on background', c.accentText, c.background),
  ('accentText on surfaceSunken', c.accentText, c.surfaceSunken),
  ('onAccentFill on accentFill', c.onAccentFill, c.accentFill),
  ('onHero on hero', c.onHero, c.hero),
  ('onHeroMuted on hero', c.onHeroMuted, c.hero),
  ('moneyInOnHero on hero', c.moneyInOnHero, c.hero),
  ('moneyIn on surface', c.moneyIn, c.surface),
  ('moneyIn on background', c.moneyIn, c.background),
  ('danger on surface', c.danger, c.surface),
  ('review on reviewContainer', c.review, c.reviewContainer),
];

/// Shapes and glyphs that must stand out (WCAG 1.4.11, 3:1).
List<(String, Color, Color)> _shapePairs(AppColors c) => [
  ('accent on surface', c.accent, c.surface),
  ('accent on background', c.accent, c.background),
  ('accentFill on hero', c.accentFill, c.hero),
];

void main() {
  for (final (name, colors) in [
    ('light', AppColors.light),
    ('dark', AppColors.dark),
  ]) {
    group('$name theme', () {
      for (final (label, fg, bg) in _textPairs(colors)) {
        test('text: $label meets 4.5:1', () {
          expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5));
        });
      }
      for (final (label, fg, bg) in _shapePairs(colors)) {
        test('shape: $label meets 3:1', () {
          expect(_contrast(fg, bg), greaterThanOrEqualTo(3));
        });
      }
    });
  }

  test('every category tile holds its white glyph at 3:1', () {
    const c = CategoryColors.standard;
    for (final tile in [
      c.orange,
      c.green,
      c.blue,
      c.red,
      c.purple,
      c.amber,
      c.violet,
      c.teal,
      c.pink,
      c.grey,
    ]) {
      expect(_contrast(c.onTile, tile), greaterThanOrEqualTo(3));
    }
  });

  test('lerp reaches the other palette at t = 1', () {
    final mixed = AppColors.light.lerp(AppColors.dark, 1);
    expect(mixed.background, AppColors.dark.background);
    expect(mixed.floatingShadow, AppColors.dark.floatingShadow);
  });
}
