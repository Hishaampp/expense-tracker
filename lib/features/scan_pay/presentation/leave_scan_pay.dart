import 'package:expense_tracker/routing/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Leaves Scan & Pay: back where it was opened from, or Home when it was
/// opened on its own (a Lock Screen widget link).
void leaveScanPay(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(Routes.home);
