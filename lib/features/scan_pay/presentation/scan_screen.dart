import 'dart:async';

import 'package:expense_tracker/core/upi_qr.dart';
import 'package:expense_tracker/features/scan_pay/presentation/leave_scan_pay.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scan & Pay's camera (Phase 11): reads a UPI QR code and opens the
/// payment screen for it. The camera only reads codes; no picture is kept.
class ScanScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final MobileScannerController _camera = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _done = false;
  bool _notUpi = false;

  @override
  void dispose() {
    unawaited(_camera.dispose());
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final code in capture.barcodes) {
      final text = code.rawValue;
      if (text == null) continue;
      if (UpiRequest.tryParse(text) == null) {
        if (!_notUpi) setState(() => _notUpi = true);
        continue;
      }
      _done = true;
      ref.read(hapticsProvider).select();
      context.pushReplacement(Routes.scanPay(text));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colors.hero,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _camera,
            onDetect: _onDetect,
            errorBuilder: (context, _) => Center(
              child: Padding(
                padding: EdgeInsetsDirectional.all(metrics.spaceXl),
                child: Text(
                  l10n.scanCameraOff,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: colors.onHero),
                ),
              ),
            ),
          ),
          // The frame to aim at. Decorative.
          ExcludeSemantics(
            child: Center(
              child: SizedBox.square(
                dimension: metrics.scanFrameSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colors.onHero,
                      width: metrics.scanFrameStroke,
                    ),
                    borderRadius: BorderRadius.circular(
                      metrics.radiusTileLarge,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsetsDirectional.all(metrics.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: RoundIconButton(
                      icon: Icons.close_rounded,
                      tooltip: l10n.close,
                      color: colors.onSurface,
                      onPressed: () => leaveScanPay(context),
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _notUpi ? l10n.scanNotUpi : l10n.scanHint,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.onHero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
