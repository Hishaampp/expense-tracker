import 'dart:io';

import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:test/test.dart';

/// Contract (docs/DESIGN.md, "Type"): the brand fonts are bundled with
/// their licences. A family name with no file behind it falls back to the
/// platform font silently, so check the wiring here.
void main() {
  test('both theme font families are declared with real files', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final family in [appFontFamily, displayFontFamily]) {
      expect(pubspec, contains('- family: $family'), reason: family);
    }
    final assets = RegExp(r'- asset: (assets/fonts/\S+\.ttf)')
        .allMatches(pubspec)
        .map((m) => m.group(1)!)
        .toList();
    expect(assets, isNotEmpty, reason: 'no font asset declared');
    for (final asset in assets) {
      expect(File(asset).existsSync(), isTrue, reason: '$asset is missing');
    }
    for (final licence in ['Manrope-OFL.txt', 'Fraunces-OFL.txt']) {
      expect(File('assets/fonts/$licence').existsSync(), isTrue);
    }
  });

  test('no runtime font download', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, isNot(contains('google_fonts')));
  });
}
