import 'package:expense_tracker/core/money.dart';
import 'package:meta/meta.dart';

/// A UPI payment request read from a QR code (Phase 11): who to pay and,
/// for a shop's billing QR, how much.
@immutable
final class UpiRequest {
  const new _({
    required this.payeeVpa,
    required this.payeeName,
    required this.amount,
    required this.isFixed,
    required this.uri,
  });

  /// Reads [text] from a QR code. Returns null unless it is a UPI payment
  /// request (`upi://pay?pa=…`) with a valid UPI id; anything else, such as
  /// a website or a "collect" request, is not paid from this app.
  static UpiRequest? tryParse(String text) {
    final uri = Uri.tryParse(text.trim());
    if (uri == null) return null;
    if (uri.scheme.toLowerCase() != 'upi') return null;
    if (uri.host.toLowerCase() != 'pay') return null;
    final params = {
      for (final e in uri.queryParameters.entries) e.key.toLowerCase(): e.value,
    };
    final vpa = params['pa']?.trim().toLowerCase();
    if (vpa == null || !_vpa.hasMatch(vpa)) return null;
    final currency = params['cu']?.trim().toUpperCase();
    if (currency != null && currency.isNotEmpty && currency != 'INR') {
      return null;
    }
    final name = params['pn']?.trim();
    final amount = _amount(params['am']);
    // A signed QR (a shop's billing counter) or one carrying an order
    // reference must be paid exactly as scanned.
    final fixed =
        amount != null &&
        ((params['sign']?.isNotEmpty ?? false) ||
            (params['tr']?.isNotEmpty ?? false));
    return UpiRequest._(
      payeeVpa: vpa,
      payeeName: name == null || name.isEmpty ? null : name,
      amount: amount,
      isFixed: fixed,
      uri: uri,
    );
  }

  /// The payee's UPI id, lower case ("sharmastore@okicici").
  final String payeeVpa;

  /// The name in the QR ("Sharma Store"), or null when it has none.
  final String? payeeName;

  /// The amount in the QR, or null when the payer types it.
  final Money? amount;

  /// Whether the amount must not be changed (a signed or billing QR).
  final bool isFixed;

  /// The request exactly as scanned.
  final Uri uri;

  /// The name to show and record: the QR's name, else the UPI id.
  String get displayName => payeeName ?? payeeVpa;

  /// The payment link to hand to a UPI app for [amount]. A fixed request
  /// is passed on unchanged; otherwise the typed amount and the payee are
  /// all that is sent.
  Uri payUri(Money amount) {
    if (isFixed) return uri;
    final rupees = (amount.paise ~/ 100).toString();
    final paise = (amount.paise % 100).toString().padLeft(2, '0');
    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': payeeVpa,
        'pn': ?payeeName,
        'am': '$rupees.$paise',
        'cu': 'INR',
      },
    );
  }

  static final RegExp _vpa = RegExp(
    r'^[a-z0-9._-]{1,256}@[a-z][a-z0-9.-]{1,63}$',
  );

  static Money? _amount(String? text) {
    final value = text?.trim();
    if (value == null || value.isEmpty) return null;
    final match = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(value);
    if (match == null) return null;
    final whole = int.parse(match.group(1)!);
    final fraction = (match.group(2) ?? '').padRight(2, '0');
    final paise = whole * 100 + int.parse(fraction);
    return paise > 0 ? Money(paise) : null;
  }
}
