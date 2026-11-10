import 'package:flutter/material.dart';

/// Motion slots: quick and flat. Always spend them through [resolveMotion].
@immutable
class AppMotion extends ThemeExtension<AppMotion> {
  /// Creates a motion set; use [AppMotion.standard].
  const new({
    required this.quick,
    required this.medium,
    required this.enter,
    required this.exit,
  });

  /// The Passbook motion: short durations, no bounce.
  static const AppMotion standard = AppMotion(
    quick: Duration(milliseconds: 120),
    medium: Duration(milliseconds: 200),
    enter: Curves.easeOutCubic,
    exit: Curves.easeInCubic,
  );

  /// Presses, the confirm "stamp", chip selection.
  final Duration quick;

  /// Sheets, the budget bar filling, list changes.
  final Duration medium;

  /// Curve for things arriving.
  final Curve enter;

  /// Curve for things leaving.
  final Curve exit;

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
    Curve? enter,
    Curve? exit,
  }) {
    return AppMotion(
      quick: quick ?? this.quick,
      medium: medium ?? this.medium,
      enter: enter ?? this.enter,
      exit: exit ?? this.exit,
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

/// Returns [full], or [Duration.zero] when the OS asks for reduced motion.
Duration resolveMotion(BuildContext context, Duration full) {
  return MediaQuery.disableAnimationsOf(context) ? Duration.zero : full;
}
