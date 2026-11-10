import 'dart:io';

import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:test/test.dart';

/// Contract (docs/DESIGN.md, "Type"): the app font is bundled with its
/// licence. A family name with no file behind it falls back to the
/// platform font silently, so check the wiring here.
void main() {
  test('the theme font family is declared in pubspec with a real file', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- family: $appFontFamily'));
    final asset = RegExp(r'- asset: (assets/fonts/\S+\.ttf)')
        .firstMatch(pubspec)
        ?.group(1);
    expect(asset, isNotNull, reason: 'no font asset declared');
    expect(File(asset!).existsSync(), isTrue, reason: '$asset is missing');
    expect(File('assets/fonts/AnekLatin-OFL.txt').existsSync(), isTrue);
  });

  test('no runtime font download', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, isNot(contains('google_fonts')));
  });
}
