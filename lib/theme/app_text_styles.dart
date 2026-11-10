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

TextStyle _style(
  double size,
  FontWeight weight,
  double height, {
  double letterSpacing = 0,
  List<FontFeature>? features,
}) {
  return TextStyle(
    fontFamily: appFontFamily,
    fontFamilyFallback: appFontFallback,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    fontFeatures: features,
  );
}

/// Builds the Material text theme in [color], with secondary text in [muted].
TextTheme buildTextTheme({required Color color, required Color muted}) {
  return TextTheme(
        displaySmall: _style(36, FontWeight.w700, 1.1, letterSpacing: -0.7),
        headlineMedium: _style(36, FontWeight.w700, 1.1, letterSpacing: -0.7),
        headlineSmall: _style(26, FontWeight.w700, 1.15, letterSpacing: -0.3),
        titleLarge: _style(22, FontWeight.w700, 1.2, letterSpacing: -0.2),
        titleMedium: _style(18, FontWeight.w700, 1.25),
        bodyLarge: _style(16, FontWeight.w500, 1.35),
        bodyMedium: _style(15, FontWeight.w400, 1.4),
        bodySmall: _style(13, FontWeight.w400, 1.35),
        labelLarge: _style(16, FontWeight.w600, 1.2),
        labelMedium: _style(13, FontWeight.w600, 1.2),
        labelSmall: _style(11, FontWeight.w600, 1.2),
      )
      .apply(bodyColor: color, displayColor: color)
      .copyWith(
        bodySmall: _style(13, FontWeight.w400, 1.35).copyWith(color: muted),
      );
}

/// Text styles for money and the hero card. Digits are equal-width so
/// amounts do not jitter while they count. Colour is not set here: the
/// money state or the surface decides it.
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  /// Creates the styles; use [AppTextStyles.standard].
  const new({
    required this.amountDisplay,
    required this.heroSentence,
    required this.statValue,
    required this.amountRow,
  });

  /// The standard styles.
  static final AppTextStyles standard = AppTextStyles(
    amountDisplay: _style(
      56,
      FontWeight.w700,
      1.05,
      letterSpacing: -1.2,
      features: _tabular,
    ),
    heroSentence: _style(20, FontWeight.w500, 1.3, letterSpacing: -0.2),
    statValue: _style(19, FontWeight.w700, 1.2, features: _tabular),
    amountRow: _style(16, FontWeight.w700, 1.3, features: _tabular),
  );

  /// The amount being typed in Quick Add.
  final TextStyle amountDisplay;

  /// The sentence that opens the hero card.
  final TextStyle heroSentence;

  /// A number in the hero card's stat rows.
  final TextStyle statValue;

  /// The amount at the end of a row.
  final TextStyle amountRow;

  /// Reads the styles from the theme; asserts if the theme lacks them.
  static AppTextStyles of(BuildContext context) {
    final extension = Theme.of(context).extension<AppTextStyles>();
    assert(extension != null, 'AppTextStyles missing: use buildAppTheme().');
    return extension!;
  }

  @override
  AppTextStyles copyWith({
    TextStyle? amountDisplay,
    TextStyle? heroSentence,
    TextStyle? statValue,
    TextStyle? amountRow,
  }) {
    return AppTextStyles(
      amountDisplay: amountDisplay ?? this.amountDisplay,
      heroSentence: heroSentence ?? this.heroSentence,
      statValue: statValue ?? this.statValue,
      amountRow: amountRow ?? this.amountRow,
    );
  }

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) {
    if (other == null) return this;
    return AppTextStyles(
      amountDisplay: TextStyle.lerp(amountDisplay, other.amountDisplay, t)!,
      heroSentence: TextStyle.lerp(heroSentence, other.heroSentence, t)!,
      statValue: TextStyle.lerp(statValue, other.statValue, t)!,
      amountRow: TextStyle.lerp(amountRow, other.amountRow, t)!,
    );
  }
}
