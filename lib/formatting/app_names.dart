import 'package:expense_tracker/l10n/app_localizations.dart';

const Map<String, String> _known = {
  'com.google.android.apps.messaging': 'Google Messages',
  'com.samsung.android.messaging': 'Samsung Messages',
  'com.google.android.apps.nbu.paisa.user': 'Google Pay',
  'com.phonepe.app': 'PhonePe',
  'net.one97.paytm': 'Paytm',
  'in.org.npci.upiapp': 'BHIM',
};

/// A readable name for the app with [package]. The phone's default SMS app
/// ([defaultSms]) is "Your SMS app" unless its name is known.
String appNameFor(AppLocalizations l10n, String package, {String? defaultSms}) {
  return _known[package] ??
      (package == defaultSms ? l10n.autoCaptureYourSmsApp : package);
}
