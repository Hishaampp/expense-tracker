import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:expense_tracker/data/sync/sync_crypto.dart';

/// A computer asking for the sync key (Ample for the web, W2): the QR on
/// the website, `AMPLE1:<id>:<public key>`. The id is 16 random bytes in
/// hex; the key is the website's one-time X25519 public key, base64url.
final class ComputerLink {
  const new _(this.id, this.publicKey);

  /// The website's one-time request id.
  final String id;

  /// The website's one-time X25519 public key.
  final List<int> publicKey;

  static final RegExp _shape = RegExp(
    r'^AMPLE1:([0-9a-f]{32}):([A-Za-z0-9_-]{43})$',
  );

  /// The request in [text], or null when it is not an Ample link code.
  static ComputerLink? tryParse(String text) {
    final match = _shape.firstMatch(text.trim());
    if (match == null) return null;
    final key = base64Url.decode('${match.group(2)}=');
    if (key.length != 32) return null;
    return ComputerLink._(match.group(1)!, key);
  }
}

/// The sync key sealed for one computer: the phone's one-time public key
/// and the sealed key, both base64.
typedef SealedLink = ({String phoneKey, String sealed});

/// Seals [key] for [link]: X25519 between a one-time phone key and the
/// website's key, HKDF-SHA-256 to an AES-256-GCM key, the request id as
/// associated data. Only that browser tab can open it.
Future<SealedLink> sealForComputer(
  SyncKey key,
  ComputerLink link, {
  SimpleKeyPair? phoneKeyPair,
  Random? random,
}) async {
  final x25519 = X25519();
  final phone = phoneKeyPair ?? await x25519.newKeyPair();
  final shared = await x25519.sharedSecretKey(
    keyPair: phone,
    remotePublicKey: SimplePublicKey(link.publicKey, type: KeyPairType.x25519),
  );
  final boxKey = await Hkdf(
    hmac: Hmac.sha256(),
    outputLength: 32,
  ).deriveKey(secretKey: shared, info: utf8.encode('ample-link-v1'));
  final r = random ?? Random.secure();
  final box = await AesGcm.with256bits().encrypt(
    key.bytes,
    secretKey: boxKey,
    nonce: [for (var i = 0; i < 12; i++) r.nextInt(256)],
    aad: utf8.encode(link.id),
  );
  final phonePublic = await phone.extractPublicKey();
  return (
    phoneKey: base64.encode(phonePublic.bytes),
    sealed: base64.encode([...box.nonce, ...box.cipherText, ...box.mac.bytes]),
  );
}
