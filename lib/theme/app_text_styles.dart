import 'package:flutter/material.dart';

/// The text face (Ample brand kit: Manrope). Registered in pubspec.yaml.
const String appFontFamily = 'Manrope';

/// The display face for headlines and hero amounts (Ample brand kit:
/// Fraunces, soft, semibold). Registered in pubspec.yaml.
const String displayFontFamily = 'Fraunces';

/// Faces tried when a face lacks a glyph (Hindi, Punjabi; then the platform
/// default). The Devanagari and Gurmukhi faces are bundled when those
/// languages are added.
const List<String> appFontFallback = <String>[
  'Noto Sans Devanagari',
  'Noto Sans Gurmukhi',
];

const List<FontFeature> _tabular = <FontFeature>[FontFeature.tabularFigures()];

TextStyle _style(
  double size,
  FontWeight weight,
  double height, {
  double letterSpacing = 0,
  List<FontFeature>? features,
  String family = appFontFamily,
}) {
  return TextStyle(
    fontFamily: family,
    fontFamilyFallback: appFontFallback,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    fontFeatures: features,
  );
}

TextStyle _display(double size, double height, {double letterSpacing = 0}) =>
    _style(
      size,
      FontWeight.w600,
      height,
      letterSpacing: letterSpacing,
      family: displayFontFamily,
    );

final TextStyle _caption = _style(
  12,
  FontWeight.w500,
  16 / 12,
  letterSpacing: 0.12,
);

/// Builds the Material text theme in [color], with secondary text in [muted].
TextTheme buildTextTheme({required Color color, required Color muted}) {
  return TextTheme(
        // Brand "display-xl" and "display": Fraunces.
        displaySmall: _display(48, 52 / 48, letterSpacing: -0.96),
        headlineMedium: _display(32, 38 / 32, letterSpacing: -0.32),
        headlineSmall: _display(26, 32 / 26, letterSpacing: -0.26),
        titleLarge: _style(20, FontWeight.w700, 28 / 20),
        // Brand "heading".
        titleMedium: _style(18, FontWeight.w700, 26 / 18),
        // Brand "body".
        bodyLarge: _style(16, FontWeight.w400, 24 / 16),
        bodyMedium: _style(15, FontWeight.w400, 22 / 15),
        // Brand "caption": never below 12.
        bodySmall: _caption,
        // Brand "label".
        labelLarge: _style(14, FontWeight.w600, 20 / 14),
        labelMedium: _style(13, FontWeight.w600, 18 / 13),
        labelSmall: _style(12, FontWeight.w600, 16 / 12),
      )
      .apply(bodyColor: color, displayColor: color)
      .copyWith(bodySmall: _caption.copyWith(color: muted));
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
    // Brand "amount-hero": Fraunces, the one big amount on a screen.
    amountDisplay: _style(
      52,
      FontWeight.w600,
      56 / 52,
      letterSpacing: -0.52,
      features: _tabular,
      family: displayFontFamily,
    ),
    heroSentence: _style(
      26,
      FontWeight.w600,
      32 / 26,
      letterSpacing: -0.26,
      family: displayFontFamily,
    ),
    // Brand "amount": tabular so columns line up.
    statValue: _style(18, FontWeight.w700, 26 / 18, features: _tabular),
    amountRow: _style(16, FontWeight.w700, 24 / 16, features: _tabular),
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
