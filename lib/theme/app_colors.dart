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
    required this.heroTrack,
    required this.lineStrong,
    required this.cardShadow,
    required this.cardShadowFar,
    required this.honey,
    required this.onHoney,
    required this.splash,
    required this.onSplash,
    required this.dangerOnHero,
  });

  /// The light palette.
  static const AppColors light = AppColors(
    background: Primitives.brandWhite,
    surface: Primitives.brandWhite,
    surfaceSunken: Primitives.brandSand,
    onSurface: Primitives.brandInk,
    onSurfaceMuted: Primitives.brandInkMuted,
    hairline: Primitives.brandLine,
    accent: Primitives.brandHoneyInk,
    accentFill: Primitives.brandInk,
    onAccentFill: Primitives.brandWhite,
    accentText: Primitives.brandHoneyInk,
    hero: Primitives.brandInk,
    onHero: Primitives.brandWhite,
    onHeroMuted: Primitives.brandOnCardMuted,
    moneyIn: Primitives.brandIncome,
    moneyInOnHero: Primitives.brandIncomeDark,
    danger: Primitives.brandDanger,
    review: Primitives.brandHoneyInk,
    reviewContainer: Primitives.brandHoneySoft,
    floatingShadow: Primitives.shadow08,
    heroTrack: Primitives.brandCardTrack,
    lineStrong: Primitives.brandLineStrong,
    cardShadow: Primitives.brandShadowNear,
    cardShadowFar: Primitives.brandShadowFar,
    honey: Primitives.brandHoney,
    onHoney: Primitives.brandInk,
    splash: Primitives.brandInk,
    onSplash: Primitives.brandWhite,
    dangerOnHero: Primitives.brandDangerDark,
  );

  /// The dark palette, authored by hand (not a flip of light).
  static const AppColors dark = AppColors(
    background: Primitives.brandNight,
    surface: Primitives.brandNightRaised,
    surfaceSunken: Primitives.brandNightSunken,
    onSurface: Primitives.brandInkDark,
    onSurfaceMuted: Primitives.brandInkMutedDark,
    hairline: Primitives.brandLineDark,
    accent: Primitives.brandHoney,
    accentFill: Primitives.brandHoney,
    onAccentFill: Primitives.brandInk,
    accentText: Primitives.brandHoneyInkDark,
    hero: Primitives.brandCardInkDark,
    onHero: Primitives.brandInkDark,
    onHeroMuted: Primitives.brandOnCardMuted,
    moneyIn: Primitives.brandIncomeDark,
    moneyInOnHero: Primitives.brandIncomeDark,
    danger: Primitives.brandDangerDark,
    review: Primitives.brandHoneyInkDark,
    reviewContainer: Primitives.brandHoneySoftDark,
    floatingShadow: Primitives.shadow40,
    heroTrack: Primitives.brandCardTrackDark,
    lineStrong: Primitives.brandLineStrongDark,
    cardShadow: Primitives.brandShadowDark,
    cardShadowFar: Primitives.brandShadowDark,
    honey: Primitives.brandHoney,
    onHoney: Primitives.brandInk,
    splash: Primitives.brandInk,
    onSplash: Primitives.brandWhite,
    dangerOnHero: Primitives.brandDangerDark,
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

  /// The accent for icons, progress and the floating + glyph on [surface]
  /// and [background]: honey-ink in light (honey itself is too pale on
  /// white), honey in dark. Not for text. On [hero], use [honey].
  final Color accent;

  /// Fill of primary buttons: ink in light, honey in dark.
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

  /// The empty part of a meter on [hero].
  final Color heroTrack;

  /// Outlines of inputs and secondary buttons (3:1).
  final Color lineStrong;

  /// The near shadow under cards on the page.
  final Color cardShadow;

  /// The soft, far shadow under cards on the page.
  final Color cardShadowFar;

  /// Honey, the brand signature, as a fill on [hero]: the balance meter
  /// and the arrow button. Never thin lines or text on white.
  final Color honey;

  /// Text and icons on [honey].
  final Color onHoney;

  /// The launch screen and the intro behind the animated logo: card ink,
  /// the same in light and dark so the still launch screen hands over
  /// without a flash.
  final Color splash;

  /// The logo's "a" on [splash].
  final Color onSplash;

  /// Over budget on [hero]: brighter than [danger], which is too dark there.
  final Color dangerOnHero;

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
    Color? heroTrack,
    Color? lineStrong,
    Color? cardShadow,
    Color? cardShadowFar,
    Color? honey,
    Color? onHoney,
    Color? splash,
    Color? onSplash,
    Color? dangerOnHero,
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
      heroTrack: heroTrack ?? this.heroTrack,
      lineStrong: lineStrong ?? this.lineStrong,
      cardShadow: cardShadow ?? this.cardShadow,
      cardShadowFar: cardShadowFar ?? this.cardShadowFar,
      honey: honey ?? this.honey,
      onHoney: onHoney ?? this.onHoney,
      splash: splash ?? this.splash,
      onSplash: onSplash ?? this.onSplash,
      dangerOnHero: dangerOnHero ?? this.dangerOnHero,
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
      heroTrack: mix(heroTrack, other.heroTrack),
      lineStrong: mix(lineStrong, other.lineStrong),
      cardShadow: mix(cardShadow, other.cardShadow),
      cardShadowFar: mix(cardShadowFar, other.cardShadowFar),
      honey: mix(honey, other.honey),
      onHoney: mix(onHoney, other.onHoney),
      splash: mix(splash, other.splash),
      onSplash: mix(onSplash, other.onSplash),
      dangerOnHero: mix(dangerOnHero, other.dangerOnHero),
    );
  }
}
