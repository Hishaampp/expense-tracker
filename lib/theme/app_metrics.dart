import 'dart:ui';

import 'package:flutter/material.dart';

/// Spacing, radius and size slots. One set for both brightnesses.
@immutable
class AppMetrics extends ThemeExtension<AppMetrics> {
  /// Creates a metric set; use [AppMetrics.standard].
  const new({
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.spaceXxl,
    required this.radiusCard,
    required this.radiusTile,
    required this.radiusTileLarge,
    required this.iconTileSize,
    required this.iconTileLargeSize,
    required this.iconSize,
    required this.iconLargeSize,
    required this.roundButtonSize,
    required this.heroArrowSize,
    required this.minTapTarget,
    required this.progressHeight,
    required this.hairlineWidth,
    required this.tabBarHeight,
    required this.tabBarRadius,
    required this.readableWidth,
    required this.stackedTextScale,
    required this.pressedScale,
    required this.entranceOffset,
    required this.shakeDistance,
    required this.shadowOffset,
    required this.headerBarHeight,
    required this.titleCollapseOffset,
    required this.shadowBlur,
    required this.ringSize,
    required this.ringStroke,
    required this.donutSize,
    required this.donutStroke,
    required this.chartHeight,
    required this.chartBarRadius,
  });

  /// The standard metrics: 4-point grid, large soft corners.
  static const AppMetrics standard = AppMetrics(
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 12,
    spaceLg: 16,
    spaceXl: 24,
    spaceXxl: 32,
    radiusCard: 24,
    radiusTile: 9,
    radiusTileLarge: 16,
    iconTileSize: 32,
    iconTileLargeSize: 52,
    iconSize: 18,
    iconLargeSize: 24,
    roundButtonSize: 44,
    heroArrowSize: 48,
    minTapTarget: 48,
    progressHeight: 6,
    hairlineWidth: 1,
    tabBarHeight: 64,
    tabBarRadius: 32,
    readableWidth: 560,
    stackedTextScale: 1.5,
    pressedScale: 0.97,
    entranceOffset: 16,
    shakeDistance: 8,
    shadowOffset: 6,
    headerBarHeight: 52,
    titleCollapseOffset: 40,
    shadowBlur: 18,
    ringSize: 96,
    ringStroke: 10,
    donutSize: 184,
    donutStroke: 26,
    chartHeight: 128,
    chartBarRadius: 4,
  );

  /// 4 logical pixels.
  final double spaceXs;

  /// 8 logical pixels.
  final double spaceSm;

  /// 12 logical pixels: icon-to-text gap.
  final double spaceMd;

  /// 16 logical pixels: page gutter and card padding.
  final double spaceLg;

  /// 24 logical pixels: gap between cards.
  final double spaceXl;

  /// 32 logical pixels: gap before a large title.
  final double spaceXxl;

  /// Corner radius of cards and sheets.
  final double radiusCard;

  /// Corner radius of small icon tiles.
  final double radiusTile;

  /// Corner radius of Quick Add category tiles.
  final double radiusTileLarge;

  /// Side of a small icon tile.
  final double iconTileSize;

  /// Side of a Quick Add category tile.
  final double iconTileLargeSize;

  /// Glyph size inside a small icon tile.
  final double iconSize;

  /// Glyph size inside a large tile and in round buttons.
  final double iconLargeSize;

  /// Diameter of floating round buttons.
  final double roundButtonSize;

  /// Diameter of the arrow button on the hero card.
  final double heroArrowSize;

  /// Minimum height and width of anything tappable.
  final double minTapTarget;

  /// Height of progress bars.
  final double progressHeight;

  /// Thickness of a divider.
  final double hairlineWidth;

  /// Height of the floating tab bar.
  final double tabBarHeight;

  /// Corner radius of the floating tab bar.
  final double tabBarRadius;

  /// Maximum content width on tablets and foldables.
  final double readableWidth;

  /// System text scale from which a row puts its amount under the title.
  final double stackedTextScale;

  /// Scale of a card or tile while pressed.
  final double pressedScale;

  /// Distance content rises while it fades in.
  final double entranceOffset;

  /// Sideways travel of the reject shake.
  final double shakeDistance;

  /// Downward offset of the floating shadow.
  final double shadowOffset;

  /// Height of the bar above a large title, which holds its actions.
  final double headerBarHeight;

  /// How far the page scrolls before the small title fades into the bar.
  final double titleCollapseOffset;

  /// Blur radius of the floating shadow.
  final double shadowBlur;

  /// Diameter of the budget ring on Home.
  final double ringSize;

  /// Stroke of the budget ring.
  final double ringStroke;

  /// Diameter of the category donut on Stats.
  final double donutSize;

  /// Stroke of the category donut.
  final double donutStroke;

  /// Height of a bar chart.
  final double chartHeight;

  /// Corner radius of a chart bar.
  final double chartBarRadius;

  /// Reads the metrics from the theme; asserts if the theme lacks them.
  static AppMetrics of(BuildContext context) {
    final extension = Theme.of(context).extension<AppMetrics>();
    assert(extension != null, 'AppMetrics missing: use buildAppTheme().');
    return extension!;
  }

