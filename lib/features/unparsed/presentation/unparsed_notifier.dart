import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/repositories/capture_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One message on the Unparsed screen, with its local arrival date.
typedef UnparsedEntry = ({UnparsedItem item, DateTime localDay});

/// The Unparsed screen's view model: unresolved messages, newest first,
/// with the local date each arrived. Live.
class UnparsedNotifier extends StreamNotifier<List<UnparsedEntry>> {
  @override
  Stream<List<UnparsedEntry>> build() {
    return ref
        .watch(captureRepositoryProvider)
        .watchUnparsed()
        .map(
          (items) => [
            for (final item in items)
              (item: item, localDay: item.receivedAt.toLocal()),
          ],
        );
  }
}

/// Provides [UnparsedNotifier].
final StreamNotifierProvider<UnparsedNotifier, List<UnparsedEntry>>
unparsedNotifierProvider =
    StreamNotifierProvider.autoDispose<UnparsedNotifier, List<UnparsedEntry>>(
      UnparsedNotifier.new,
    );
