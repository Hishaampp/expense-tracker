import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/appearance_mode.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/features/capture/application/capture_providers.dart';
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
  });

  /// The day of the month a budgeting month starts on.
  final int monthStartDay;

  /// Light, dark or follow the phone.
  final AppearanceMode appearance;

  /// How many messages wait on the Unparsed list; null until known.
  final int? unparsedCount;
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
