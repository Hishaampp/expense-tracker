import 'dart:async';

import 'package:expense_tracker/core/app_identity.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:expense_tracker/widgets/ample_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the intro still has to play: true at a cold start (bootstrap),
/// false once it has, and in tests.
class IntroNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// The intro has finished or was skipped.
  void done() => state = false;
}

/// Provides [IntroNotifier]. Bootstrap overrides it to start true.
final NotifierProvider<IntroNotifier, bool> introPendingProvider =
    NotifierProvider<IntroNotifier, bool>(IntroNotifier.new);

// The intro's script, as shares of its length: three coins fall in turn,
// the honey rises as each lands, the name rises in, then all of it fades.
const List<(double, double)> _coins = [(0, 0.26), (0.16, 0.42), (0.32, 0.58)];
const List<double> _drift = [-6, 5, -2];
const double _riseLength = 0.12;
const double _nameStart = 0.6;
const double _nameEnd = 0.8;
const double _fadeStart = 0.84;
const double _waveCycles = 1.6;

/// The Ample intro (brand kit): over the launch screen's still mark, coins
/// fall into the bowl and the honey rises, "Ample" appears, then it fades
/// into the app. A tap skips it; under reduced motion it never plays.
/// Wraps the app; renders [child] beneath.
class IntroOverlay extends ConsumerStatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  ConsumerState<IntroOverlay> createState() => _IntroOverlayState();
}

class _IntroOverlayState extends ConsumerState<IntroOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || !ref.read(introPendingProvider)) return;
    _started = true;
    if (reducesMotion(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
      return;
    }
    _clock.duration = AppMotion.of(context).intro;
    unawaited(_clock.forward().whenComplete(_finish));
  }

  void _finish() {
    if (mounted) ref.read(introPendingProvider.notifier).done();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  static double _span(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(introPendingProvider);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final motion = AppMotion.of(context);
    final textTheme = Theme.of(context).textTheme;
    // The same Stack before and after, so the app beneath keeps its state
    // when the intro ends; only the top layer goes. Hidden from screen
    // readers: it is decoration and ends by itself.
    return Stack(
      children: [
        widget.child,
        if (pending)
          Positioned.fill(
            child: ExcludeSemantics(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _finish,
                child: AnimatedBuilder(
                  animation: _clock,
                  builder: (context, _) {
                    final t = _clock.value;
                    var fill = 0.0;
                    final coins = <FallingCoin>[];
                    for (final (i, (from, to)) in _coins.indexed) {
                      coins.add((
                        progress: _span(t, from, to),
                        drift: _drift[i],
                      ));
                      fill +=
                          motion.move.transform(
                            _span(t, to - 0.02, to + _riseLength),
                          ) /
                          _coins.length;
                    }
                    final name = motion.enter.transform(
                      _span(t, _nameStart, _nameEnd),
                    );
                    final fade =
                        1 - motion.exit.transform(_span(t, _fadeStart, 1));
                    return Opacity(
                      opacity: fade,
                      child: ColoredBox(
                        color: colors.splash,
                        // The mark stays exactly where the launch screen drew
                        // it; the name rises in just below.
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: Size.square(metrics.introMarkSize),
                              painter: AmpleMarkPainter(
                                fill: fill,
                                wave: t * _waveCycles,
                                coins: coins,
                                markColor: colors.onSplash,
                                honeyColor: colors.honey,
                                coinGlyphColor: colors.onHoney,
                                glyphStyle: textTheme.labelLarge!,
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(
                                0,
                                metrics.introMarkSize / 2 +
                                    metrics.spaceXxl +
                                    metrics.entranceOffset * (1 - name),
                              ),
                              child: Opacity(
                                opacity: name,
                                child: Text(
                                  appDisplayName,
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: colors.onSplash,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
