import 'dart:math' as math;

import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_motion.dart';
import 'package:flutter/material.dart';

// The Ample mark's geometry, from the brand kit (logos/ample-mark.svg): a
// 66-unit square from 17 to 83, centred on 50.
const double _origin = 17;
const double _extent = 66;
const double _centre = 50;
const double _ringRadius = 28;
const double _ringStroke = 10;
const double _barLeft = 73;
const double _barWidth = 10;
const double _barRadius = 5;
const double _honeyRadius = 19.5;
// The honey's surface when the bowl is full, and when it is empty.
const double _honeyFull = 40;
const double _honeyEmpty = _centre + _honeyRadius;
// A falling coin's radius, how high it starts, and how far the honey's
// surface rises and falls in its wave.
const double _coinRadius = 6.5;
const double _coinStart = -14;
const double _waveHeight = 1.4;
// Where in its fall a coin starts sinking into the honey.
const double _sinkFrom = 0.85;
// How many waves the living mark sways before it settles.
const int _waveCount = 2;

/// One coin on its way into the bowl: `progress` 0 above the mark, 1 at the
/// honey; `drift` moves it sideways in mark units.
typedef FallingCoin = ({double progress, double drift});

/// Paints the Ample mark with its bowl filled to [fill] (0 empty, 1 the
/// brand's level), the honey's surface swaying by [wave] (0–1, one
/// cycle), and [coins] falling into it.
class AmpleMarkPainter extends CustomPainter {
  /// Creates the painter.
  const new({
    required this.fill,
    required this.wave,
    required this.coins,
    required this.markColor,
    required this.honeyColor,
    required this.coinGlyphColor,
    required this.glyphStyle,
    this.waveStrength = 1,
  });

  /// How full the bowl is, 0–1.
  final double fill;

  /// Where the wave is in its cycle, 0–1.
  final double wave;

  /// Coins on their way in.
  final List<FallingCoin> coins;

  /// The "a".
  final Color markColor;

  /// The honey and the coins.
  final Color honeyColor;

  /// The ₹ on a coin.
  final Color coinGlyphColor;

  /// The ₹'s face and weight (sized here to the coin).
  final TextStyle glyphStyle;

  /// How strongly the honey sways, 0 (flat) to 1.
  final double waveStrength;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide / _extent;
    canvas
      ..save()
      ..scale(unit)
      ..translate(-_origin, -_origin);
    const centre = Offset(_centre, _centre);
    canvas
      ..drawCircle(
        centre,
        _ringRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _ringStroke
          ..color = markColor,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(_barLeft, _origin, _barWidth, _extent),
          const Radius.circular(_barRadius),
        ),
        Paint()..color = markColor,
      );
    _paintHoney(canvas);
    for (final coin in coins) {
      _paintCoin(canvas, coin);
    }
    canvas.restore();
  }

  double get _level =>
      _honeyEmpty - (_honeyEmpty - _honeyFull) * fill.clamp(0, 1);

  void _paintHoney(Canvas canvas) {
    if (fill <= 0) return;
    final level = _level;
    // The wave fades out as the bowl nears empty or full, so a full logo
    // rests on the brand's straight line.
    final settle = math.sin(math.pi * fill.clamp(0, 1));
    final height = _waveHeight * settle * waveStrength.clamp(0, 1);
    const left = _centre - _honeyRadius;
    const right = _centre + _honeyRadius;
    final surface = Path()..moveTo(left, level);
    const steps = 24;
    for (var i = 0; i <= steps; i++) {
      final x = left + (right - left) * i / steps;
      final y = level + height * math.sin(2 * math.pi * (wave + i / steps));
      surface.lineTo(x, y);
    }
    surface
      ..lineTo(right, _honeyEmpty)
      ..lineTo(left, _honeyEmpty)
      ..close();
    final bowl = Path()
      ..addOval(
        Rect.fromCircle(
          center: const Offset(_centre, _centre),
          radius: _honeyRadius,
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.intersect, bowl, surface),
      Paint()..color = honeyColor,
    );
  }

  void _paintCoin(Canvas canvas, FallingCoin coin) {
    final t = coin.progress.clamp(0.0, 1.0);
    if (t <= 0 || t >= 1) return;
    // Gravity: slow at the top, fast at the bottom; it sinks as it lands.
    final eased = t * t;
    final y = _coinStart + (_level - _coinStart) * eased;
    final x = _centre + coin.drift * (1 - eased);
    final shrink = t > _sinkFrom ? 1 - (t - _sinkFrom) / (1 - _sinkFrom) : 1.0;
    final radius = _coinRadius * shrink;
    if (radius <= 0) return;
    final at = Offset(x, y);
    canvas.drawCircle(at, radius, Paint()..color = honeyColor);
    final glyph = TextPainter(
      text: TextSpan(
        text: '₹',
        style: glyphStyle.copyWith(
          color: coinGlyphColor,
          fontSize: radius * 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    glyph.paint(canvas, at - Offset(glyph.width / 2, glyph.height / 2));
  }

  @override
  bool shouldRepaint(AmpleMarkPainter old) =>
      old.fill != fill ||
      old.wave != wave ||
      old.coins != coins ||
      old.markColor != markColor ||
      old.honeyColor != honeyColor ||
      old.coinGlyphColor != coinGlyphColor ||
      old.glyphStyle != glyphStyle ||
      old.waveStrength != waveStrength;
}

/// The Ample mark, alive: its honey sways for a couple of waves, then
/// settles flat (a bounded moment, never a loop). Decorative; still under
/// reduced motion. [markColor] defaults to the text colour.
class AmpleMark extends StatefulWidget {
  /// Creates the mark, [size] square, filled to [fill].
  const new({required this.size, this.fill = 1, this.markColor, super.key});

  /// Width and height.
  final double size;

  /// How full the bowl is, 0–1.
  final double fill;

  /// The "a"'s colour; the theme's text colour when null.
  final Color? markColor;

  @override
  State<AmpleMark> createState() => _AmpleMarkState();
}

class _AmpleMarkState extends State<AmpleMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(vsync: this);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Plays once per appearance; nothing under reduced motion.
    if (reducesMotion(context)) {
      _wave
        ..stop()
        ..value = 1;
    } else if (!_started) {
      _started = true;
      _wave.duration = AppMotion.of(context).honeyWave * _waveCount;
      _wave.forward();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _wave,
          builder: (context, _) => CustomPaint(
            size: Size.square(widget.size),
            painter: AmpleMarkPainter(
              fill: widget.fill,
              wave: (_wave.value * _waveCount) % 1,
              waveStrength: 1 - _wave.value,
              coins: const [],
              markColor: widget.markColor ?? colors.onSurface,
              honeyColor: colors.honey,
              coinGlyphColor: colors.onHoney,
              glyphStyle: Theme.of(context).textTheme.labelLarge!,
            ),
          ),
        ),
      ),
    );
  }
}

/// The living Ample mark, its honey pouring in to [fill] as it appears,
/// then swaying. For empty states and the welcome. Still, and already
/// full, under reduced motion.
class PouringAmpleMark extends StatelessWidget {
  /// Creates the mark, poured to [fill].
  const new({this.fill = 0.6, super.key});

  /// How full the bowl ends up, 0–1.
  final double fill;

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fill),
      duration: resolveMotion(context, motion.countUp),
      curve: motion.enter,
      builder: (context, poured, _) =>
          AmpleMark(size: AppMetrics.of(context).markSize, fill: poured),
    );
  }
}
