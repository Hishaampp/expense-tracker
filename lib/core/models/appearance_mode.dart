/// Whether the app follows the phone's light/dark setting or forces one.
enum AppearanceMode {
  /// Follow the phone.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark;

  /// The mode stored as [name], or [system] for a missing or unknown value.
  static AppearanceMode parse(String? name) {
    for (final mode in values) {
      if (mode.name == name) return mode;
    }
    return system;
  }
}
