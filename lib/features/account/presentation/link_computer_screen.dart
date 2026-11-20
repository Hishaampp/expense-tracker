import 'dart:async';

import 'package:expense_tracker/data/sync/computer_link.dart';
import 'package:expense_tracker/data/sync/sync_controller.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Link a computer (Ample for the web): scans the website's QR, asks the
/// owner to confirm, then hands over the sync key sealed for that browser
/// tab only. The camera only reads codes; no picture is kept.
class LinkComputerScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<LinkComputerScreen> createState() => _LinkComputerState();
}

class _LinkComputerState extends ConsumerState<LinkComputerScreen> {
  final MobileScannerController _camera = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _busy = false;
  bool _notAmple = false;

  @override
  void dispose() {
    unawaited(_camera.dispose());
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_busy) return;
    for (final code in capture.barcodes) {
      final text = code.rawValue;
      if (text == null) continue;
      final link = ComputerLink.tryParse(text);
      if (link == null) {
        if (!_notAmple) setState(() => _notAmple = true);
        continue;
      }
      _busy = true;
      ref.read(hapticsProvider).select();
      unawaited(_link(link));
      return;
    }
  }

  Future<void> _link(ComputerLink link) async {
    await _camera.stop();
    if (!mounted) return;
    final outcome = await confirmAndLink(context, ref, link);
    if (!mounted) return;
    if (outcome == LinkOutcome.linked) {
      context.pop();
      return;
    }
    _busy = false;
    await _camera.start();
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
                      color: colors.honey,
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
                  Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.close_rounded,
                        tooltip: l10n.close,
                        color: colors.onSurface,
                        onPressed: () => context.pop(),
                      ),
                      SizedBox(width: metrics.spaceMd),
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            l10n.linkTitle,
                            style: textTheme.titleLarge?.copyWith(
                              color: colors.onHero,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _notAmple ? l10n.linkNotAmple : l10n.linkHint,
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

/// Asks the owner to confirm, checks it's them (Face ID, fingerprint or
/// passcode), then links [link]'s computer and says how it went.
Future<LinkOutcome?> confirmAndLink(
  BuildContext context,
  WidgetRef ref,
  ComputerLink link,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final sure = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.linkConfirmTitle),
      content: Text(l10n.linkConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.linkConfirm),
        ),
      ],
    ),
  );
  // Null means dismissed: link nothing.
  if (sure != true) return null;
  final itsYou = await ref.read(deviceAuthProvider).unlock(l10n.linkReason);
  if (!itsYou) return null;
  final outcome = await ref
      .read(syncControllerProvider.notifier)
      .linkComputer(link);
  if (outcome == LinkOutcome.linked) ref.read(hapticsProvider).commit();
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(switch (outcome) {
          LinkOutcome.linked => l10n.linkDone,
          LinkOutcome.notSyncing => l10n.linkNotSyncing,
          LinkOutcome.failed => l10n.linkFailed,
        }),
      ),
    );
  return outcome;
}
