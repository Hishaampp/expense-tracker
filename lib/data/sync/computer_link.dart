import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:expense_tracker/data/sync/sync_crypto.dart';

/// A computer asking to be signed in and unlocked (Ample for the web): the
/// QR on the website, `AMPLE2:<id>:<public key>`. The id is 16 random bytes
/// in hex; the key is the website's one-time X25519 public key, base64url.
/// Version 2 carries a sign-in as well as the key: only a signed-in phone
/// can let a computer in.
final class ComputerLink {
  const new _(this.id, this.publicKey);

  /// The website's one-time request id.
  final String id;

  /// The website's one-time X25519 public key.
  final List<int> publicKey;

  static final RegExp _shape = RegExp(
    r'^AMPLE2:([0-9a-f]{32}):([A-Za-z0-9_-]{43})$',
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

/// What the phone hands one computer: the sync key, and a one-time sign-in
/// for its own account (a magic-link token made by the link-session
/// function; the computer exchanges it for its own session).
typedef ComputerPass = ({SyncKey key, String email, String tokenHash});

/// The pass sealed for one computer: the phone's one-time public key and
/// the sealed pass, both base64.
typedef SealedLink = ({String phoneKey, String sealed});

/// Seals [pass] for [link]: X25519 between a one-time phone key and the
/// website's key, HKDF-SHA-256 ("ample-link-v2") to an AES-256-GCM key, the
/// request id as associated data. Only that browser tab can open it.
Future<SealedLink> sealForComputer(
  ComputerPass pass,
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
  ).deriveKey(secretKey: shared, info: utf8.encode('ample-link-v2'));
  final r = random ?? Random.secure();
  final plain = utf8.encode(
    jsonEncode({
      'v': 2,
      'key': base64.encode(pass.key.bytes),
      'email': pass.email,
      'token': pass.tokenHash,
    }),
  );
  final box = await AesGcm.with256bits().encrypt(
    plain,
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
