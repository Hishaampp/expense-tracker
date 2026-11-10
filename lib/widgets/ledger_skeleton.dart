import 'dart:async';

import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Placeholder rows shown while a ledger loads. Stays blank briefly so a
/// fast load does not flash.
class LedgerSkeleton extends StatefulWidget {
  /// Creates a skeleton of [rowCount] rows, announced as [semanticLabel].
  const new({required this.semanticLabel, this.rowCount = 5, super.key});

  /// What a screen reader says, for example "Loading".
  final String semanticLabel;

  /// Number of placeholder rows.
  final int rowCount;

  @override
  State<LedgerSkeleton> createState() => _LedgerSkeletonState();
}

class _LedgerSkeletonState extends State<LedgerSkeleton> {
  Timer? _delay;
  bool _visible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _delay ??= Timer(AppMotion.of(context).medium, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    return Semantics(
      label: widget.semanticLabel,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.rowCount; i++) ...[
              SizedBox(
                height: metrics.minTapTarget,
                child: Center(
                  child: SizedBox(
                    height: metrics.spaceMd,
                    width: double.infinity,
                    child: ColoredBox(color: colors.hairline),
                  ),
                ),
              ),
              const Divider(),
            ],
          ],
        ),
      ),
    );
  }
}
