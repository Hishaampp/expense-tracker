import 'package:expense_tracker/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root: binds Flutter, installs infrastructure, and runs the app.
///
/// Later phases construct the database, capture channel and clock here and
/// inject them through [ProviderScope] overrides.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: App()));
}
