import 'dart:async';

import 'package:expense_tracker/routing/app_router.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens Add for an expensetracker://add link and Scan & Pay for an
/// expensetracker://scan link: the iPhone Lock Screen widgets' taps.
/// Before onboarding is finished the links are ignored. Wraps the app;
/// renders [child] unchanged.
class QuickAddLinkHost extends ConsumerStatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  ConsumerState<QuickAddLinkHost> createState() => _QuickAddLinkHostState();
}

class _QuickAddLinkHostState extends ConsumerState<QuickAddLinkHost> {
  StreamSubscription<Uri>? _links;

  @override
  void initState() {
    super.initState();
    final source = ref.read(appLinkSourceProvider);
    _links = source.links.listen(_open);
    unawaited(source.initial().then((uri) => uri == null ? null : _open(uri)));
  }

  void _open(Uri uri) {
    if (!mounted) return;
    final target = switch (uri.host) {
      Routes.addLinkHost => Routes.addExpense,
      Routes.scanLinkHost => Routes.scan,
      _ => null,
    };
    if (target == null) return;
    final router = ref.read(routerProvider);
    final at = router.routerDelegate.currentConfiguration.uri.path;
    if (at == Routes.welcome || at == target) return;
    unawaited(router.push(target));
  }

  @override
  void dispose() {
    unawaited(_links?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
