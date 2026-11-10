import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Makes [child] tappable with a gentle press: it scales down slightly while
/// the finger is on it (none under reduced motion). Keyboard focus and the
/// screen-reader tap come from the [InkWell] inside.
class Pressable extends StatefulWidget {
  /// Creates the wrapper.
  const new({
    required this.onTap,
    required this.child,
    this.shape = const RoundedRectangleBorder(),
    super.key,
  });

  /// Called on tap; null makes [child] static.
  final VoidCallback? onTap;

  /// The tappable content.
  final Widget child;

  /// The outline used for the focus highlight.
  final ShapeBorder shape;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool pressed) {
    if (_pressed != pressed && mounted) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    if (onTap == null) return widget.child;
    final motion = AppMotion.of(context);
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed && !reducesMotion(context)
            ? AppMetrics.of(context).pressedScale
            : 1,
        duration: resolveMotion(context, motion.quick),
        curve: motion.enter,
        child: InkWell(
          onTap: onTap,
          customBorder: widget.shape,
          child: widget.child,
        ),
      ),
    );
  }
}
