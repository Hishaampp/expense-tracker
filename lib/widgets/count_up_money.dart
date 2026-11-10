import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Builds text for [money] that counts from its previous value (or zero, the
/// first time) to the new one. Under reduced motion the final value shows at
/// once. The [builder] gets the amount to show on each frame.
class CountUpMoney extends StatelessWidget {
  /// Creates the counter.
  const new({required this.money, required this.builder, super.key});

  /// The value to arrive at.
  final Money money;

  /// Builds the widget for the amount shown on this frame.
  final Widget Function(BuildContext context, Money shown) builder;

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: money.paise.toDouble()),
      duration: resolveMotion(context, motion.countUp),
      curve: motion.enter,
      builder: (context, value, _) =>
          builder(context, Money(value.round(), money.currency)),
    );
  }
}
