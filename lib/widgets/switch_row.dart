import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';

/// A settings row with a leading tile, a title and a switch. The whole row
/// toggles; a screen reader hears it as one switch.
class SwitchRow extends StatelessWidget {
  /// Creates the row.
  const new({
    required this.leading,
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Leading tile.
  final Widget leading;

  /// What the switch controls.
  final String title;

  /// Whether it is on.
  final bool value;

  /// Called with the new value.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(metrics.radiusTileLarge),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: metrics.minTapTarget),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: metrics.spaceSm),
            child: Row(
              children: [
                leading,
                SizedBox(width: metrics.spaceMd),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Switch(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
