import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/data/repositories/settings_repository.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root: the only place live infrastructure is constructed.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(_fontLicenses);
  final database = AppDatabase.open();
  // Read before the first frame so the app never flashes the wrong theme.
  final appearance = await SettingsRepository(
    database,
    const DeveloperLogger(),
  ).watchAppearance().first;
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        initialAppearanceProvider.overrideWithValue(appearance),
      ],
      child: const App(),
    ),
  );
}

/// The bundled font's licence, shown on the platform licences page.
Stream<LicenseEntry> _fontLicenses() async* {
  final text = await rootBundle.loadString('assets/fonts/AnekLatin-OFL.txt');
  yield LicenseEntryWithLineBreaks(const ['Anek Latin'], text);
}