  @override
  AppMetrics copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? spaceXxl,
    double? radiusCard,
    double? radiusTile,
    double? radiusTileLarge,
    double? iconTileSize,
    double? iconTileLargeSize,
    double? iconSize,
    double? iconLargeSize,
    double? roundButtonSize,
    double? heroArrowSize,
    double? minTapTarget,
    double? progressHeight,
    double? hairlineWidth,
    double? tabBarHeight,
    double? tabBarRadius,
    double? readableWidth,
    double? stackedTextScale,
    double? pressedScale,
    double? entranceOffset,
    double? shakeDistance,
    double? shadowOffset,
    double? headerBarHeight,
    double? titleCollapseOffset,
    double? shadowBlur,
    double? ringSize,
    double? ringStroke,
    double? donutSize,
    double? donutStroke,
    double? chartHeight,
    double? chartBarRadius,
  }) {
    return AppMetrics(
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      spaceXxl: spaceXxl ?? this.spaceXxl,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusTile: radiusTile ?? this.radiusTile,
      radiusTileLarge: radiusTileLarge ?? this.radiusTileLarge,
      iconTileSize: iconTileSize ?? this.iconTileSize,
      iconTileLargeSize: iconTileLargeSize ?? this.iconTileLargeSize,
      iconSize: iconSize ?? this.iconSize,
      iconLargeSize: iconLargeSize ?? this.iconLargeSize,
      roundButtonSize: roundButtonSize ?? this.roundButtonSize,
      heroArrowSize: heroArrowSize ?? this.heroArrowSize,
      minTapTarget: minTapTarget ?? this.minTapTarget,
      progressHeight: progressHeight ?? this.progressHeight,
      hairlineWidth: hairlineWidth ?? this.hairlineWidth,
      tabBarHeight: tabBarHeight ?? this.tabBarHeight,
      tabBarRadius: tabBarRadius ?? this.tabBarRadius,
      readableWidth: readableWidth ?? this.readableWidth,
      stackedTextScale: stackedTextScale ?? this.stackedTextScale,
      pressedScale: pressedScale ?? this.pressedScale,
      entranceOffset: entranceOffset ?? this.entranceOffset,
      shakeDistance: shakeDistance ?? this.shakeDistance,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      headerBarHeight: headerBarHeight ?? this.headerBarHeight,
      titleCollapseOffset: titleCollapseOffset ?? this.titleCollapseOffset,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      ringSize: ringSize ?? this.ringSize,
      ringStroke: ringStroke ?? this.ringStroke,
      donutSize: donutSize ?? this.donutSize,
      donutStroke: donutStroke ?? this.donutStroke,
      chartHeight: chartHeight ?? this.chartHeight,
      chartBarRadius: chartBarRadius ?? this.chartBarRadius,
    );
  }

  @override
  AppMetrics lerp(AppMetrics? other, double t) {
    if (other == null) return this;
    double mix(double a, double b) => lerpDouble(a, b, t) ?? b;
    return AppMetrics(
      spaceXs: mix(spaceXs, other.spaceXs),
      spaceSm: mix(spaceSm, other.spaceSm),
      spaceMd: mix(spaceMd, other.spaceMd),
      spaceLg: mix(spaceLg, other.spaceLg),
      spaceXl: mix(spaceXl, other.spaceXl),
      spaceXxl: mix(spaceXxl, other.spaceXxl),
      radiusCard: mix(radiusCard, other.radiusCard),
      radiusTile: mix(radiusTile, other.radiusTile),
      radiusTileLarge: mix(radiusTileLarge, other.radiusTileLarge),
      iconTileSize: mix(iconTileSize, other.iconTileSize),
      iconTileLargeSize: mix(iconTileLargeSize, other.iconTileLargeSize),
      iconSize: mix(iconSize, other.iconSize),
      iconLargeSize: mix(iconLargeSize, other.iconLargeSize),
      roundButtonSize: mix(roundButtonSize, other.roundButtonSize),
      heroArrowSize: mix(heroArrowSize, other.heroArrowSize),
      minTapTarget: mix(minTapTarget, other.minTapTarget),
      progressHeight: mix(progressHeight, other.progressHeight),
      hairlineWidth: mix(hairlineWidth, other.hairlineWidth),
      tabBarHeight: mix(tabBarHeight, other.tabBarHeight),
      tabBarRadius: mix(tabBarRadius, other.tabBarRadius),
      readableWidth: mix(readableWidth, other.readableWidth),
      stackedTextScale: mix(stackedTextScale, other.stackedTextScale),
      pressedScale: mix(pressedScale, other.pressedScale),
      entranceOffset: mix(entranceOffset, other.entranceOffset),
      shakeDistance: mix(shakeDistance, other.shakeDistance),
      shadowOffset: mix(shadowOffset, other.shadowOffset),
      headerBarHeight: mix(headerBarHeight, other.headerBarHeight),
      titleCollapseOffset: mix(titleCollapseOffset, other.titleCollapseOffset),
      shadowBlur: mix(shadowBlur, other.shadowBlur),
      ringSize: mix(ringSize, other.ringSize),
      ringStroke: mix(ringStroke, other.ringStroke),
      donutSize: mix(donutSize, other.donutSize),
      donutStroke: mix(donutStroke, other.donutStroke),
      chartHeight: mix(chartHeight, other.chartHeight),
      chartBarRadius: mix(chartBarRadius, other.chartBarRadius),
    );
  }
}
