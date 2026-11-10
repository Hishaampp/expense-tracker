import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/widgets/floating_shadow.dart';
import 'package:flutter/material.dart';

/// One tab of the [FloatingTabBar].
typedef TabDestination = ({IconData icon, IconData selectedIcon, String label});

/// A pill-shaped tab bar that floats above the content. The highlight under
/// the selected tab slides to the new one (instantly under reduced motion).
class FloatingTabBar extends StatelessWidget {
  /// Creates the bar.
  const new({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    super.key,
  });

  /// The tabs, start to end.
  final List<TabDestination> destinations;

  /// The selected tab.
  final int selectedIndex;

  /// Called with the index of the tab tapped.
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final motion = AppMotion.of(context);
    final count = destinations.length;
    final radius = BorderRadius.circular(metrics.tabBarRadius);
    return SafeArea(
      // Same inset on both sides, so left/right is direction-neutral here.
      minimum: EdgeInsets.only(
        left: metrics.spaceLg,
        right: metrics.spaceLg,
        bottom: metrics.spaceMd,
      ),
      child: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: metrics.readableWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: radius,
              boxShadow: floatingShadow(context),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.all(metrics.spaceXs),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: metrics.tabBarHeight - metrics.spaceSm,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedAlign(
                        alignment: AlignmentDirectional(
                          count == 1 ? 0 : -1 + 2 * selectedIndex / (count - 1),
                          0,
                        ),
                        duration: resolveMotion(context, motion.medium),
                        curve: motion.move,
                        child: FractionallySizedBox(
                          widthFactor: 1 / count,
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surfaceSunken,
                              borderRadius: radius,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final (index, tab) in destinations.indexed)
                          Expanded(
                            child: _Tab(
                              tab: tab,
                              selected: index == selectedIndex,
                              onTap: () => onSelect(index),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const new({required this.tab, required this.selected, required this.onTap});

  final TabDestination tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final color = selected ? colors.accentText : colors.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: metrics.minTapTarget),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: metrics.spaceXs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(selected ? tab.selectedIcon : tab.icon, color: color),
                  Text(
                    tab.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
