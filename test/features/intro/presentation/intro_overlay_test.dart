import 'package:expense_tracker/core/app_lock.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/features/intro/presentation/intro_overlay.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/widgets/ample_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Pending extends IntroNotifier {
  @override
  bool build() => true;
}

class _Asking extends LockStatusNotifier {
  @override
  LockStatus build() => LockStatus.asking;
}

Future<void> _pump(
  WidgetTester tester, {
  bool reduceMotion = false,
  bool locked = false,
}) => tester.pumpWidget(
  ProviderScope(
    overrides: [
      introPendingProvider.overrideWith(_Pending.new),
      if (locked) lockStatusProvider.overrideWith(_Asking.new),
    ],
    child: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: const IntroOverlay(child: Text('the app')),
      ),
    ),
  ),
);

bool _showing(WidgetTester tester) => find
    .byWidgetPredicate((w) => w is CustomPaint && w.painter is AmpleMarkPainter)
    .evaluate()
    .isNotEmpty;

double _nameOpacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find
          .ancestor(of: find.text('Ample'), matching: find.byType(Opacity))
          .first,
    )
    .opacity;

void main() {
  testWidgets('the intro plays, says the name, then shows the app', (
    tester,
  ) async {
    await _pump(tester);
    expect(_showing(tester), isTrue);
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('Ample'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(_showing(tester), isFalse);
    expect(find.text('the app'), findsOneWidget);
  });

  testWidgets('a tap skips it', (tester) async {
    await _pump(tester);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tapAt(const Offset(200, 300));
    await tester.pump();
    expect(_showing(tester), isFalse);
  });

  testWidgets('under reduced motion it never plays', (tester) async {
    await _pump(tester, reduceMotion: true);
    await tester.pump();
    expect(_showing(tester), isFalse);
  });

  testWidgets('with Face ID asked, it waits, then plays once unlocked', (
    tester,
  ) async {
    await _pump(tester, locked: true);
    await tester.pump(const Duration(seconds: 3));
    // Still waiting on the still logo: the name has not risen in.
    expect(_showing(tester), isTrue);
    expect(_nameOpacity(tester), 0);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(IntroOverlay)),
    );
    container.read(lockStatusProvider.notifier).status = LockStatus.open;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
    expect(_nameOpacity(tester), greaterThan(0.9));
    await tester.pumpAndSettle();
    expect(_showing(tester), isFalse);
  });

  testWidgets('if unlocking fails it steps aside for the lock screen', (
    tester,
  ) async {
    await _pump(tester, locked: true);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(IntroOverlay)),
    );
    container.read(lockStatusProvider.notifier).status = LockStatus.locked;
    await tester.pump();
    await tester.pump();
    expect(_showing(tester), isFalse);
  });
}
