import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';

/// A tab screen: a big bold title that shrinks into the bar as you scroll,
/// floating actions at the top end, and [children] as a column of cards.
class LargeTitlePage extends StatelessWidget {
  /// Creates the page.
  const new({
    required this.title,
    required this.children,
    this.actions = const [],
    super.key,
  });

  /// The title widget, usually a `Text` or a tappable month title.
  final Widget title;

  /// Floating round buttons at the top end.
  final List<Widget> actions;

  /// The page content, top to bottom. Space between cards is added here.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom + metrics.spaceXl;
    return Scaffold(
      backgroundColor: colors.background,
      body: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: metrics.readableWidth),
          child: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                backgroundColor: colors.background,
                surfaceTintColor: colors.background,
                centerTitle: false,
                title: title,
                actions: [
                  ...actions,
                  SizedBox(width: metrics.spaceSm),
                ],
              ),
              SliverPadding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  metrics.spaceLg,
                  metrics.spaceSm,
                  metrics.spaceLg,
                  bottom,
                ),
                sliver: SliverList.separated(
                  itemCount: children.length,
                  itemBuilder: (context, index) => children[index],
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
