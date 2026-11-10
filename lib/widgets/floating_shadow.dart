import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/widgets.dart';

/// The one shadow in the app, for controls that float over content.
List<BoxShadow> floatingShadow(BuildContext context) {
  final metrics = AppMetrics.of(context);
  return [
    BoxShadow(
      color: AppColors.of(context).floatingShadow,
      blurRadius: metrics.shadowBlur,
      offset: Offset(0, metrics.shadowOffset),
    ),
  ];
}
