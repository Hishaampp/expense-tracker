// The phone's half of "Link a computer". The website's half opens what
// this seals: web/src/lib/link/link-crypto.test.ts, using the cases
// written here. Regenerate after a deliberate change with
//   UPDATE_WEB_VECTORS=1 flutter test test/data/sync/computer_link_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:expense_tracker/data/sync/computer_link.dart';
import 'package:expense_tracker/data/sync/sync_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

const _path = 'web/src/lib/link/fixtures/link-vectors.json';

void main() {
  test('reads the website QR and refuses anything else', () {
    final key = base64Url.encode(List.filled(32, 7)).replaceAll('=', '');
    final good = 'AMPLE2:${'ab' * 16}:$key';
    final link = ComputerLink.tryParse(good)!;
    expect(link.id, 'ab' * 16);
    expect(link.publicKey, List.filled(32, 7));
    expect(ComputerLink.tryParse('upi://pay?pa=a@b'), isNull);
    expect(ComputerLink.tryParse('AMPLE2:${'ab' * 16}:short'), isNull);
    // A version-1 code from an older website asked for the key only.
    expect(
      ComputerLink.tryParse(good.replaceFirst('AMPLE2', 'AMPLE1')),
      isNull,
    );
    expect(ComputerLink.tryParse(good.toUpperCase()), isNull);
  });

  test('the website test case is current', () async {
    final x25519 = X25519();
    final webSeed = List.generate(32, (i) => 32 + i);
    final web = await x25519.newKeyPairFromSeed(webSeed);
    final webPublic = (await web.extractPublicKey()).bytes;
    final phone = await x25519.newKeyPairFromSeed(
      List.generate(32, (i) => 100 + i),
    );
    final key = SyncKey.fromBytes(List.generate(32, (i) => i))!;
    final id = 'c0ffee00' * 4;
    final qr = 'AMPLE2:$id:${base64Url.encode(webPublic).replaceAll('=', '')}';
    const email = 'asha@example.com';
    const tokenHash =
        'pkce_3f2a9c0d6e1b4a7c8d5e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e';
    final sealed = await sealForComputer(
      (key: key, email: email, tokenHash: tokenHash),
      ComputerLink.tryParse(qr)!,
      phoneKeyPair: phone,
      random: Random(5),
    );
    final json = const JsonEncoder.withIndent('  ').convert({
      'qr': qr,
      'id': id,
      'webSeed': webSeed,
      'webPublic': webPublic,
      'phoneKey': sealed.phoneKey,
      'sealed': sealed.sealed,
      'keyBytes': key.bytes,
      'email': email,
      'tokenHash': tokenHash,
    });
    final fresh = '$json\n';
    final file = File(_path);
    if (Platform.environment['UPDATE_WEB_VECTORS'] == '1') {
      file
        ..createSync(recursive: true)
        ..writeAsStringSync(fresh);
    }
    expect(file.readAsStringSync(), fresh);
  });
}
