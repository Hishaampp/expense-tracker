import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/charts/bar_chart.dart';
import 'package:flutter/material.dart';

/// A card with a heading, a bar chart and lines of text that say what the
/// chart shows. The chart itself is silent; [semanticLabel] speaks for it.
class BarsCard extends StatelessWidget {
  /// Creates the card.
  const new({
    required this.title,
    required this.values,
    required this.semanticLabel,
    required this.lines,
    this.highlight,
    this.guide,
    this.labels,
    super.key,
  });

  /// The card's heading.
  final String title;

  /// One value per bar.
  final List<double> values;

  /// What a screen reader hears for the chart.
  final String semanticLabel;

  /// Facts under the chart, for example the highest day.
  final List<String> lines;

  /// The bar drawn in the accent colour.
  final int? highlight;

  /// A dashed guide line's value, for example the average.
  final double? guide;

  /// Text under each bar.
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: textTheme.titleMedium),
          ),
          SizedBox(height: metrics.spaceLg),
          Semantics(
            container: true,
            label: semanticLabel,
            child: BarChart(
              values: values,
              color: colors.surfaceSunken,
              highlightColor: colors.accent,
              guideColor: colors.onSurfaceMuted,
              highlight: highlight,
              guide: guide,
              labels: labels,
            ),
          ),
          SizedBox(height: metrics.spaceMd),
          for (final line in lines)
            ExcludeSemantics(
              child: Padding(
                padding: EdgeInsetsDirectional.only(top: metrics.spaceXs),
                child: Text(line, style: textTheme.bodyMedium),
              ),
            ),
        ],
      ),
    );
  }
}
