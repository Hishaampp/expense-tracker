import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// What the Settings screen shows.
@immutable
final class SettingsState {
  /// Creates the state.
  const new({required this.monthStartDay});

  /// The day of the month a budgeting month starts on.
  final int monthStartDay;
}

/// The Settings view model over the live settings.
class SettingsNotifier extends StreamNotifier<SettingsState> {
  @override
  Stream<SettingsState> build() {
    return ref
        .watch(settingsRepositoryProvider)
        .watchMonthStartDay()
        .map((day) => SettingsState(monthStartDay: day));
  }

  /// Saves the month start [day]. Returns the failure, or null on success;
  /// the stream re-emits the new value on its own.
  Future<StoreFailure?> setMonthStartDay(int day) async {
    final result = await ref
        .read(settingsRepositoryProvider)
        .setMonthStartDay(day);
    return switch (result) {
      Ok() => null,
      Err(:final failure) => failure,
    };
  }
}

/// Provides [SettingsNotifier].
final StreamNotifierProvider<SettingsNotifier, SettingsState>
settingsNotifierProvider =
    StreamNotifierProvider.autoDispose<SettingsNotifier, SettingsState>(
      SettingsNotifier.new,
    );
