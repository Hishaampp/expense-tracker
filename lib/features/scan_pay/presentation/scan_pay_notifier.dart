import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/core/upi_qr.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:expense_tracker/services/upi_pay_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:meta/meta.dart';

/// What the Scan & Pay screen shows (Phase 11).
@immutable
final class ScanPayState {
  /// Creates the state.
  const new({
    required this.request,
    required this.categories,
    required this.apps,
    this.amountText = '',
    this.categoryId,
    this.isBusy = false,
  });

  /// The scanned payment request.
  final UpiRequest request;

  /// Expense categories to choose from, in their usual order.
  final List<Category> categories;

  /// UPI apps on this phone.
  final List<UpiApp> apps;

  /// The amount as typed.
  final String amountText;

  /// The category chosen, if any.
  final String? categoryId;

  /// Whether a payment or a save is under way.
  final bool isBusy;

  /// The amount to pay: the QR's when it sets one, else the typed amount;
  /// null while it is not a valid amount.
  Money? get amount =>
      request.isFixed ? request.amount : parseRupees(amountText);

  /// Whether Pay can be pressed.
  bool get canPay => amount != null && !isBusy && apps.isNotEmpty;

  /// A copy with the given fields replaced.
  ScanPayState copyWith({
    String? amountText,
    String? categoryId,
    bool? isBusy,
  }) => ScanPayState(
    request: request,
    categories: categories,
    apps: apps,
    amountText: amountText ?? this.amountText,
    categoryId: categoryId ?? this.categoryId,
    isBusy: isBusy ?? this.isBusy,
  );
}

/// Reads typed rupees ("250", "99.50") as money; null when it is not an
/// amount above zero.
Money? parseRupees(String text) {
  final match = RegExp(r'^(\d{1,9})(?:\.(\d{0,2}))?$').firstMatch(text.trim());
  if (match == null) return null;
  final paise =
      int.parse(match.group(1)!) * 100 +
      int.parse((match.group(2) ?? '').padRight(2, '0'));
  return paise > 0 ? Money(paise) : null;
}

/// The Scan & Pay view model, for the scanned QR text it is keyed by.
/// Throws [ArgumentError] in build when the text is not a UPI request.
class ScanPayNotifier extends AsyncNotifier<ScanPayState> {
  /// Creates the notifier for [qr].
  new(this.qr);

  /// The scanned text.
  final String qr;

  @override
  Future<ScanPayState> build() async {
    final request = UpiRequest.tryParse(qr);
    if (request == null) throw ArgumentError.value(qr, 'qr', 'not a UPI QR');
    final all = await ref.watch(categoriesProvider.future);
    final categories = [
      for (final c in all)
        if (c.kind == CategoryKind.expense && !c.isArchived) c,
    ];
    final apps = await ref.read(upiPayServiceProvider).apps();
    // A payee paid before keeps its category.
    final rule = await ref
        .read(payeeRepositoryProvider)
        .ruleFor(request.payeeVpa);
    return ScanPayState(
      request: request,
      categories: categories,
      apps: apps,
      amountText: request.amount == null ? '' : _plain(request.amount!),
      categoryId: rule?.categoryId,
    );
  }

  static String _plain(Money m) {
    final paise = m.paise % 100;
    return paise == 0
        ? '${m.paise ~/ 100}'
        : '${m.paise ~/ 100}.${'$paise'.padLeft(2, '0')}';
  }

  void _update(ScanPayState Function(ScanPayState) change) {
    final current = state.value;
    if (current == null || current.isBusy) return;
    state = AsyncData(change(current));
  }

  /// The amount was edited.
  void setAmount(String text) => _update((s) => s.copyWith(amountText: text));

  /// A category was chosen.
  void pickCategory(String id) {
    ref.read(hapticsProvider).select();
    _update((s) => s.copyWith(categoryId: id));
  }

  /// Opens [app] to pay and waits for the payer to come back. Null when
  /// the app could not be opened.
  Future<UpiResult?> pay(UpiApp app) async {
    final current = state.value;
    final amount = current?.amount;
    if (current == null || amount == null || !current.canPay) return null;
    state = AsyncData(current.copyWith(isBusy: true));
    try {
      return await ref
          .read(upiPayServiceProvider)
          .pay(app, current.request.payUri);
    } finally {
      final now = state.value;
      if (now != null) state = AsyncData(now.copyWith(isBusy: false));
    }
  }

  /// Records the payment: [status] confirmed when it is known to have gone
  /// through, needsReview while that is not known. [amount] replaces the
  /// planned amount when the payer says it differed.
  Future<StoreFailure?> save({
    required ReviewStatus status,
    String? refNo,
    Money? amount,
  }) async {
    final current = state.value;
    final paid = amount ?? current?.amount;
    if (current == null || paid == null) return null;
    final result = await ref
        .read(transactionRepositoryProvider)
        .addUpiPayment(
          amount: paid,
          payeeVpa: current.request.payeeVpa,
          payeeName: current.request.displayName,
          categoryId: current.categoryId,
          refNo: refNo,
          reviewStatus: status,
        );
    switch (result) {
      case Ok():
        ref.read(hapticsProvider).commit();
        return null;
      case Err(:final failure):
        return failure;
    }
  }
}

/// Provides [ScanPayNotifier] for scanned QR text.
final AsyncNotifierProviderFamily<ScanPayNotifier, ScanPayState, String>
scanPayNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<ScanPayNotifier, ScanPayState, String>(ScanPayNotifier.new);
