import 'dart:io';

import 'package:test/test.dart';

/// Contract (house rule 1): dependencies point down. `core/` and `data/`
/// never import a feature, the router or a widget; `core/` never imports
/// Flutter. An upward import is invisible at runtime, so grep it.
void main() {
  final importUri = RegExp(
    r'''^\s*import\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );

  List<String> offenders(String dir, bool Function(String uri) banned) {
    final found = <String>[];
    for (final file in Directory(dir).listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path.endsWith('.g.dart') || file.path.endsWith('.steps.dart')) {
        continue;
      }
      for (final m in importUri.allMatches(file.readAsStringSync())) {
        final uri = m.group(1)!;
        if (banned(uri)) found.add('${file.path}: $uri');
      }
    }
    return found;
  }

  bool upward(String uri) =>
      uri.startsWith('package:expense_tracker/features/') ||
      uri.startsWith('package:expense_tracker/routing/') ||
      uri.startsWith('package:expense_tracker/widgets/');

  test('core/ and data/ import no feature, router or widget code', () {
    final found = [
      ...offenders('lib/core', upward),
      ...offenders('lib/data', upward),
    ];
    expect(
      found,
      isEmpty,
      reason: 'Move the shared type down:\n${found.join('\n')}',
    );
  });

  test('a feature never imports another feature', () {
    final found = <String>[];
    final features = Directory('lib/features')
        .listSync()
        .whereType<Directory>()
        .map((d) => d.uri.pathSegments.where((p) => p.isNotEmpty).last);
    for (final feature in features) {
      found.addAll(
        offenders(
          'lib/features/$feature',
          (uri) =>
              uri.startsWith('package:expense_tracker/features/') &&
              !uri.startsWith('package:expense_tracker/features/$feature/'),
        ),
      );
    }
    expect(
      found,
      isEmpty,
      reason:
          'Share through core/, data/, services/ or widgets/, or '
          'navigate by route:\n${found.join('\n')}',
    );
  });

  test('core/ value types import no Flutter UI', () {
    final found = offenders(
      'lib/core',
      (uri) =>
          uri.startsWith('package:flutter/') ||
          uri.startsWith('package:expense_tracker/data/'),
    );
    expect(found, isEmpty, reason: found.join('\n'));
  });
}
