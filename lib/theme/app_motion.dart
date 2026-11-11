import 'package:flutter/material.dart';

/// Motion slots: smooth and purposeful. Always spend durations through
/// [resolveMotion] so reduced motion turns them off (docs/DESIGN.md).
@immutable
class AppMotion extends ThemeExtension<AppMotion> {
  /// Creates a motion set; use [AppMotion.standard].
  const new({
    required this.quick,
    required this.medium,
    required this.slow,
    required this.countUp,
    required this.stagger,
    required this.pulse,
    required this.enter,
    required this.exit,
    required this.move,
    required this.pop,
    required this.undoWindow,
    required this.undoWindowAccessible,
  });

  /// The standard motion.
  static const AppMotion standard = AppMotion(
    quick: Duration(milliseconds: 140),
    medium: Duration(milliseconds: 260),
    slow: Duration(milliseconds: 420),
    countUp: Duration(milliseconds: 700),
    stagger: Duration(milliseconds: 55),
    pulse: Duration(milliseconds: 900),
    enter: Curves.easeOutCubic,
    exit: Curves.easeInCubic,
    move: Curves.easeInOutCubic,
    pop: Curves.easeOutBack,
    undoWindow: Duration(seconds: 6),
    undoWindowAccessible: Duration(seconds: 30),
  );

  /// Presses, keypad digits, the selected-tile pop.
  final Duration quick;

  /// Tab switches, the tab pill sliding, sheets.
  final Duration medium;

  /// Screen entrances, route transitions, progress bars filling.
  final Duration slow;

  /// Numbers counting up to their value.
  final Duration countUp;

  /// Delay between items of a staggered entrance.
  final Duration stagger;

  /// One half-cycle of the loading placeholder's pulse.
  final Duration pulse;

  /// Curve for things arriving.
  final Curve enter;

  /// Curve for things leaving.
  final Curve exit;

  /// Curve for things moving from one place to another.
  final Curve move;

  /// Curve for a small emphasis pop (slight overshoot).
  final Curve pop;

  /// How long a snackbar with Undo stays up.
  final Duration undoWindow;

  /// The same, when a screen reader or switch is in use.
  final Duration undoWindowAccessible;

  /// Reads the motion slots from the theme; asserts if the theme lacks them.
  static AppMotion of(BuildContext context) {
    final extension = Theme.of(context).extension<AppMotion>();
    assert(extension != null, 'AppMotion missing: use buildAppTheme().');
    return extension!;
  }

  @override
  AppMotion copyWith({
    Duration? quick,
    Duration? medium,
    Duration? slow,
    Duration? countUp,
    Duration? stagger,
    Duration? pulse,
    Curve? enter,
    Curve? exit,
    Curve? move,
    Curve? pop,
    Duration? undoWindow,
    Duration? undoWindowAccessible,
  }) {
    return AppMotion(
      quick: quick ?? this.quick,
      medium: medium ?? this.medium,
      slow: slow ?? this.slow,
      countUp: countUp ?? this.countUp,
      stagger: stagger ?? this.stagger,
      pulse: pulse ?? this.pulse,
      enter: enter ?? this.enter,
      exit: exit ?? this.exit,
      move: move ?? this.move,
      pop: pop ?? this.pop,
      undoWindow: undoWindow ?? this.undoWindow,
      undoWindowAccessible: undoWindowAccessible ?? this.undoWindowAccessible,
    );
  }

  // Deliberate step: durations and curves do not interpolate meaningfully,
  // and the app does not animate theme changes.
  @override
  AppMotion lerp(AppMotion? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

/// Whether the OS asks for reduced motion.
bool reducesMotion(BuildContext context) {
  return MediaQuery.disableAnimationsOf(context);
}

/// Returns [full], or [Duration.zero] when the OS asks for reduced motion.
Duration resolveMotion(BuildContext context, Duration full) {
  return reducesMotion(context) ? Duration.zero : full;
}

/// How far an onboarding step slides as it changes, as a share of its
/// width.
const double stepSlideShare = 0.08;

/// The size an icon pops in from, as a share of its full size.
const double popStartScale = 0.6;
