import 'package:flutter/material.dart';

/// The bundled Latin face. Registered in pubspec.yaml under this name.
const String appFontFamily = 'Anek Latin';

/// Faces tried when [appFontFamily] lacks a glyph (Hindi, Punjabi; then the
/// platform default). The Devanagari and Gurmukhi faces are bundled when
/// those languages are added.
const List<String> appFontFallback = <String>[
  'Anek Devanagari',
  'Anek Gurmukhi',
];

const List<FontFeature> _tabular = <FontFeature>[FontFeature.tabularFigures()];

/// Builds the Material text theme in [color], with secondary text in [muted].
TextTheme buildTextTheme({required Color color, required Color muted}) {
  TextStyle style(double size, FontWeight weight, double height, Color c) {
    return TextStyle(
      fontFamily: appFontFamily,
      fontFamilyFallback: appFontFallback,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: c,
    );
  }

  return TextTheme(
    headlineMedium: style(24, FontWeight.w600, 1.2, color),
    titleLarge: style(20, FontWeight.w600, 1.25, color),
    titleMedium: style(16, FontWeight.w500, 1.3, color),
    bodyLarge: style(16, FontWeight.w400, 1.4, color),
    bodyMedium: style(14, FontWeight.w400, 1.4, color),
    bodySmall: style(13, FontWeight.w400, 1.35, muted),
    labelLarge: style(15, FontWeight.w500, 1.2, color),
    labelMedium: style(13, FontWeight.w500, 1.2, color),
  );
}

/// Text styles for money. Digits are equal-width so amounts line up in a
/// column. Colour is not set here: the money state decides it.
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  /// Creates the money styles; use [AppTextStyles.standard].
  const new({
    required this.amountHero,
    required this.amountLarge,
    required this.amountRow,
  });

  /// The Passbook money styles.
  static const AppTextStyles standard = AppTextStyles(
    amountHero: TextStyle(
      fontFamily: appFontFamily,
      fontFamilyFallback: appFontFallback,
      fontSize: 40,
      fontWeight: FontWeight.w600,
      height: 1.1,
      letterSpacing: -0.5,
      fontFeatures: _tabular,
    ),
    amountLarge: TextStyle(
      fontFamily: appFontFamily,
      fontFamilyFallback: appFontFallback,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.2,
      fontFeatures: _tabular,
    ),
    amountRow: TextStyle(
      fontFamily: appFontFamily,
      fontFamilyFallback: appFontFallback,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.3,
      fontFeatures: _tabular,
    ),
  );

  /// The one big number on a screen (month spend, keypad amount).
  final TextStyle amountHero;

  /// Secondary totals (safe to spend, money in, Room total).
  final TextStyle amountLarge;

  /// The amount column of a transaction row.
  final TextStyle amountRow;

  /// Reads the money styles from the theme; asserts if the theme lacks them.
  static AppTextStyles of(BuildContext context) {
    final extension = Theme.of(context).extension<AppTextStyles>();
    assert(extension != null, 'AppTextStyles missing: use buildAppTheme().');
    return extension!;
  }

  @override
  AppTextStyles copyWith({
    TextStyle? amountHero,
    TextStyle? amountLarge,
    TextStyle? amountRow,
  }) {
    return AppTextStyles(
      amountHero: amountHero ?? this.amountHero,
      amountLarge: amountLarge ?? this.amountLarge,
      amountRow: amountRow ?? this.amountRow,
    );
  }

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) {
    if (other == null) return this;
    return AppTextStyles(
      amountHero: TextStyle.lerp(amountHero, other.amountHero, t)!,
      amountLarge: TextStyle.lerp(amountLarge, other.amountLarge, t)!,
      amountRow: TextStyle.lerp(amountRow, other.amountRow, t)!,
    );
  }
}
