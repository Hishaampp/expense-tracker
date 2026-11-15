import 'dart:ui';

/// Tier-1 colour primitives — the only file allowed a raw colour literal.
///
/// Named hue + OKLCH lightness ×100 (the measured value). Widgets never read
/// these; they read `AppColors` and `CategoryColors`.
abstract final class Primitives {
  /// Black at 8% opacity: the soft shadow under floating controls (light).
  static const Color shadow08 = Color(0x14000000);

  /// Black at 40% opacity: the shadow under floating controls (dark).
  static const Color shadow40 = Color(0x66000000);

  /// #FFFFFF.
  static const Color white100 = Color(0xFFFFFFFF);

  /// #E2600F.
  static const Color tileOrange64 = Color(0xFFE2600F);

  /// #1E9550.
  static const Color tileGreen59 = Color(0xFF1E9550);

  /// #3B5BDB.
  static const Color tileBlue53 = Color(0xFF3B5BDB);

  /// #D9383E.
  static const Color tileRed59 = Color(0xFFD9383E);

  /// #A63BBF.
  static const Color tilePurple56 = Color(0xFFA63BBF);

  /// #B87300.
  static const Color tileAmber62 = Color(0xFFB87300);

  /// #6A4FE0.
  static const Color tileViolet54 = Color(0xFF6A4FE0);

  /// #0F8A80.
  static const Color tileTeal57 = Color(0xFF0F8A80);

  /// #C2347A.
  static const Color tilePink56 = Color(0xFFC2347A);

  /// #7A746E.
  static const Color tileGrey56 = Color(0xFF7A746E);

  // Ample brand kit (tokens.json, 2026-11-15): named by brand token.

  /// #FFFFFF (surface, light).
  static const Color brandWhite = Color(0xFFFFFFFF);

  /// #0D0D0D (surface, dark).
  static const Color brandNight = Color(0xFF0D0D0D);

  /// #181818 (surface-raised, dark).
  static const Color brandNightRaised = Color(0xFF181818);

  /// #F4EFE5 (surface-sunken, light).
  static const Color brandSand = Color(0xFFF4EFE5);

  /// #050505 (surface-sunken, dark).
  static const Color brandNightSunken = Color(0xFF050505);

  /// #121212 (ink, light; card-ink, light).
  static const Color brandInk = Color(0xFF121212);

  /// #F4F1EA (ink, dark; on-card, dark).
  static const Color brandInkDark = Color(0xFFF4F1EA);

  /// #616161 (ink-muted, light).
  static const Color brandInkMuted = Color(0xFF616161);

  /// #ABABAB (ink-muted, dark).
  static const Color brandInkMutedDark = Color(0xFFABABAB);

  /// #EAE3D6 (line, light).
  static const Color brandLine = Color(0xFFEAE3D6);

  /// #2A2A2A (line, dark).
  static const Color brandLineDark = Color(0xFF2A2A2A);

  /// #8A8270 (line-strong, light).
  static const Color brandLineStrong = Color(0xFF8A8270);

  /// #6E6E6E (line-strong, dark).
  static const Color brandLineStrongDark = Color(0xFF6E6E6E);

  /// #F2B33D (honey: the signature fill).
  static const Color brandHoney = Color(0xFFF2B33D);

  /// #7A5200 (honey-ink, light).
  static const Color brandHoneyInk = Color(0xFF7A5200);

  /// #F5C25E (honey-ink, dark).
  static const Color brandHoneyInkDark = Color(0xFFF5C25E);

  /// #FCEBC4 (honey-soft, light).
  static const Color brandHoneySoft = Color(0xFFFCEBC4);

  /// #3A2F17 (honey-soft, dark).
  static const Color brandHoneySoftDark = Color(0xFF3A2F17);

  /// #1E1E1E (card-ink, dark).
  static const Color brandCardInkDark = Color(0xFF1E1E1E);

  /// #BDBDBD (on-card-muted).
  static const Color brandOnCardMuted = Color(0xFFBDBDBD);

  /// #333333 (card-track, light).
  static const Color brandCardTrack = Color(0xFF333333);

  /// #3A3A3A (card-track, dark).
  static const Color brandCardTrackDark = Color(0xFF3A3A3A);

  /// #1B7346 (income, light).
  static const Color brandIncome = Color(0xFF1B7346);

  /// #55C68F (income, dark).
  static const Color brandIncomeDark = Color(0xFF55C68F);

  /// #B3261E (danger, light).
  static const Color brandDanger = Color(0xFFB3261E);

  /// #FF8A78 (danger, dark).
  static const Color brandDangerDark = Color(0xFFFF8A78);

  /// #000000 (shadow-card near layer: black 5%).
  static const Color brandShadowNear = Color(0x0D000000);

  /// #000000 (shadow-card far layer: black 6%).
  static const Color brandShadowFar = Color(0x0F000000);

  /// #FFFFFF (shadow-card, dark: white 4%).
  static const Color brandShadowDark = Color(0x0AFFFFFF);
}
