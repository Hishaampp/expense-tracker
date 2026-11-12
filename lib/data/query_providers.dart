import 'package:drift/drift.dart' show countAll;
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/appearance_mode.dart';
import 'package:expense_tracker/core/models/budget_plan.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/notice.dart';
import 'package:expense_tracker/core/models/payee_rule.dart';
import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/core/models/retention.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/month_period.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Every category, in picker order. Live: re-emits after each write.
final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

/// Every account. Live.
final accountsProvider = StreamProvider<List<Account>>(
  (ref) => ref.watch(accountRepositoryProvider).watchAll(),
);

/// The day of the month a budgeting month starts on. Live.
final monthStartDayProvider = StreamProvider<int>(
  (ref) => ref.watch(settingsRepositoryProvider).watchMonthStartDay(),
);

/// The appearance read before the first frame, so the app never flashes
/// the wrong theme. `bootstrap()` overrides it.
final initialAppearanceProvider = Provider<AppearanceMode>(
  (ref) => AppearanceMode.system,
);

/// Whether the first-launch welcome was done, read before the first
/// frame. `bootstrap()` overrides it; tests start past it.
final initialOnboardedProvider = Provider<bool>((ref) => true);

/// Whether the app lock was on, read before the first frame so the app
/// opens locked. `bootstrap()` overrides it.
final initialAppLockProvider = Provider<bool>((ref) => false);

/// Whether the app lock is on. Live.
final appLockProvider = StreamProvider<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).watchAppLock(),
);

/// How long original message text is kept. Live.
final retentionProvider = StreamProvider<RawTextRetention>(
  (ref) => ref.watch(settingsRepositoryProvider).watchRetention(),
);

/// Light, dark or follow the phone. Live.
final appearanceProvider = StreamProvider<AppearanceMode>(
  (ref) => ref.watch(settingsRepositoryProvider).watchAppearance(),
);

/// Transactions in one month, newest first. Live.
final StreamProviderFamily<List<MoneyTransaction>, MonthPeriod>
monthTransactionsProvider = StreamProvider.autoDispose
    .family<List<MoneyTransaction>, MonthPeriod>(
      (ref, period) =>
          ref.watch(transactionRepositoryProvider).watchInPeriod(period),
    );

/// When the first income was received, UTC milliseconds; null when none
/// is recorded (Phase 10). Live.
final firstIncomeAtProvider = StreamProvider<int?>(
  (ref) => ref.watch(transactionRepositoryProvider).watchFirstIncomeAt(),
);

/// Money in minus money spent over a UTC millisecond range (Phase 10).
/// Live.
final StreamProviderFamily<Money, ({int start, int end})> netBetweenProvider =
    StreamProvider.autoDispose.family<Money, ({int start, int end})>(
      (ref, range) => ref
          .watch(transactionRepositoryProvider)
          .watchNetBetween(range.start, range.end),
    );

/// How many payments wait in the review inbox. Live.
final reviewCountProvider = StreamProvider<int>(
  (ref) => ref
      .watch(autoCaptureRepositoryProvider)
      .watchNeedsReview()
      .map((list) => list.length),
);

/// When the iPhone Shortcuts setup was finished, or null. Live.
final iosShortcutSetupAtProvider = StreamProvider<DateTime?>(
  (ref) => ref.watch(settingsRepositoryProvider).watchIosShortcutSetupAt(),
);

/// When the newest Shortcuts capture arrived, or null. Live.
final lastShortcutCaptureAtProvider = StreamProvider<DateTime?>(
  (ref) => ref
      .watch(captureRepositoryProvider)
      .watchLastCaptureAt(CaptureSource.iosShortcut),
);

/// Every Room, active first. Live.
final roomsProvider = StreamProvider<List<Room>>(
  (ref) => ref.watch(roomRepositoryProvider).watchAll(),
);

/// Active Rooms only, newest first. Live.
final activeRoomsProvider = Provider<AsyncValue<List<Room>>>(
  (ref) => ref
      .watch(roomsProvider)
      .whenData(
        (rooms) => [
          for (final r in rooms)
            if (r.isActive) r,
        ],
      ),
);

/// Spending per Room in paise, by Room id. Live.
final roomSpentProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(roomRepositoryProvider).watchSpentByRoom(),
);

/// The budgets. Live.
final budgetPlanProvider = StreamProvider<BudgetPlan>(
  (ref) => ref.watch(budgetRepositoryProvider).watchPlan(),
);

/// Whether the weekly review notification is on. Live.
final weeklyReviewOnProvider = StreamProvider<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).watchWeeklyReview(),
);

/// The category to watch this week, or null. Live.
final watchedCategoryProvider = StreamProvider<String?>(
  (ref) => ref.watch(settingsRepositoryProvider).watchWatchedCategory(),
);

/// Transactions from the range's start (inclusive) to its end
/// (exclusive), both UTC epoch milliseconds, newest first. Live.
final StreamProviderFamily<List<MoneyTransaction>, ({int start, int end})>
rangeTransactionsProvider = StreamProvider.autoDispose
    .family<List<MoneyTransaction>, ({int start, int end})>(
      (ref, range) => ref
          .watch(transactionRepositoryProvider)
          .watchBetween(range.start, range.end),
    );

/// The notification inbox, newest first. Live.
final noticesProvider = StreamProvider<List<Notice>>(
  (ref) => ref.watch(noticeRepositoryProvider).watchAll(),
);

/// How many notices are unread. Live.
final unreadNoticesProvider = StreamProvider<int>(
  (ref) => ref.watch(noticeRepositoryProvider).watchUnreadCount(),
);

/// The merchant book: every payee seen, with its rule. Live.
final payeeBookProvider = StreamProvider<List<PayeeEntry>>(
  (ref) => ref.watch(payeeRepositoryProvider).watchBook(),
);

/// How many local changes wait to be synced. Live.
final pendingSyncProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final count = countAll();
  final query = db.selectOnly(db.syncOutbox)..addColumns([count]);
  return query.watchSingle().map((row) => row.read(count) ?? 0);
});
