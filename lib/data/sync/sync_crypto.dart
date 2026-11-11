import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:meta/meta.dart';

/// A record as the server stores it: an opaque id, when it changed, and
/// ciphertext. Nothing else about the user's money reaches the server.
typedef SealedRecord = ({String id, int changedAt, String blob});

/// What a sealed record holds once opened: the table, the row's key, when
/// it changed, and the row itself (null when it was deleted).
typedef RecordPayload = ({
  String table,
  String key,
  int changedAt,
  Map<String, Object?>? row,
});

/// The sync key and what is derived from it (Phase 9). Made on the first
/// phone, kept in the Keystore or Keychain, and carried to another phone
/// only as the recovery code the user writes down.
@immutable
final class SyncKey {
  const new _(this.bytes);

  /// A new random key.
  factory generate([Random? random]) {
    final r = random ?? Random.secure();
    return SyncKey._(
      Uint8List.fromList([for (var i = 0; i < length; i++) r.nextInt(256)]),
    );
  }

  /// The key from a [code] made by [recoveryCode], or null when the code
  /// is mistyped. Spaces, dashes and case do not matter; O reads as 0 and
  /// I or L as 1.
  static SyncKey? fromRecoveryCode(String code) {
    final clean = code
        .toUpperCase()
        .replaceAll(RegExp(r'[\s-]'), '')
        .replaceAll('O', '0')
        .replaceAll(RegExp('[IL]'), '1');
    final bytes = _base32Decode(clean);
    if (bytes == null || bytes.length != length + 1) return null;
    final key = Uint8List.sublistView(bytes, 0, length);
    if (bytes[length] != _check(key)) return null;
    return SyncKey._(Uint8List.fromList(key));
  }

  /// Key length in bytes.
  static const int length = 32;

  /// The raw key.
  final Uint8List bytes;

  /// The key as a code to write down: 53 characters in groups of four,
  /// with a check character so a typo is caught.
  String get recoveryCode {
    final text = _base32Encode(Uint8List.fromList([...bytes, _check(bytes)]));
    return [
      for (var i = 0; i < text.length; i += 4)
        text.substring(i, min(i + 4, text.length)),
    ].join('-');
  }

  @override
  bool operator ==(Object other) =>
      other is SyncKey &&
      other.bytes.length == bytes.length &&
      Iterable<int>.generate(bytes.length)
          .every((i) => other.bytes[i] == bytes[i]);

  @override
  int get hashCode => Object.hashAll(bytes);

  // A one-byte checksum: the low byte of a simple running sum is enough to
  // catch a mistyped character.
  static int _check(List<int> key) {
    var sum = 0;
    for (final (i, b) in key.indexed) {
      sum = (sum + b * (i + 1)) & 0xff;
    }
    return sum;
  }

  static const String _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  static String _base32Encode(Uint8List data) {
    final out = StringBuffer();
    var buffer = 0;
    var bits = 0;
    for (final byte in data) {
      buffer = (buffer << 8) | byte;
      bits += 8;
      while (bits >= 5) {
        out.write(_alphabet[(buffer >> (bits - 5)) & 31]);
        bits -= 5;
      }
    }
    if (bits > 0) out.write(_alphabet[(buffer << (5 - bits)) & 31]);
    return out.toString();
  }

  static Uint8List? _base32Decode(String text) {
    final out = <int>[];
    var buffer = 0;
    var bits = 0;
    for (final char in text.split('')) {
      final value = _alphabet.indexOf(char);
      if (value < 0) return null;
      buffer = ((buffer << 5) | value) & 0xffff;
      bits += 5;
      if (bits >= 8) {
        out.add((buffer >> (bits - 8)) & 0xff);
        bits -= 8;
      }
    }
    return Uint8List.fromList(out);
  }
}

/// Seals and opens sync records with keys derived from a [SyncKey]:
/// AES-256-GCM for the content, and an HMAC for the record id, so the
/// server cannot even tell which table a record belongs to.
class SyncCrypto {
  /// Creates the crypto for [key].
  new(this.key, {Random? random}) : _random = random ?? Random.secure();

  /// The sync key.
  final SyncKey key;
  final Random _random;

  static final AesGcm _cipher = AesGcm.with256bits();
  static final Hmac _hmac = Hmac.sha256();

  late final Future<SecretKey> _contentKey = _derive('records-v1');
  late final Future<SecretKey> _idKey = _derive('ids-v1');

  Future<SecretKey> _derive(String purpose) => Hkdf(
    hmac: Hmac.sha256(),
    outputLength: 32,
  ).deriveKey(secretKey: SecretKey(key.bytes), info: utf8.encode(purpose));

  /// The opaque id of the record for [recordKey] in [table].
  Future<String> recordId(String table, String recordKey) async {
    final mac = await _hmac.calculateMac(
      utf8.encode('$table\u0000$recordKey'),
      secretKey: await _idKey,
    );
    return [for (final b in mac.bytes) b.toRadixString(16).padLeft(2, '0')]
        .join();
  }

  /// [payload] sealed for the server.
  Future<SealedRecord> seal(RecordPayload payload) async {
    final plain = utf8.encode(
      jsonEncode({
        't': payload.table,
        'k': payload.key,
        'at': payload.changedAt,
        'row': payload.row,
      }),
    );
    final box = await _cipher.encrypt(
      plain,
      secretKey: await _contentKey,
      nonce: [for (var i = 0; i < 12; i++) _random.nextInt(256)],
    );
    return (
      id: await recordId(payload.table, payload.key),
      changedAt: payload.changedAt,
      blob: base64.encode([...box.nonce, ...box.cipherText, ...box.mac.bytes]),
    );
  }

  /// Opens [record], or returns null when it was not sealed with this key
  /// or was changed on the way.
  Future<RecordPayload?> open(SealedRecord record) async {
    try {
      final bytes = base64.decode(record.blob);
      if (bytes.length < 12 + 16) return null;
      final plain = await _cipher.decrypt(
        SecretBox(
          bytes.sublist(12, bytes.length - 16),
          nonce: bytes.sublist(0, 12),
          mac: Mac(bytes.sublist(bytes.length - 16)),
        ),
        secretKey: await _contentKey,
      );
      final data = jsonDecode(utf8.decode(plain));
      if (data case {
        't': final String table,
        'k': final String recordKey,
        'at': final int changedAt,
        'row': final Map<String, Object?>? row,
      }) {
        // The id must match the content, so a record cannot be swapped
        // for another one.
        if (await recordId(table, recordKey) != record.id) return null;
        return (table: table, key: recordKey, changedAt: changedAt, row: row);
      }
      return null;
    } on SecretBoxAuthenticationError {
      return null;
    } on FormatException {
      return null;
    }
  }
}
