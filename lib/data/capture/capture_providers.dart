import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/data/capture/auto_ingestion.dart';
import 'package:expense_tracker/data/capture/capture_ingestion.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/repositories/capture_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:txn_parser/txn_parser.dart';

/// The message parser.
final txnParserProvider = Provider<TxnParser>((ref) => const TxnParser());

/// Turns captures into drafts or records.
final captureIngestionProvider = Provider<CaptureIngestion>(
  (ref) => CaptureIngestion(
    ref.watch(txnParserProvider),
    ref.watch(captureRepositoryProvider),
  ),
);

/// Captures handed to Quick Add by id (shared text waits here, so message
/// text never goes into a route). Held in memory only.
class PendingCapturesNotifier extends Notifier<Map<String, RawCapture>> {
  @override
  Map<String, RawCapture> build() => const {};

  /// Holds [capture] until Quick Add takes it.
  void put(RawCapture capture) => state = {...state, capture.id: capture};

  /// Removes and returns the capture with [id], or null.
  RawCapture? take(String id) {
    final capture = state[id];
    if (capture != null) state = {...state}..remove(id);
    return capture;
  }
}

/// Provides [PendingCapturesNotifier].
final pendingCapturesProvider =
    NotifierProvider<PendingCapturesNotifier, Map<String, RawCapture>>(
      PendingCapturesNotifier.new,
    );

/// Unresolved Unparsed messages, newest first. Live.
final unparsedMessagesProvider = StreamProvider<List<UnparsedItem>>(
  (ref) => ref.watch(captureRepositoryProvider).watchUnparsed(),
);

/// Saves automatically captured messages.
final autoIngestionProvider = Provider<AutoIngestion>(
  (ref) => AutoIngestion(
    ref.watch(captureIngestionProvider),
    ref.watch(autoCaptureRepositoryProvider),
    ref.watch(transactionRepositoryProvider),
    ref.watch(roomRepositoryProvider),
    ref.watch(payeeRepositoryProvider),
  ),
);
