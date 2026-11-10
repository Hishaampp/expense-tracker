import 'package:expense_tracker/theme/app_colors.dart';
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
List<(String, Color, Color)> _pairs(AppColors c) => [
  ('onSurface on surface', c.onSurface, c.surface),
  ('onSurface on surfaceRaised', c.onSurface, c.surfaceRaised),
  ('onSurfaceMuted on surface', c.onSurfaceMuted, c.surface),
  ('onSurfaceMuted on surfaceRaised', c.onSurfaceMuted, c.surfaceRaised),
  ('accent on surface', c.accent, c.surface),
  ('accent on surfaceRaised', c.accent, c.surfaceRaised),
  ('onAccent on accent', c.onAccent, c.accent),
  ('moneyIn on surface', c.moneyIn, c.surface),
  ('moneyIn on surfaceRaised', c.moneyIn, c.surfaceRaised),
  ('danger on surface', c.danger, c.surface),
  ('danger on surfaceRaised', c.danger, c.surfaceRaised),
  ('review on reviewContainer', c.review, c.reviewContainer),
  ('review on surface', c.review, c.surface),
];

void main() {
  for (final (name, colors) in [
    ('light', AppColors.light),
    ('dark', AppColors.dark),
  ]) {
    group('$name theme meets WCAG AA (4.5:1)', () {
      for (final (label, fg, bg) in _pairs(colors)) {
        test(label, () {
          expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5));
        });
      }

      test('review outline is visible against its fill (3:1)', () {
        expect(
          _contrast(colors.reviewOutline, colors.reviewContainer),
          greaterThanOrEqualTo(3),
        );
      });
    });
  }

  test('lerp reaches the other palette at t = 1', () {
    final mixed = AppColors.light.lerp(AppColors.dark, 1);
    expect(mixed.surface, AppColors.dark.surface);
    expect(mixed.reviewOutline, AppColors.dark.reviewOutline);
  });
}
