import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/appearance_mode.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
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
