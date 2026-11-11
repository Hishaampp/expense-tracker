/// The Supabase project sync talks to (Phase 9). Both values are public by
/// design: the publishable key only lets a signed-in user reach their own
/// encrypted rows (row-level security, supabase/migrations). Never put the
/// service-role key in the app.
abstract final class CloudConfig {
  /// The project URL.
  static const String url = 'https://rsfiiiyhajwgfnkxuwtr.supabase.co';

  /// The project's publishable key.
  static const String publishableKey =
      'sb_publishable_XcpwLSWBcjVEOT6n56OXzw_cB8Lj0Sj';
}
