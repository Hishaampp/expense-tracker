import 'dart:io';

import 'package:test/test.dart';

/// Contract (spec §11.1 A, Phase 1 acceptance): no raw colour, size, radius
/// or duration outside lib/theme/. A stray literal is invisible to every
/// other test and one line to add, so grep it. The fix for a hit is a theme
/// slot (or a new one), never an ignore.
void main() {
  test('lib/ outside lib/theme/ holds no raw design values', () {
    final banned = <String, RegExp>{
      'raw colour': RegExp(r'\bColor(\.fromARGB|\.fromRGBO)?\(\s*(0x|\d)'),
      'Material colour': RegExp(r'\bColors\.(?!transparent\b)\w+'),
      'raw curve': RegExp(r'\bCurves\.\w+'),
      'raw duration': RegExp(
        r'\bDuration\(\s*(milliseconds|seconds|microseconds|minutes)\s*:',
      ),
      'raw radius': RegExp(r'\b(BorderRadius|Radius)\.circular\(\s*\d'),
      'raw font size': RegExp(r'\bfontSize\s*:\s*\d'),
      'raw font weight': RegExp(r'\bFontWeight\.w\d'),
      'raw inset': RegExp(
        r'\bEdgeInsets(Directional)?\.\w+\([^)]*\b\d+(\.\d+)?\s*[,)]',
      ),
      'raw box size': RegExp(r'\b(width|height|size)\s*:\s*\d+(\.\d+)?\s*[,)]'),
    };
    final lineComment = RegExp(r'//[^\n]*');

    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.startsWith('lib/theme/'))
        .where((f) => !f.path.startsWith('lib/l10n/'))
        .where((f) => !f.path.endsWith('.g.dart'));
    for (final file in files) {
      final lines = file.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        final code = lines[i].replaceAll(lineComment, '');
        for (final entry in banned.entries) {
          if (entry.value.hasMatch(code)) {
            offenders.add('${file.path}:${i + 1}: ${entry.key}');
          }
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Design values live only in lib/theme/ so the look can change in '
          'one place. Read a slot from AppColors, AppMetrics, AppMotion or '
          'AppTextStyles instead:\n${offenders.join('\n')}',
    );
  });
}
