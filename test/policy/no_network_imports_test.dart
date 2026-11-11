import 'dart:io';

import 'package:test/test.dart';

/// Contract (spec §13, Phase 9): the only code that may reach the network
/// is the optional account's sync with the project's own Supabase server,
/// and it only ever sends sealed records. Everything else stays offline. A
/// banned import that is never reached at runtime is invisible to every
/// other test, so grep it.
void main() {
  // The only files allowed to talk to the server.
  const cloudFiles = {
    'lib/services/cloud/cloud_auth.dart',
    'lib/services/cloud/secure_session_storage.dart',
    'lib/data/sync/supabase_sync_server.dart',
    'lib/data/sync/sync_controller.dart',
    'lib/bootstrap.dart',
  };

  test('lib/ reaches the network only through the sync files', () {
    const banned = <String>[
      'package:supabase',
      'package:gotrue',
      'package:postgrest',
      'package:realtime_client',
      'package:storage_client',
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
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !cloudFiles.contains(f.path));
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
          'Only the sync files may reach the network, and only with '
          'sealed records (Phase 9). Move this into them or remove '
          'it:\n${offenders.join('\n')}',
    );
  });

  test('the app talks to no server but its own Supabase project', () {
    final urls = RegExp(r'''https?://[^'"\s)]+''');
    final found = <String>{};
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path.endsWith('.g.dart')) continue;
      for (final m in urls.allMatches(file.readAsStringSync())) {
        found.add(m.group(0)!);
      }
    }
    expect(
      found.where((u) => !u.startsWith('https://rsfiiiyhajwgfnkxuwtr.')),
      isEmpty,
      reason: 'A new server must be agreed first (Phase 9 plan).',
    );
  });
}
