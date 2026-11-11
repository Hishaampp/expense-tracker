import 'package:flutter/painting.dart';

/// Proportions of the charts (Stats, budget rings). Kept with the theme so
/// the look changes in one place.
abstract final class ChartStyle {
  /// Share of a bar's slot left empty between bars.
  static const double barGap = 0.45;

  /// The same, when many bars share the width.
  static const double denseBarGap = 0.3;

  /// From how many bars the chart counts as dense.
  static const int denseBarCount = 12;

  /// Length of one dash of a guide line, in hairlines.
  static const double dashHairlines = 4;

  /// How far the centre of a ring keeps from it, in strokes.
  static const double ringInsetStrokes = 1.5;

  /// The gap between donut slices, as a share of the stroke.
  static const double sliceGap = 0.35;

  /// Weight of the label under the highlighted bar.
  static const FontWeight highlightWeight = FontWeight.w700;
}
