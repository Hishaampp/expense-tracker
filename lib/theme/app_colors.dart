import 'package:expense_tracker/theme/primitives.dart';
import 'package:flutter/material.dart';

/// Tier-2 semantic colour slots. Widgets read these, never a primitive.
///
/// Every money state also has a non-colour signal (sign, icon or label);
/// colour only reinforces it (docs/DESIGN.md, "Money states").
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates a colour set; use [AppColors.light] or [AppColors.dark].
  const new({
    required this.background,
    required this.surface,
    required this.surfaceSunken,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.hairline,
    required this.accent,
    required this.accentFill,
    required this.onAccentFill,
    required this.accentText,
    required this.hero,
    required this.onHero,
    required this.onHeroMuted,
    required this.moneyIn,
    required this.moneyInOnHero,
    required this.danger,
    required this.review,
    required this.reviewContainer,
    required this.floatingShadow,
  });

  /// The light palette.
  static const AppColors light = AppColors(
    background: Primitives.sand96,
    surface: Primitives.white100,
    surfaceSunken: Primitives.sand94,
    onSurface: Primitives.ink19,
    onSurfaceMuted: Primitives.stone51,
    hairline: Primitives.sand94,
    accent: Primitives.saffron64,
    accentFill: Primitives.saffron58,
    onAccentFill: Primitives.white100,
    accentText: Primitives.saffron53,
    hero: Primitives.ink19,
    onHero: Primitives.white100,
    onHeroMuted: Primitives.stone72,
    moneyIn: Primitives.green50,
    moneyInOnHero: Primitives.green78,
    danger: Primitives.red56,
    review: Primitives.amber46,
    reviewContainer: Primitives.amber94,
    floatingShadow: Primitives.shadow08,
  );

  /// The dark palette, authored by hand (not a flip of light).
  static const AppColors dark = AppColors(
    background: Primitives.night16,
    surface: Primitives.night22,
    surfaceSunken: Primitives.night27,
    onSurface: Primitives.stone96,
    onSurfaceMuted: Primitives.stone71,
    hairline: Primitives.night27,
    accent: Primitives.saffron75,
    accentFill: Primitives.saffron75,
    onAccentFill: Primitives.saffron18,
    accentText: Primitives.saffron78,
    hero: Primitives.night26,
    onHero: Primitives.white100,
    onHeroMuted: Primitives.stone75,
    moneyIn: Primitives.green78,
    moneyInOnHero: Primitives.green78,
    danger: Primitives.red74,
    review: Primitives.amber88,
    reviewContainer: Primitives.amber31,
    floatingShadow: Primitives.shadow40,
  );

  /// Page background.
  final Color background;

  /// Cards, sheets and the tab bar.
  final Color surface;

  /// Pills, selected tab and keypad keys: a step below [surface].
  final Color surfaceSunken;

  /// Primary text and icons; spent amounts.
  final Color onSurface;

  /// Supporting text; transfers.
  final Color onSurfaceMuted;

  /// The rare divider between rows inside one card.
  final Color hairline;

  /// Vivid accent for icons, progress and the floating + glyph. Not for text.
  final Color accent;

  /// Fill of primary buttons.
  final Color accentFill;

  /// Text and icons on [accentFill].
  final Color onAccentFill;

  /// Accent-coloured text, such as a tappable value.
  final Color accentText;

  /// The dark summary card.
  final Color hero;

  /// Text on [hero].
  final Color onHero;

  /// Supporting text on [hero].
  final Color onHeroMuted;

  /// Money received, on [surface] or [background].
  final Color moneyIn;

  /// Money received, on [hero].
  final Color moneyInOnHero;

  /// Over budget and destructive actions.
  final Color danger;

  /// Text and icons for "needs review".
  final Color review;

  /// Fill behind "needs review" badges.
  final Color reviewContainer;

  /// Shadow under the floating round buttons and tab bar only.
  final Color floatingShadow;

  /// Reads the colours from the theme; asserts if the theme lacks them.
  static AppColors of(BuildContext context) {
    final extension = Theme.of(context).extension<AppColors>();
    assert(extension != null, 'AppColors missing: use buildAppTheme().');
    return extension!;
  }

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSunken,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? hairline,
    Color? accent,
    Color? accentFill,
    Color? onAccentFill,
    Color? accentText,
    Color? hero,
    Color? onHero,
    Color? onHeroMuted,
    Color? moneyIn,
    Color? moneyInOnHero,
    Color? danger,
    Color? review,
    Color? reviewContainer,
    Color? floatingShadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      hairline: hairline ?? this.hairline,
      accent: accent ?? this.accent,
      accentFill: accentFill ?? this.accentFill,
      onAccentFill: onAccentFill ?? this.onAccentFill,
      accentText: accentText ?? this.accentText,
      hero: hero ?? this.hero,
      onHero: onHero ?? this.onHero,
      onHeroMuted: onHeroMuted ?? this.onHeroMuted,
      moneyIn: moneyIn ?? this.moneyIn,
      moneyInOnHero: moneyInOnHero ?? this.moneyInOnHero,
      danger: danger ?? this.danger,
      review: review ?? this.review,
      reviewContainer: reviewContainer ?? this.reviewContainer,
      floatingShadow: floatingShadow ?? this.floatingShadow,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? b;
    return AppColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceSunken: mix(surfaceSunken, other.surfaceSunken),
      onSurface: mix(onSurface, other.onSurface),
      onSurfaceMuted: mix(onSurfaceMuted, other.onSurfaceMuted),
      hairline: mix(hairline, other.hairline),
      accent: mix(accent, other.accent),
      accentFill: mix(accentFill, other.accentFill),
      onAccentFill: mix(onAccentFill, other.onAccentFill),
      accentText: mix(accentText, other.accentText),
      hero: mix(hero, other.hero),
      onHero: mix(onHero, other.onHero),
      onHeroMuted: mix(onHeroMuted, other.onHeroMuted),
      moneyIn: mix(moneyIn, other.moneyIn),
      moneyInOnHero: mix(moneyInOnHero, other.moneyInOnHero),
      danger: mix(danger, other.danger),
      review: mix(review, other.review),
      reviewContainer: mix(reviewContainer, other.reviewContainer),
      floatingShadow: mix(floatingShadow, other.floatingShadow),
    );
  }
}
