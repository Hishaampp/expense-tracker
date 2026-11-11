import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:flutter/cupertino.dart';
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
  final minButtonSize = Size(metrics.minTapTarget, metrics.minTapTarget);
  const pill = StadiumBorder();

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: _colorScheme(brightness, colors),
    scaffoldBackgroundColor: colors.background,
    canvasColor: colors.background,
    textTheme: textTheme,
    fontFamily: appFontFamily,
    fontFamilyFallback: appFontFallback,
    splashFactory: NoSplash.splashFactory,
    highlightColor: colors.surfaceSunken,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    dividerTheme: DividerThemeData(
      color: colors.hairline,
      thickness: metrics.hairlineWidth,
      space: metrics.hairlineWidth,
    ),
    iconTheme: IconThemeData(color: colors.onSurface),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleMedium,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: pill,
        backgroundColor: colors.accentFill,
        foregroundColor: colors.onAccentFill,
        minimumSize: Size.fromHeight(metrics.roundButtonSize + metrics.spaceSm),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: pill,
        minimumSize: minButtonSize,
        foregroundColor: colors.accentText,
        backgroundColor: colors.surface,
        side: BorderSide.none,
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: pill,
        minimumSize: minButtonSize,
        foregroundColor: colors.accentText,
        textStyle: textTheme.labelMedium,
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colors.background,
      indicatorColor: colors.surfaceSunken,
      selectedIconTheme: IconThemeData(color: colors.accentText),
      selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
        color: colors.accentText,
      ),
      unselectedLabelTextStyle: textTheme.labelSmall,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.onAccentFill
            : colors.onSurfaceMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.accentFill
            : colors.surfaceSunken,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.accentFill
            : colors.onSurfaceMuted,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      elevation: 0,
      showDragHandle: true,
      dragHandleColor: colors.surfaceSunken,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(metrics.radiusCard),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(metrics.radiusCard),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(metrics.radiusCard),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.hero,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: colors.onHero),
      actionTextColor: colors.accent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(metrics.radiusTileLarge),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceSunken,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(metrics.radiusTileLarge),
        borderSide: BorderSide.none,
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[
      colors,
      metrics,
      AppMotion.standard,
      AppTextStyles.standard,
      CategoryColors.standard,
    ],
  );
}

// Hand-authored: every role the app or a Material widget reads is stated.
ColorScheme _colorScheme(Brightness brightness, AppColors c) {
  return ColorScheme(
    brightness: brightness,
    primary: c.accentFill,
    onPrimary: c.onAccentFill,
    secondary: c.accentFill,
    onSecondary: c.onAccentFill,
    secondaryContainer: c.surfaceSunken,
    onSecondaryContainer: c.onSurface,
    tertiary: c.moneyIn,
    onTertiary: c.surface,
    error: c.danger,
    onError: c.surface,
    surface: c.surface,
    onSurface: c.onSurface,
    onSurfaceVariant: c.onSurfaceMuted,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surface,
    surfaceContainerHighest: c.surfaceSunken,
    outline: c.onSurfaceMuted,
    outlineVariant: c.hairline,
    surfaceTint: c.surface,
    inverseSurface: c.hero,
    onInverseSurface: c.onHero,
  );
}
