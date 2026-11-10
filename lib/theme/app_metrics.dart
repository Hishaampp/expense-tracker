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
    required this.radius,
    required this.hairlineWidth,
    required this.ruleWidth,
    required this.minTapTarget,
    required this.iconSize,
    required this.barHeight,
    required this.readableWidth,
  });

  /// The Passbook metrics: tight, 4-point grid, small corners.
  static const AppMetrics standard = AppMetrics(
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 12,
    spaceLg: 16,
    spaceXl: 24,
    radius: 6,
    hairlineWidth: 1,
    ruleWidth: 2,
    minTapTarget: 48,
    iconSize: 20,
    barHeight: 6,
    readableWidth: 560,
  );

  /// 4 logical pixels.
  final double spaceXs;

  /// 8 logical pixels.
  final double spaceSm;

  /// 12 logical pixels: gap between an icon and its row text.
  final double spaceMd;

  /// 16 logical pixels: page gutter.
  final double spaceLg;

  /// 24 logical pixels: gap between page blocks.
  final double spaceXl;

  /// Corner radius of buttons, chips, badges and sheets.
  final double radius;

  /// Thickness of row dividers.
  final double hairlineWidth;

  /// Thickness of the heavy rule that opens a ledger block.
  final double ruleWidth;

  /// Minimum height and width of anything tappable.
  final double minTapTarget;

  /// Size of row and button icons.
  final double iconSize;

  /// Height of the budget bar.
  final double barHeight;

  /// Maximum content width on tablets and foldables.
  final double readableWidth;

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
    double? radius,
    double? hairlineWidth,
    double? ruleWidth,
    double? minTapTarget,
    double? iconSize,
    double? barHeight,
    double? readableWidth,
  }) {
    return AppMetrics(
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      radius: radius ?? this.radius,
      hairlineWidth: hairlineWidth ?? this.hairlineWidth,
      ruleWidth: ruleWidth ?? this.ruleWidth,
      minTapTarget: minTapTarget ?? this.minTapTarget,
      iconSize: iconSize ?? this.iconSize,
      barHeight: barHeight ?? this.barHeight,
      readableWidth: readableWidth ?? this.readableWidth,
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
      radius: mix(radius, other.radius),
      hairlineWidth: mix(hairlineWidth, other.hairlineWidth),
      ruleWidth: mix(ruleWidth, other.ruleWidth),
      minTapTarget: mix(minTapTarget, other.minTapTarget),
      iconSize: mix(iconSize, other.iconSize),
      barHeight: mix(barHeight, other.barHeight),
      readableWidth: mix(readableWidth, other.readableWidth),
    );
  }
}
