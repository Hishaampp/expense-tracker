import 'dart:ui';

/// Tier-1 colour primitives — the only file allowed a raw colour literal.
///
/// Named `hue` + OKLCH lightness ×100 (the measured value), never by rank or
/// appearance. Widgets must not read these; they read `AppColors`.
abstract final class Primitives {
  /// Navy at OKLCH lightness 20.
  static const Color navy20 = Color(0xFF0E1626);

  /// Navy at OKLCH lightness 25.
  static const Color navy25 = Color(0xFF17223A);

  /// Navy at OKLCH lightness 26.
  static const Color navy26 = Color(0xFF16233F);

  /// Navy at OKLCH lightness 35.
  static const Color navy35 = Color(0xFF2C3A57);

  /// Slate at OKLCH lightness 46.
  static const Color slate46 = Color(0xFF4A5674);

  /// Slate at OKLCH lightness 77.
  static const Color slate77 = Color(0xFFA9B4CC);

  /// Slate at OKLCH lightness 90.
  static const Color slate90 = Color(0xFFD9DEE8);

  /// Slate at OKLCH lightness 94.
  static const Color slate94 = Color(0xFFE6EBF5);

  /// Slate at OKLCH lightness 98.
  static const Color slate98 = Color(0xFFF6F7F9);

  /// White at OKLCH lightness 100.
  static const Color white100 = Color(0xFFFFFFFF);

  /// Blue at OKLCH lightness 43.
  static const Color blue43 = Color(0xFF2747A0);

  /// Blue at OKLCH lightness 78.
  static const Color blue78 = Color(0xFF9DB4F5);

  /// Green at OKLCH lightness 52.
  static const Color green52 = Color(0xFF1C7A52);

  /// Green at OKLCH lightness 80.
  static const Color green80 = Color(0xFF7BD3A8);

  /// Red at OKLCH lightness 50.
  static const Color red50 = Color(0xFFB3261E);

  /// Red at OKLCH lightness 79.
  static const Color red79 = Color(0xFFF2A29B);

  /// Amber at OKLCH lightness 31.
  static const Color amber31 = Color(0xFF3A2E0F);

  /// Amber at OKLCH lightness 43.
  static const Color amber43 = Color(0xFF6B4700);

  /// Amber at OKLCH lightness 51.
  static const Color amber51 = Color(0xFF8A5A00);

  /// Amber at OKLCH lightness 78.
  static const Color amber78 = Color(0xFFD9B24C);

  /// Amber at OKLCH lightness 88.
  static const Color amber88 = Color(0xFFF5D58A);

  /// Amber at OKLCH lightness 96.
  static const Color amber96 = Color(0xFFFFF1CC);
}
