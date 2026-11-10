import 'dart:async';

import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Puts back a deleted expense when the user taps Undo. Lives at app scope
/// because the Undo snackbar outlasts the screen that deleted it.
class UndoDeleteNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Restores [deleted]. A failure is already logged by the repository; the
  /// lists then simply stay as they are.
  void restore(MoneyTransaction deleted) {
    unawaited(_restore(deleted));
  }

  Future<void> _restore(MoneyTransaction deleted) async {
    switch (await ref.read(transactionRepositoryProvider).restore(deleted)) {
      case Ok():
      case Err():
        return;
    }
  }
}

/// Provides [UndoDeleteNotifier].
final undoDeleteProvider = NotifierProvider<UndoDeleteNotifier, void>(
  UndoDeleteNotifier.new,
);
