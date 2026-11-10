/// Phone makers whose battery savers are known to stop background apps
/// (spec §6.2). Each gets its own setup steps.
enum OemFamily {
  /// Xiaomi, Redmi, POCO.
  xiaomi,

  /// Vivo, iQOO.
  vivo,

  /// Oppo, Realme, OnePlus (ColorOS based).
  oppo,

  /// Samsung.
  samsung,

  /// Anyone else.
  other,
}

/// The family for Android's `Build.MANUFACTURER` value.
OemFamily oemFamilyFor(String? manufacturer) {
  final m = (manufacturer ?? '').toLowerCase();
  if (m.contains('xiaomi') || m.contains('redmi') || m.contains('poco')) {
    return OemFamily.xiaomi;
  }
  if (m.contains('vivo') || m.contains('iqoo')) return OemFamily.vivo;
  if (m.contains('oppo') || m.contains('realme') || m.contains('oneplus')) {
    return OemFamily.oppo;
  }
  if (m.contains('samsung')) return OemFamily.samsung;
  return OemFamily.other;
}
