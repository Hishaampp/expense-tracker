import 'dart:async';

import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/capture/capture_providers.dart';
import 'package:expense_tracker/routing/app_router.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drains the native capture queue when the app starts, when it returns to
/// the foreground, and when the queue says something arrived. Each shared
/// message opens Quick Add, filled in; the text waits in memory, never in a
/// route. Wraps the app; renders [child] unchanged.
class CaptureInbox extends ConsumerStatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  ConsumerState<CaptureInbox> createState() => _CaptureInboxState();
}

class _CaptureInboxState extends ConsumerState<CaptureInbox> {
  StreamSubscription<void>? _changes;
  late final AppLifecycleListener _lifecycle;
  bool _draining = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _drainSoon);
    _changes = ref
        .read(captureQueueProvider)
        .changes
        .listen((_) => _drainSoon(), onError: _logStreamError);
    WidgetsBinding.instance.addPostFrameCallback((_) => _drainSoon());
  }

  void _drainSoon() => unawaited(_drain());

  void _logStreamError(Object error, StackTrace stack) {
    ref
        .read(appLoggerProvider)
        .error('capture.events', error.runtimeType, stack);
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    final queue = ref.read(captureQueueProvider);
    final pending = ref.read(pendingCapturesProvider.notifier);
    final router = ref.read(routerProvider);
    try {
      final captures = await queue.drain();
      final auto = ref.read(autoIngestionProvider);
      final handled = <String>[];
      for (final capture in captures) {
        if (capture.source == CaptureSource.share) {
          // The user shared it: let them finish it in Quick Add.
          pending.put(capture);
          unawaited(router.push(Routes.shared(capture.id)));
          handled.add(capture.id);
          continue;
        }
        // Notifications and SMS are saved without the user (spec §5.7).
        // Only acked once recorded, so a failure is retried next time.
        switch (await auto.ingest(capture)) {
          case Ok():
            handled.add(capture.id);
          case Err():
            break;
        }
      }
      await queue.ack(handled);
    } on PlatformException catch (e, st) {
      ref.read(appLoggerProvider).error('capture.drain', e.runtimeType, st);
    } on MissingPluginException catch (e, st) {
      ref.read(appLoggerProvider).error('capture.drain', e.runtimeType, st);
    } finally {
      _draining = false;
    }
  }

  @override
  void dispose() {
    unawaited(_changes?.cancel());
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
