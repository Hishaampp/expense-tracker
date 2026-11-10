import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:txn_parser/txn_parser.dart';

/// Golden tests: every fixture's expected fields must match exactly.
/// Fixtures marked `"synthetic": true` were written by hand to scaffold the
/// parser; they are not evidence that any bank's real format is supported
/// (spec §7.5). Real anonymised samples go in a separate file.
void main() {
  const parser = TxnParser();
  final files = Directory('test/fixtures')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'));

  for (final file in files) {
    final fixtures = (jsonDecode(file.readAsStringSync()) as List<Object?>)
        .cast<Map<String, Object?>>();
    group(file.uri.pathSegments.last, () {
      for (final fixture in fixtures) {
        test(fixture['name']! as String, () {
          expect(
            fixture.containsKey('synthetic'),
            isTrue,
            reason: 'every fixture says whether it is synthetic',
          );
          final result = parser.parse(
            fixture['text']! as String,
            origin: fixture['origin'] as String?,
          );
          _check(result, fixture['expected']! as Map<String, Object?>);
        });
      }
    });
  }
}

void _check(ParseResult result, Map<String, Object?> expected) {
  expect(result.messageClass.name, expected['class']);
  final kind = expected['result'];
  switch (result) {
    case ParsedTransaction(:final fields):
      expect(kind, anyOf(isNull, 'parsed'));
      _checkFields(fields, expected);
    case DroppedMessage():
      expect(kind, 'dropped');
    case UnparsedMessage(:final amountPaise):
      expect(kind, 'unparsed');
      if (expected.containsKey('amountPaise')) {
        expect(amountPaise, expected['amountPaise']);
      }
    case NoAmount():
      expect(kind, 'noAmount');
  }
}

void _checkFields(ParsedFields f, Map<String, Object?> e) {
  final actual = <String, Object?>{
    'amountPaise': f.amountPaise,
    'direction': f.direction.name,
    'instrument': f.instrument.name,
    'bankHint': f.bankHint,
    'accountHint': f.accountHint,
    'isCreditCard': f.isCreditCard,
    'payeeVpa': f.payeeVpa,
    'payeeName': f.payeeName,
    'refNo': f.refNo,
    'availableBalancePaise': f.availableBalancePaise,
    'date': f.occurredAt == null
        ? null
        : '${f.occurredAt!.year}-'
              '${f.occurredAt!.month.toString().padLeft(2, '0')}-'
              '${f.occurredAt!.day.toString().padLeft(2, '0')}',
    'time': f.occurredAt?.hasTime ?? false
        ? '${f.occurredAt!.hour.toString().padLeft(2, '0')}:'
              '${f.occurredAt!.minute.toString().padLeft(2, '0')}:'
              '${f.occurredAt!.second.toString().padLeft(2, '0')}'
        : null,
  };
  for (final key in e.keys) {
    if (const {'class', 'result', 'note'}.contains(key)) continue;
    expect(actual[key], e[key], reason: key);
  }
}
