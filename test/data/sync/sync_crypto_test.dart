import 'dart:math';

import 'package:expense_tracker/data/sync/sync_crypto.dart';
import 'package:test/test.dart';

void main() {
  final key = SyncKey.generate(Random(1));

  test('the recovery code brings back the same key, typed loosely', () {
    final code = key.recoveryCode;
    expect(code.replaceAll('-', ''), hasLength(53));
    expect(SyncKey.fromRecoveryCode(code), key);
    final loose = code.toLowerCase().replaceAll('-', ' ').replaceAll('0', 'o');
    expect(SyncKey.fromRecoveryCode(loose), key);
  });

  test('a mistyped recovery code is refused', () {
    final code = key.recoveryCode;
    final wrong = '${code[0] == 'A' ? 'B' : 'A'}${code.substring(1)}';
    expect(SyncKey.fromRecoveryCode(wrong), isNull);
    expect(SyncKey.fromRecoveryCode('not a code'), isNull);
  });

  test('a sealed record opens with the key and with nothing else', () async {
    final crypto = SyncCrypto(key, random: Random(2));
    final sealed = await crypto.seal((
      table: 'transactions',
      key: 't1',
      changedAt: 5,
      row: {'payee_display': 'Swiggy', 'amount_paise': 24000},
    ));
    expect(sealed.blob.contains('Swiggy'), isFalse);
    expect(sealed.id.contains('transactions'), isFalse);

    final opened = await crypto.open(sealed);
    expect(opened?.row?['payee_display'], 'Swiggy');

    final other = SyncCrypto(SyncKey.generate(Random(3)));
    expect(await other.open(sealed), isNull);
  });

  test('a record moved to another id or changed is refused', () async {
    final crypto = SyncCrypto(key, random: Random(4));
    final sealed = await crypto.seal((
      table: 'budgets',
      key: 'month',
      changedAt: 1,
      row: {'id': 'month', 'amount_paise': 100},
    ));
    final moved = (id: 'ff' * 32, changedAt: 1, blob: sealed.blob);
    expect(await crypto.open(moved), isNull);
    final flipped = sealed.blob.replaceRange(
      20,
      21,
      sealed.blob[20] == 'A' ? 'B' : 'A',
    );
    expect(
      await crypto.open((id: sealed.id, changedAt: 1, blob: flipped)),
      isNull,
    );
  });
}
