import 'dart:async';

import 'package:expense_tracker/core/sync_timing.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/data/sync/sync_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runs sync in the background while it is on (Phase 9): when the app
/// opens or returns, shortly after a local change, and every
/// [syncInterval] while open. Never blocks the app. Wraps the app;
/// renders [child] unchanged.
class SyncHost extends ConsumerStatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  ConsumerState<SyncHost> createState() => _SyncHostState();
}

class _SyncHostState extends ConsumerState<SyncHost> {
  late final AppLifecycleListener _lifecycle;
  Timer? _soon;
  Timer? _every;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _syncNow);
    _every = Timer.periodic(syncInterval, (_) => _syncNow());
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncNow());
  }

  void _syncNow() {
    if (!mounted) return;
    unawaited(ref.read(syncControllerProvider.notifier).syncNow());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _soon?.cancel();
    _every?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingSyncProvider, (_, next) {
      if ((next.value ?? 0) == 0) return;
      // Waits for a burst of edits to settle, then sends them together.
      _soon?.cancel();
      _soon = Timer(syncDebounce, _syncNow);
    });
    return widget.child;
  }
}
