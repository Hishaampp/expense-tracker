import 'dart:async';

import 'package:clock/clock.dart';
import 'package:expense_tracker/core/app_identity.dart';
import 'package:expense_tracker/core/app_lock.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Covers the app until the user unlocks with Face ID, fingerprint or the
/// phone passcode (spec §13): on open, and after [appLockGrace] in the
/// background. While locked, nothing of the app is visible, readable by a
/// screen reader, or tappable. Wraps the app; renders [child] when open.
class AppLockGate extends ConsumerStatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  late bool _locked = ref.read(initialAppLockProvider);
  late final AppLifecycleListener _lifecycle;
  DateTime? _hiddenAt;
  bool _asking = false;

  Clock get _clock => ref.read(clockProvider);

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => _hiddenAt ??= _clock.now(),
      onShow: _maybeLock,
    );
    if (_locked) _askSoon();
  }

  void _maybeLock() {
    final since = _hiddenAt;
    _hiddenAt = null;
    final on = switch (ref.read(appLockProvider).value) {
      final bool value => value,
      null => ref.read(initialAppLockProvider),
    };
    if (!on || since == null) return;
    if (_clock.now().difference(since) >= appLockGrace) {
      setState(() => _locked = true);
      _askSoon();
    }
  }

  void _askSoon() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_unlock()));

  Future<void> _unlock() async {
    if (_asking || !mounted) return;
    _asking = true;
    final reason = AppLocalizations.of(context).lockReason;
    final ok = await ref.read(deviceAuthProvider).unlock(reason);
    _asking = false;
    if (ok && mounted) setState(() => _locked = false);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Turning the lock off in Settings opens the app at once.
    ref.listen(appLockProvider, (previous, next) {
      final turnedOff = previous?.value == true && next.value == false;
      if (turnedOff && _locked) setState(() => _locked = false);
    });
    if (!_locked) return widget.child;
    return Stack(
      // Fills the window: the hidden app below has no size of its own.
      fit: StackFit.expand,
      children: [
        // Built, so state survives; never shown, read or tapped.
        Offstage(
          child: ExcludeSemantics(child: IgnorePointer(child: widget.child)),
        ),
        Positioned.fill(
          child: _LockScreen(onUnlock: () => unawaited(_unlock())),
        ),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const new({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: colors.background,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: metrics.readableWidth),
            child: Padding(
              padding: EdgeInsetsDirectional.all(metrics.spaceXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTile(
                    icon: Icons.lock_rounded,
                    color: CategoryColors.of(context).violet,
                    large: true,
                  ),
                  SizedBox(height: metrics.spaceLg),
                  Semantics(
                    header: true,
                    child: Text(
                      appDisplayName,
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: metrics.spaceSm),
                  Text(
                    l10n.lockBody,
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: metrics.spaceXl),
                  FilledButton.icon(
                    onPressed: onUnlock,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: Text(l10n.lockUnlock),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
