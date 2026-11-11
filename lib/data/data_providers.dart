import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/repositories/account_repository.dart';
import 'package:expense_tracker/data/repositories/auto_capture_repository.dart';
import 'package:expense_tracker/data/repositories/budget_repository.dart';
import 'package:expense_tracker/data/repositories/capture_repository.dart';
import 'package:expense_tracker/data/repositories/category_repository.dart';
import 'package:expense_tracker/data/repositories/notice_repository.dart';
import 'package:expense_tracker/data/repositories/room_repository.dart';
import 'package:expense_tracker/data/repositories/settings_repository.dart';
import 'package:expense_tracker/data/repositories/transaction_repository.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The open database. Throws until `bootstrap()` (or a test) overrides it.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('override appDatabaseProvider'),
);

/// The single write path for transactions.
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(appLoggerProvider),
  ),
);

/// Reads categories.
final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(appDatabaseProvider)),
);

/// Reads accounts.
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(appDatabaseProvider)),
);

/// Reads and writes settings.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(appLoggerProvider),
  ),
);

/// Records captures that are not transactions; serves the Unparsed list.
final captureRepositoryProvider = Provider<CaptureRepository>(
  (ref) => CaptureRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(appLoggerProvider),
  ),
);

/// Duplicate checks, merging and the review inbox.
final autoCaptureRepositoryProvider = Provider<AutoCaptureRepository>(
  (ref) => AutoCaptureRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(transactionRepositoryProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(appLoggerProvider),
  ),
);

/// The Room repository.
final roomRepositoryProvider = Provider<RoomRepository>(
  (ref) => RoomRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(appLoggerProvider),
  ),
);

/// Budgets and fired alerts.
final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(appLoggerProvider),
  ),
);

/// The in-app notification inbox.
final noticeRepositoryProvider = Provider<NoticeRepository>(
  (ref) => NoticeRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(appLoggerProvider),
  ),
);
