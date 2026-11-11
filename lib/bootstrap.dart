import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/core/cloud_config.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/data/repositories/settings_repository.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:expense_tracker/services/cloud/secure_session_storage.dart';
import 'package:expense_tracker/services/database_key.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Composition root: the only place live infrastructure is constructed.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(_fontLicenses);
  final path = p.join(
    (await getApplicationDocumentsDirectory()).path,
    'expenses.sqlite',
  );
  final database = AppDatabase.open(
    path: path,
    hexKey: await const DatabaseKeyStore().readOrCreate(),
    wasPlain: await AppDatabase.isPlain(path),
  );
  // Read before the first frame so the app never flashes the wrong theme.
  // Only reached when the user signs in (Phase 9); no request is made
  // before that.
  await Supabase.initialize(
    url: CloudConfig.url,
    publishableKey: CloudConfig.publishableKey,
    authOptions: const FlutterAuthClientOptions(
      localStorage: SecureSessionStorage(),
    ),
  );
  final settings = SettingsRepository(database, const DeveloperLogger());
  final appearance = await settings.watchAppearance().first;
  final onboarded = await settings.isOnboarded();
  final locked = await settings.appLockOn();
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        initialAppearanceProvider.overrideWithValue(appearance),
        initialOnboardedProvider.overrideWithValue(onboarded),
        initialAppLockProvider.overrideWithValue(locked),
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
