import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    test('${brightness.name} theme carries every extension', () {
      final theme = buildAppTheme(brightness);
      expect(theme.extension<AppColors>(), isNotNull);
      expect(theme.extension<AppMetrics>(), isNotNull);
      expect(theme.extension<AppMotion>(), isNotNull);
      expect(theme.extension<AppTextStyles>(), isNotNull);
      expect(theme.colorScheme.brightness, brightness);
    });
  }

  test('tap targets meet the 44px accessibility floor', () {
    expect(AppMetrics.standard.minTapTarget, greaterThanOrEqualTo(44));
  });

  testWidgets('resolveMotion is zero when the OS reduces motion', (
    tester,
  ) async {
    late Duration resolved;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            resolved = resolveMotion(context, AppMotion.standard.medium);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(resolved, Duration.zero);
  });
}
