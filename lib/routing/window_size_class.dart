/// Material 3 window size classes, by available width.
enum WindowSizeClass {
  /// Under 600: phones.
  compact,

  /// 600–839: small tablets, unfolded foldables.
  medium,

  /// 840 and wider: tablets and desktops.
  expanded,
}

/// The size class for a window [width] in logical pixels.
WindowSizeClass windowSizeClassFor(double width) => switch (width) {
  < 600 => WindowSizeClass.compact,
  < 840 => WindowSizeClass.medium,
  _ => WindowSizeClass.expanded,
};
