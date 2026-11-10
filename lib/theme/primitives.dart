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

  /// #F6F1EA.
  static const Color sand96 = Color(0xFFF6F1EA);

  /// #EFE9E2.
  static const Color sand94 = Color(0xFFEFE9E2);

  /// #FFFFFF.
  static const Color white100 = Color(0xFFFFFFFF);

  /// #141414.
  static const Color ink19 = Color(0xFF141414);

  /// #6B655F.
  static const Color stone51 = Color(0xFF6B655F);

  /// #A8A29C.
  static const Color stone72 = Color(0xFFA8A29C);

  /// #E2600F.
  static const Color saffron64 = Color(0xFFE2600F);

  /// #C8500A.
  static const Color saffron58 = Color(0xFFC8500A);

  /// #AD4806.
  static const Color saffron53 = Color(0xFFAD4806);

  /// #1A7742.
  static const Color green50 = Color(0xFF1A7742);

  /// #5BD38F.
  static const Color green78 = Color(0xFF5BD38F);

  /// #C93439.
  static const Color red56 = Color(0xFFC93439);

  /// #7A4F00.
  static const Color amber46 = Color(0xFF7A4F00);

  /// #FCEBC5.
  static const Color amber94 = Color(0xFFFCEBC5);

  /// #0F0E0D.
  static const Color night16 = Color(0xFF0F0E0D);

  /// #1C1A18.
  static const Color night22 = Color(0xFF1C1A18);

  /// #2A2724.
  static const Color night27 = Color(0xFF2A2724);

  /// #262320.
  static const Color night26 = Color(0xFF262320);

  /// #F4F1EC.
  static const Color stone96 = Color(0xFFF4F1EC);

  /// #A8A19A.
  static const Color stone71 = Color(0xFFA8A19A);

  /// #B3ADA6.
  static const Color stone75 = Color(0xFFB3ADA6);

  /// #FF8A3D.
  static const Color saffron75 = Color(0xFFFF8A3D);

  /// #FF9A55.
  static const Color saffron78 = Color(0xFFFF9A55);

  /// #1A0E05.
  static const Color saffron18 = Color(0xFF1A0E05);

  /// #FF7B7F.
  static const Color red74 = Color(0xFFFF7B7F);

  /// #F5D58A.
  static const Color amber88 = Color(0xFFF5D58A);

  /// #3A2E0F.
  static const Color amber31 = Color(0xFF3A2E0F);

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
}
