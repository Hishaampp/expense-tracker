import 'dart:async';

import 'package:flutter/services.dart';

/// Touch feedback, named by event rather than by strength, so intensity is
/// decided in one place (docs/DESIGN.md, "Motion").
abstract interface class Haptics {
  /// A key press or selection.
  void select();

  /// A saved change.
  void commit();

  /// Input that was not accepted.
  void reject();
}

/// Plays haptics through the platform.
final class SystemHaptics implements Haptics {
  /// Creates the service.
  const new();

  @override
  void select() => unawaited(HapticFeedback.selectionClick());

  @override
  void commit() => unawaited(HapticFeedback.lightImpact());

  @override
  void reject() => unawaited(HapticFeedback.lightImpact());
}
