// Shared test cases for Ample for the web (docs/WEB_DASHBOARD_PLAN.md):
// records sealed by the app's own SyncCrypto, which the website's tests
// must open to the same content. Regenerate after a deliberate change with
//   UPDATE_WEB_VECTORS=1 flutter test test/data/sync/web_vectors_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:expense_tracker/data/sync/sync_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

const _path = 'web/src/lib/crypto/fixtures/sync-vectors.json';

Future<String> _vectors() async {
  // Bytes 0..31, so both sides can rebuild it; read back from its code.
  final key = SyncKey.fromRecoveryCode(
    SyncKey.fromBytes(List.generate(32, (i) => i))!.recoveryCode,
  )!;
  final crypto = SyncCrypto(key, random: Random(7));
  final payloads = <RecordPayload>[
    (
      table: 'transactions',
      key: 't-1',
      changedAt: 1763365200000,
      row: {
        'id': 't-1',
        'kind': 'expense',
        'amount_paise': 6000,
        'currency': 'INR',
        'occurred_at': 1763364000000,
        'account_id': 'a-1',
        'to_account_id': null,
        'category_id': 'food',
        'room_id': null,
        'payee_key': 'upi:greenandprotein@okaxis',
        'payee_display': 'Green And Protein ₹ café',
        'instrument': 'upi',
        'ref_no': '531122334455',
        'note': null,
        'review_status': 'confirmed',
        'is_hidden': 0,
        'linked_transaction_id': null,
        'origin': 'notification',
        'created_at': 1763364000000,
        'updated_at': 1763365200000,
      },
    ),
    (table: 'transactions', key: 't-2', changedAt: 1763365300000, row: null),
    (
      table: 'settings',
      key: 'month_start_day',
      changedAt: 1763365400000,
      row: {'key': 'month_start_day', 'value': '5'},
    ),
  ];
  final records = <Map<String, Object?>>[];
  for (final p in payloads) {
    final sealed = await crypto.seal(p);
    records.add({
      'id': sealed.id,
      'changed_at': sealed.changedAt,
      'blob': sealed.blob,
      'opened': {'t': p.table, 'k': p.key, 'at': p.changedAt, 'row': p.row},
    });
  }
  final other = SyncCrypto(SyncKey.generate(Random(11)), random: Random(9));
  final foreign = await other.seal(payloads.first);
  // Sealed with another key under this key's id: must not open.
  final foreignRecord = {
    'id': await crypto.recordId('transactions', 't-1'),
    'changed_at': foreign.changedAt,
    'blob': foreign.blob,
  };
  final json = const JsonEncoder.withIndent('  ').convert({
    'recoveryCode': key.recoveryCode,
    'keyBytes': key.bytes,
    'records': records,
    'foreignRecord': foreignRecord,
  });
  return '$json\n';
}

void main() {
  test('the website test cases are current', () async {
    final fresh = await _vectors();
    final file = File(_path);
    if (Platform.environment['UPDATE_WEB_VECTORS'] == '1') {
      file.writeAsStringSync(fresh);
    }
    final committed = file.readAsStringSync();
    // The foreign record uses a random key, so compare without it.
    Map<String, Object?> stable(String s) =>
        (jsonDecode(s) as Map<String, Object?>)..remove('foreignRecord');
    expect(stable(committed), stable(fresh));
  });
}
