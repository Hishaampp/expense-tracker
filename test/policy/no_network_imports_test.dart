import 'dart:io';

import 'package:test/test.dart';

/// Contract (spec §13): no networking code ships. A banned import that is
/// never reached at runtime is invisible to every other test, so grep it.
void main() {
  test('lib/ imports nothing that can reach the network', () {
    const banned = <String>[
      'package:http/',
      'package:dio/',
      'package:web_socket_channel/',
      'package:firebase_',
      'package:sentry',
      'package:grpc/',
    ];
    final importUri = RegExp(
      r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
      multiLine: true,
    );
    final lineComment = RegExp(r'//[^\n]*');
    final httpClientUse = RegExp(r'\b(HttpClient|Socket|RawSocket)\s*[.(]');

    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final code = file.readAsStringSync().replaceAll(lineComment, '');
      for (final match in importUri.allMatches(code)) {
        final uri = match.group(1)!;
        if (banned.any(uri.startsWith)) offenders.add('${file.path}: $uri');
      }
      if (httpClientUse.hasMatch(code)) {
        offenders.add('${file.path}: uses dart:io socket/HTTP API');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'The app promises that no data leaves the phone (spec §13). '
          'Remove these:\n${offenders.join('\n')}',
    );
  });
}
