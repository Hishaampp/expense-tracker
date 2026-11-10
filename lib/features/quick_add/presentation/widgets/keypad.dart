import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';

/// The numeric keypad: 1–9, decimal point, 0 and backspace.
class Keypad extends StatelessWidget {
  /// Creates the keypad.
  const new({
    required this.onDigit,
    required this.onPoint,
    required this.onBackspace,
    required this.pointLabel,
    required this.backspaceLabel,
    super.key,
  });

  /// Called with the digit pressed.
  final ValueChanged<int> onDigit;

  /// Called when the decimal point is pressed.
  final VoidCallback onPoint;

  /// Called when backspace is pressed.
  final VoidCallback onBackspace;

  /// Screen-reader label of the decimal point key.
  final String pointLabel;

  /// Screen-reader label of the backspace key.
  final String backspaceLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            children: [
              for (final digit in row)
                _Key(onPressed: () => onDigit(digit), child: Text('$digit')),
            ],
          ),
        Row(
          children: [
            _Key(
              onPressed: onPoint,
              semanticLabel: pointLabel,
              child: const Text('.'),
            ),
            _Key(onPressed: () => onDigit(0), child: const Text('0')),
            _Key(
              onPressed: onBackspace,
              semanticLabel: backspaceLabel,
              child: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const new({required this.onPressed, required this.child, this.semanticLabel});

  final VoidCallback onPressed;
  final Widget child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final button = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.of(context).onSurface,
        textStyle: textTheme.titleLarge,
        minimumSize: Size.square(AppMetrics.of(context).minTapTarget),
      ),
      child: child,
    );
    final label = semanticLabel;
    return Expanded(
      child: label == null
          ? button
          : Semantics(
              button: true,
              label: label,
              onTap: onPressed,
              child: ExcludeSemantics(child: button),
            ),
    );
  }
}
