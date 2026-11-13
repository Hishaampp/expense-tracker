import 'dart:async';

import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/features/scan_pay/presentation/leave_scan_pay.dart';
import 'package:expense_tracker/features/scan_pay/presentation/scan_pay_notifier.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/services/upi_pay_service.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/choice_pill.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/option_sheet.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The answer to "Did the payment go through?".
enum _Answer { yes, no, other }

/// Scan & Pay's payment screen (Phase 11): who is being paid, the amount
/// and what it was for, then a UPI app to pay with. Records the payment
/// when it is known to have gone through, or keeps it in Review.
class ScanPayScreen extends ConsumerStatefulWidget {
  /// Creates the screen for the scanned [qr] text.
  const new({required this.qr, super.key});

  /// The scanned QR text.
  final String qr;

  @override
  ConsumerState<ScanPayScreen> createState() => _ScanPayScreenState();
}

class _ScanPayScreenState extends ConsumerState<ScanPayScreen> {
  final TextEditingController _amount = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  ScanPayNotifier get _notifier =>
      ref.read(scanPayNotifierProvider(widget.qr).notifier);

  // Records the payment (waiting in Review), opens the UPI app for the
  // payer to scan and pay there, then settles it with their answer.
  Future<void> _pay(ScanPayState state) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final app = await _chooseApp(state.apps);
    if (app == null || !mounted) return;
    final result = await _notifier.recordAndOpen(app);
    if (!mounted) return;
    if (result.failure case final failure?) {
      _say(messenger, failureMessage(l10n, failure));
      return;
    }
    final id = result.id;
    if (id == null) return;
    if (!result.opened) {
      await _notifier.settle(id, paid: false);
      _say(messenger, l10n.scanPayNotOpened(app.name));
      return;
    }
    await _ask(state, id);
  }

  Future<UpiApp?> _chooseApp(List<UpiApp> apps) async {
    if (apps.length == 1) return apps.single;
    final l10n = AppLocalizations.of(context);
    final picked = await showAppSheet<OptionPick>(
      context,
      OptionSheet(
        title: l10n.scanPayWith,
        options: [
          for (final app in apps) (value: app.id, label: app.name, icon: null),
        ],
        selected: null,
      ),
    );
    // Null means dismissed: pay with nothing.
    return apps.where((a) => a.id == picked?.value).firstOrNull;
  }

  // Back from the UPI app: ask how it went.
  Future<void> _ask(ScanPayState state, String id) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final amount = state.amount;
    if (amount == null) return;
    final name = state.request.displayName;
    final answer = await showDialog<_Answer>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scanPayAskTitle),
        content: Text(l10n.scanPayAskBody(formatMoney(amount), name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_Answer.no),
            child: Text(l10n.scanPayAskNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_Answer.other),
            child: Text(l10n.scanPayAskOther),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_Answer.yes),
            child: Text(l10n.scanPayAskYes),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (answer) {
      case _Answer.yes:
        await _settle(
          id,
          paid: true,
          message: l10n.scanPaySaved(formatMoney(amount), name),
        );
      case _Answer.no:
        await _settle(id, paid: false, message: l10n.scanPayFailed);
      case _Answer.other:
        final paid = await _askAmount();
        if (!mounted) return;
        if (paid == null) {
          _say(messenger, l10n.scanPayToReview);
          leaveScanPay(context);
          return;
        }
        await _settle(
          id,
          paid: true,
          amount: paid,
          message: l10n.scanPaySaved(formatMoney(paid), name),
        );
      // Dismissed: not known yet, so it stays in Review.
      case null:
        _say(messenger, l10n.scanPayToReview);
        leaveScanPay(context);
    }
  }

  Future<Money?> _askAmount() => showDialog<Money>(
    context: context,
    builder: (_) => const _AmountDialog(),
  );

  Future<void> _settle(
    String id, {
    required bool paid,
    required String message,
    Money? amount,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final failure = await _notifier.settle(id, paid: paid, amount: amount);
    _say(messenger, failure == null ? message : failureMessage(l10n, failure));
    if (failure == null && mounted) leaveScanPay(context);
  }

  void _say(ScaffoldMessengerState messenger, String text) => messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final provider = scanPayNotifierProvider(widget.qr);
    final async = ref.watch(provider);
    final state = async.value;
    if (state != null && !_seeded) {
      _seeded = true;
      _amount.text = state.amountText;
    }
    final Widget body;
    if (state != null) {
      body = _PayForm(
        state: state,
        amount: _amount,
        onAmount: _notifier.setAmount,
        onCategory: _notifier.pickCategory,
        onPay: () => unawaited(_pay(state)),
      );
    } else if (async.hasError) {
      body = Center(
        child: ErrorStateView(
          message: l10n.scanNotUpi,
          actionLabel: l10n.close,
          onAction: () => leaveScanPay(context),
        ),
      );
    } else {
      body = Center(child: PulsingPlaceholder(semanticLabel: l10n.loading));
    }
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Align(
          alignment: AlignmentDirectional.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: metrics.readableWidth),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: metrics.spaceLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.close_rounded,
                        tooltip: l10n.close,
                        floating: false,
                        color: colors.onSurface,
                        onPressed: () => leaveScanPay(context),
                      ),
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            l10n.scanPayTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      SizedBox.square(dimension: metrics.minTapTarget),
                    ],
                  ),
                  Expanded(child: body),
                  SizedBox(height: metrics.spaceSm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PayForm extends StatelessWidget {
  const new({
    required this.state,
    required this.amount,
    required this.onAmount,
    required this.onCategory,
    required this.onPay,
  });

  final ScanPayState state;
  final TextEditingController amount;
  final ValueChanged<String> onAmount;
  final ValueChanged<String> onCategory;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final request = state.request;
    final paying = state.amount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: metrics.spaceLg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.scanPayTo, style: textTheme.bodySmall),
                      SizedBox(height: metrics.spaceXs),
                      Text(request.displayName, style: textTheme.titleLarge),
                      if (request.payeeName != null)
                        Text(request.payeeVpa, style: textTheme.bodyMedium),
                      SizedBox(height: metrics.spaceMd),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            size: metrics.iconSize,
                            color: colors.accent,
                          ),
                          SizedBox(width: metrics.spaceSm),
                          Expanded(
                            child: Text(
                              l10n.scanPayCheck,
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: metrics.spaceLg),
                if (request.isFixed && paying != null) ...[
                  Text(formatMoney(paying), style: textTheme.headlineMedium),
                  Text(l10n.scanPayFixedAmount, style: textTheme.bodySmall),
                  SizedBox(height: metrics.spaceXs),
                  Text(l10n.scanPayTypeThere, style: textTheme.bodySmall),
                ] else
                  TextField(
                    controller: amount,
                    autofocus: request.amount == null,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.scanPayAmountLabel,
                      prefixText: rupeeFieldPrefix,
                    ),
                    onChanged: onAmount,
                  ),
                if (!request.isFixed || paying == null) ...[
                  SizedBox(height: metrics.spaceXs),
                  Text(l10n.scanPayTypeThere, style: textTheme.bodySmall),
                ],
                SizedBox(height: metrics.spaceLg),
                Semantics(
                  header: true,
                  child: Text(l10n.scanPayFor, style: textTheme.titleMedium),
                ),
                SizedBox(height: metrics.spaceSm),
                Wrap(
                  spacing: metrics.spaceSm,
                  runSpacing: metrics.spaceSm,
                  children: [
                    for (final c in state.categories)
                      ChoicePill(
                        label: c.name,
                        selected: c.id == state.categoryId,
                        onTap: () => onCategory(c.id),
                      ),
                  ],
                ),
                SizedBox(height: metrics.spaceLg),
              ],
            ),
          ),
        ),
        if (state.apps.isEmpty)
          Text(
            l10n.scanPayNoApps,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          )
        else
          FilledButton(
            onPressed: state.canPay ? onPay : null,
            child: Text(
              paying == null
                  ? l10n.scanPayAmountInvalid
                  : l10n.scanPayButton(formatMoney(paying)),
            ),
          ),
      ],
    );
  }
}

/// Asks how much was actually paid. Pops the amount, or null.
class _AmountDialog extends StatefulWidget {
  const new();

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final paid = parseRupees(_text.text);
    return AlertDialog(
      title: Text(l10n.scanPayOtherTitle),
      content: TextField(
        controller: _text,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]'))],
        decoration: InputDecoration(
          labelText: l10n.scanPayAmountLabel,
          prefixText: rupeeFieldPrefix,
        ),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: paid == null
              ? null
              : () => Navigator.of(context).pop(paid),
          child: Text(l10n.scanPaySave),
        ),
      ],
    );
  }
}
