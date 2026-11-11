import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/appearance_mode.dart';
import 'package:expense_tracker/core/models/retention.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/capture/capture_providers.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/data/sync/sync_controller.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// What the Settings screen shows.
@immutable
final class SettingsState {
  /// Creates the state.
  const new({
    required this.monthStartDay,
    required this.appearance,
    required this.unparsedCount,
    required this.autoCaptureOn,
    this.monthlyBudget,
    this.appLock = false,
    this.retention = RawTextRetention.days30,
    this.syncEmail,
  });

  /// The day of the month a budgeting month starts on.
  final int monthStartDay;

  /// Light, dark or follow the phone.
  final AppearanceMode appearance;

  /// How many messages wait on the Unparsed list; null until known.
  final int? unparsedCount;

  /// Whether auto-capture is on; null where it does not apply (iPhone) or
  /// is not known yet.
  final bool? autoCaptureOn;

  /// The monthly budget, or null when none is set.
  final Money? monthlyBudget;

  /// Whether the app lock is on.
  final bool appLock;

  /// How long original message text is kept.
  final RawTextRetention retention;

  /// The account syncing this phone, or null when sync is off.
  final String? syncEmail;
}

/// The Settings view model over the live settings.
class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    return SettingsState(
      monthStartDay: await ref.watch(monthStartDayProvider.future),
      appearance: await ref.watch(appearanceProvider.future),
      // Not awaited: if the list cannot load, Settings still shows.
      unparsedCount: ref.watch(unparsedMessagesProvider).value?.length,
      autoCaptureOn: ref.watch(autoCaptureOnProvider).value,
      monthlyBudget: ref.watch(budgetPlanProvider).value?.monthly,
      appLock: ref.watch(appLockProvider).value ?? false,
      retention: ref.watch(retentionProvider).value ?? RawTextRetention.days30,
      syncEmail: switch (ref.watch(syncControllerProvider).value) {
        SyncOn(:final email) ||
        SyncNewKey(:final email) ||
        SyncNeedsCode(:final email) => email,
        _ => null,
      },
    );
  }

  /// Saves the month start [day]. Returns the failure, or null on success;
  /// the settings stream re-emits the new value on its own.
  Future<StoreFailure?> setMonthStartDay(int day) async {
    final result = await ref
        .read(settingsRepositoryProvider)
        .setMonthStartDay(day);
    return switch (result) {
      Ok() => null,
      Err(:final failure) => failure,
    };
  }

  /// Turns the app lock on (after the user proves it's them, with
  /// [reason] shown) or off. Returns false when the phone has no lock or
  /// the user did not confirm; throws nothing.
  Future<({bool changed, StoreFailure? failure})> setAppLock({
    required bool on,
    required String reason,
  }) async {
    final auth = ref.read(deviceAuthProvider);
    if (on && !(await auth.isAvailable() && await auth.unlock(reason))) {
      return (changed: false, failure: null);
    }
    final result = await ref
        .read(settingsRepositoryProvider)
        .setAppLock(on: on);
    return switch (result) {
      Ok() => (changed: true, failure: null),
      Err(:final failure) => (changed: false, failure: failure),
    };
  }

  /// Saves the retention [choice] and removes text it no longer keeps.
  Future<StoreFailure?> setRetention(RawTextRetention choice) async {
    final result = await ref
        .read(settingsRepositoryProvider)
        .setRetention(choice);
    if (result case Err(:final failure)) return failure;
    final cutoff = choice.cutoff(ref.read(clockProvider).now().toUtc());
    if (cutoff == null) return null;
    final purged = await ref
        .read(captureRepositoryProvider)
        .purgeRawText(cutoff);
    return switch (purged) {
      Ok() => null,
      Err(:final failure) => failure,
    };
  }

  /// Saves the appearance [mode]. Returns the failure, or null on success.
  Future<StoreFailure?> setAppearance(AppearanceMode mode) async {
    final result = await ref
        .read(settingsRepositoryProvider)
        .setAppearance(mode);
    return switch (result) {
      Ok() => null,
      Err(:final failure) => failure,
    };
  }
}

/// Provides [SettingsNotifier].
final AsyncNotifierProvider<SettingsNotifier, SettingsState>
settingsNotifierProvider =
    AsyncNotifierProvider.autoDispose<SettingsNotifier, SettingsState>(
      SettingsNotifier.new,
    );
