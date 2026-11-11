import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/capture/capture_providers.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:txn_parser/txn_parser.dart';

/// What a test message was read as.
sealed class TestReading {
  const new();
}

/// Which way a test payment went.
enum TestDirection {
  /// Money out.
  spent,

  /// Money in.
  received,

  /// A refund.
  refunded,
}

/// A payment: [amount] in [direction], to or from [payee] if named.
final class TestPayment extends TestReading {
  /// Creates the reading.
  const new(this.amount, this.direction, this.payee);

  /// The amount.
  final Money amount;

  /// Which way it went.
  final TestDirection direction;

  /// Who, if the message says.
  final String? payee;
}

/// Not a payment ([messageClass] says what it is); it would be skipped.
final class TestNotPayment extends TestReading {
  /// Creates the reading.
  const new(this.messageClass);

  /// What the message is.
  final MessageClass messageClass;
}

/// Has an amount but could not be read; it would go to Unparsed.
final class TestUnreadable extends TestReading {
  /// Creates the reading.
  const new();
}

/// No amount at all.
final class TestNoAmount extends TestReading {
  /// Creates the reading.
  const new();
}

/// The iPhone setup guide's view model: test-parse a message (nothing is
/// saved) and record that setup is done (spec §6.3).
class IphoneSetupNotifier extends Notifier<TestReading?> {
  @override
  TestReading? build() => null;

  /// Parses [text] to show what the app would make of it.
  void test(String text) {
    if (text.trim().isEmpty) {
      state = null;
      return;
    }
    state = switch (ref.read(txnParserProvider).parse(text)) {
      ParsedTransaction(:final messageClass, :final fields) => TestPayment(
        Money(fields.amountPaise),
        messageClass == MessageClass.reversalRefund
            ? TestDirection.refunded
            : fields.direction == Direction.debit
            ? TestDirection.spent
            : TestDirection.received,
        fields.payeeName ?? fields.payeeVpa,
      ),
      DroppedMessage(:final messageClass) => TestNotPayment(messageClass),
      UnparsedMessage() => const TestUnreadable(),
      NoAmount() => const TestNoAmount(),
    };
  }

  /// Opens the Shortcuts app. Returns false if the phone refused.
  Future<bool> openShortcuts() async {
    try {
      await ref.read(captureControlProvider).openCaptureSettings();
      return true;
    } on PlatformException catch (e, st) {
      ref.read(appLoggerProvider).error('ios.open', e.runtimeType, st);
      return false;
    } on MissingPluginException catch (e, st) {
      ref.read(appLoggerProvider).error('ios.open', e.runtimeType, st);
      return false;
    }
  }

  /// Records that setup is done. Returns the failure, or null.
  Future<StoreFailure?> markDone() async {
    final now = ref.read(clockProvider).now().toUtc();
    final result = await ref
        .read(settingsRepositoryProvider)
        .setIosShortcutSetupAt(now);
    return switch (result) {
      Ok() => null,
      Err(:final failure) => failure,
    };
  }
}

/// Provides [IphoneSetupNotifier].
final NotifierProvider<IphoneSetupNotifier, TestReading?>
iphoneSetupNotifierProvider =
    NotifierProvider.autoDispose<IphoneSetupNotifier, TestReading?>(
      IphoneSetupNotifier.new,
    );
