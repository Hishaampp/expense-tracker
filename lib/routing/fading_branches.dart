import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Shows one tab branch at a time, keeping every branch's state, and fades
/// the newly selected branch in (instantly under reduced motion).
class FadingBranches extends StatefulWidget {
  /// Creates the container for [children], showing [index].
  const new({required this.index, required this.children, super.key});

  /// The branch to show.
  final int index;

  /// One navigator per tab.
  final List<Widget> children;

  @override
  State<FadingBranches> createState() => _FadingBranchesState();
}

class _FadingBranchesState extends State<FadingBranches>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    value: 1,
  );

  @override
  void didUpdateWidget(FadingBranches oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    final motion = AppMotion.of(context);
    _fade.duration = resolveMotion(context, motion.medium);
    if (_fade.duration == Duration.zero) {
      _fade.value = 1;
    } else {
      _fade.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: [
        // The same wrapper type for every branch, so no branch loses state
        // when the selection moves.
        for (final (i, child) in widget.children.indexed)
          FadeTransition(
            opacity: i == widget.index ? _fade : kAlwaysCompleteAnimation,
            child: TickerMode(enabled: i == widget.index, child: child),
          ),
      ],
    );
  }
}
