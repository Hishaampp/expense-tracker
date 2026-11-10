import 'package:expense_tracker/theme/primitives.dart';
import 'package:flutter/material.dart';

/// Tier-2 semantic colour slots. Widgets read these, never a primitive.
///
/// Every money state also has a non-colour signal (sign, icon, label); these
/// colours only reinforce it (docs/DESIGN.md, "Money states").
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates a colour set; use [AppColors.light] or [AppColors.dark].
  const new({
    required this.surface,
    required this.surfaceRaised,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.hairline,
    required this.rule,
    required this.accent,
    required this.onAccent,
    required this.moneyIn,
    required this.danger,
    required this.review,
    required this.reviewContainer,
    required this.reviewOutline,
  });

  /// The light "Passbook" palette.
  static const AppColors light = AppColors(
    surface: Primitives.slate98,
    surfaceRaised: Primitives.white100,
    onSurface: Primitives.navy26,
    onSurfaceMuted: Primitives.slate46,
    hairline: Primitives.slate90,
    rule: Primitives.navy26,
    accent: Primitives.blue43,
    onAccent: Primitives.white100,
    moneyIn: Primitives.green52,
    danger: Primitives.red50,
    review: Primitives.amber43,
    reviewContainer: Primitives.amber96,
    reviewOutline: Primitives.amber51,
  );

  /// The dark "Passbook" palette, authored by hand (not a flip of light).
  static const AppColors dark = AppColors(
    surface: Primitives.navy20,
    surfaceRaised: Primitives.navy25,
    onSurface: Primitives.slate94,
    onSurfaceMuted: Primitives.slate77,
    hairline: Primitives.navy35,
    rule: Primitives.slate94,
    accent: Primitives.blue78,
    onAccent: Primitives.navy20,
    moneyIn: Primitives.green80,
    danger: Primitives.red79,
    review: Primitives.amber88,
    reviewContainer: Primitives.amber31,
    reviewOutline: Primitives.amber78,
  );

  /// Page background ("paper").
  final Color surface;

  /// Background of sheets, dialogs and raised panels.
  final Color surfaceRaised;

  /// Primary text and icons ("ink"); also plain spent amounts.
  final Color onSurface;

  /// Supporting text; also transfers, which are not spending.
  final Color onSurfaceMuted;

  /// Row dividers.
  final Color hairline;

  /// The heavy ruled line that opens a ledger block.
  final Color rule;

  /// Primary actions, selection and the budget bar.
  final Color accent;

  /// Text and icons on [accent].
  final Color onAccent;

  /// Money received.
  final Color moneyIn;

  /// Over budget and destructive actions.
  final Color danger;

  /// Text and icons for "needs review".
  final Color review;

  /// Fill behind "needs review" badges.
  final Color reviewContainer;

  /// Dashed outline of "needs review" items.
  final Color reviewOutline;

  /// Reads the colours from the theme; asserts if the theme lacks them.
  static AppColors of(BuildContext context) {
    final extension = Theme.of(context).extension<AppColors>();
    assert(extension != null, 'AppColors missing: use buildAppTheme().');
    return extension!;
  }

  @override
  AppColors copyWith({
    Color? surface,
    Color? surfaceRaised,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? hairline,
    Color? rule,
    Color? accent,
    Color? onAccent,
    Color? moneyIn,
    Color? danger,
    Color? review,
    Color? reviewContainer,
    Color? reviewOutline,
  }) {
    return AppColors(
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      hairline: hairline ?? this.hairline,
      rule: rule ?? this.rule,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      moneyIn: moneyIn ?? this.moneyIn,
      danger: danger ?? this.danger,
      review: review ?? this.review,
      reviewContainer: reviewContainer ?? this.reviewContainer,
      reviewOutline: reviewOutline ?? this.reviewOutline,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? b;
    return AppColors(
      surface: mix(surface, other.surface),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      onSurface: mix(onSurface, other.onSurface),
      onSurfaceMuted: mix(onSurfaceMuted, other.onSurfaceMuted),
      hairline: mix(hairline, other.hairline),
      rule: mix(rule, other.rule),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      moneyIn: mix(moneyIn, other.moneyIn),
      danger: mix(danger, other.danger),
      review: mix(review, other.review),
      reviewContainer: mix(reviewContainer, other.reviewContainer),
      reviewOutline: mix(reviewOutline, other.reviewOutline),
    );
  }
}
