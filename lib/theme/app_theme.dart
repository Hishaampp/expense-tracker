import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Builds the app theme for [brightness]. The only place a `ThemeData` is
/// made; every extension is attached for both brightnesses.
ThemeData buildAppTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark
      ? AppColors.dark
      : AppColors.light;
  const metrics = AppMetrics.standard;
  final textTheme = buildTextTheme(
    color: colors.onSurface,
    muted: colors.onSurfaceMuted,
  );
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(metrics.radius),
  );
  final minButtonSize = Size(metrics.minTapTarget, metrics.minTapTarget);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: _colorScheme(brightness, colors),
    scaffoldBackgroundColor: colors.surface,
    textTheme: textTheme,
    fontFamily: appFontFamily,
    fontFamilyFallback: appFontFallback,
    splashFactory: NoSplash.splashFactory,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    dividerTheme: DividerThemeData(
      color: colors.hairline,
      thickness: metrics.hairlineWidth,
      space: metrics.hairlineWidth,
    ),
    iconTheme: IconThemeData(color: colors.onSurface, size: metrics.iconSize),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleMedium,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: shape,
        minimumSize: minButtonSize,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: shape,
        minimumSize: minButtonSize,
        side: BorderSide(color: colors.accent, width: metrics.hairlineWidth),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: shape,
        minimumSize: minButtonSize,
        textStyle: textTheme.labelLarge,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: shape,
      side: BorderSide(color: colors.hairline, width: metrics.hairlineWidth),
      backgroundColor: colors.surface,
      selectedColor: colors.accent,
      labelStyle: textTheme.labelMedium,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surfaceRaised,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(metrics.radius),
        ),
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[
      colors,
      metrics,
      AppMotion.standard,
      AppTextStyles.standard,
    ],
  );
}

// Hand-authored: every role the app or a Material widget reads is stated.
ColorScheme _colorScheme(Brightness brightness, AppColors c) {
  return ColorScheme(
    brightness: brightness,
    primary: c.accent,
    onPrimary: c.onAccent,
    secondary: c.accent,
    onSecondary: c.onAccent,
    tertiary: c.moneyIn,
    onTertiary: c.surface,
    error: c.danger,
    onError: c.surface,
    surface: c.surface,
    onSurface: c.onSurface,
    onSurfaceVariant: c.onSurfaceMuted,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surfaceRaised,
    surfaceContainerHigh: c.surfaceRaised,
    surfaceContainerHighest: c.surfaceRaised,
    outline: c.onSurfaceMuted,
    outlineVariant: c.hairline,
    surfaceTint: c.surface,
  );
}
