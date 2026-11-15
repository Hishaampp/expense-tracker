/// Whether the app follows the phone's light/dark setting or forces one.
enum AppearanceMode {
  /// Follow the phone.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark;

  /// The mode stored as [name], or [initial] for a missing or unknown
  /// value.
  static AppearanceMode parse(String? name) {
    for (final mode in values) {
      if (mode.name == name) return mode;
    }
    return initial;
  }

  /// What a new user sees before choosing: Ample opens in dark, matching
  /// its launch screen (owner's choice, 2026-11-15).
  static const AppearanceMode initial = dark;
}
