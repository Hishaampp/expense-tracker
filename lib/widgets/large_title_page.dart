import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// A tab screen: a slim bar with floating actions, a big bold title right
/// under it, and [children] as a column of cards. When the big title
/// scrolls away, a small copy fades into the bar.
class LargeTitlePage extends StatefulWidget {
  /// Creates the page.
  const new({
    required this.title,
    required this.children,
    this.actions = const [],
    super.key,
  });

  /// The title widget, usually a `Text` or a tappable month title. It is
  /// shown large under the bar, and small in the bar once scrolled.
  final Widget title;

  /// Floating round buttons at the top end.
  final List<Widget> actions;

  /// The page content, top to bottom. Space between cards is added here.
  final List<Widget> children;

  @override
  State<LargeTitlePage> createState() => _LargeTitlePageState();
}

class _LargeTitlePageState extends State<LargeTitlePage> {
  final ScrollController _scroll = ScrollController();
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final collapsed =
        _scroll.offset > AppMetrics.of(context).headerBarHeight * 0.75;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final bottom = MediaQuery.paddingOf(context).bottom + metrics.spaceXl;
    return Scaffold(
      backgroundColor: colors.background,
      body: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: metrics.readableWidth),
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                toolbarHeight: metrics.headerBarHeight,
                backgroundColor: colors.background,
                surfaceTintColor: colors.background,
                title: _SmallTitle(visible: _collapsed, child: widget.title),
                actions: [
                  ...widget.actions,
                  SizedBox(width: metrics.spaceSm),
                ],
              ),
              SliverPadding(
                padding: EdgeInsetsDirectional.only(
                  start: metrics.spaceLg,
                  end: metrics.spaceLg,
                  bottom: metrics.spaceLg,
                ),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: DefaultTextStyle.merge(
                      style: textTheme.headlineMedium,
                      child: Semantics(header: true, child: widget.title),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsetsDirectional.only(
                  start: metrics.spaceLg,
                  end: metrics.spaceLg,
                  bottom: bottom,
                ),
                sliver: SliverList.separated(
                  itemCount: widget.children.length,
                  itemBuilder: (context, index) => widget.children[index],
                  separatorBuilder: (context, index) =>
                      SizedBox(height: metrics.spaceMd),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The bar's copy of the title: hidden from screen readers (the big title
/// is the one they read) and from taps until it is shown.
class _SmallTitle extends StatelessWidget {
  const new({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: resolveMotion(context, AppMotion.of(context).quick),
          child: child,
        ),
      ),
    );
  }
}
