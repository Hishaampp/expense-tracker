import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// The numeric keypad: 1–9, decimal point, 0 and backspace. Large keys with
/// no borders; each press scales gently.
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
                KeypadKey(
                  label: '$digit',
                  onPressed: () => onDigit(digit),
                  child: Text('$digit'),
                ),
            ],
          ),
        Row(
          children: [
            KeypadKey(
              label: pointLabel,
              onPressed: onPoint,
              child: const Text('.'),
            ),
            KeypadKey(
              label: '0',
              onPressed: () => onDigit(0),
              child: const Text('0'),
            ),
            KeypadKey(
              label: backspaceLabel,
              onPressed: onBackspace,
              child: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
      ],
    );
  }
}

/// One keypad key.
class KeypadKey extends StatelessWidget {
  /// Creates the key.
  const new({
    required this.label,
    required this.onPressed,
    required this.child,
    super.key,
  });

  /// What a screen reader announces.
  final String label;

  /// Called when pressed.
  final VoidCallback onPressed;

  /// The key face.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        onTap: onPressed,
        child: ExcludeSemantics(
          child: Pressable(
            onTap: onPressed,
            shape: const StadiumBorder(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: metrics.minTapTarget + metrics.spaceSm,
              ),
              child: Center(
                child: DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: colors.onSurface),
                  child: IconTheme.merge(
                    data: IconThemeData(color: colors.onSurface),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
