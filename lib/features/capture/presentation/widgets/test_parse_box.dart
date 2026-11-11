import 'package:expense_tracker/features/capture/presentation/iphone_setup_notifier.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/not_payment_reason.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:flutter/material.dart';

/// A field to paste a bank SMS into and a Check button; shows what the app
/// would make of it. Nothing is saved.
class TestParseBox extends StatefulWidget {
  /// Creates the box.
  const new({required this.result, required this.onCheck, super.key});

  /// The last result, or null before a check.
  final TestReading? result;

  /// Called with the text to check.
  final ValueChanged<String> onCheck;

  @override
  State<TestParseBox> createState() => _TestParseBoxState();
}

class _TestParseBoxState extends State<TestParseBox> {
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String _describe(AppLocalizations l10n, TestReading reading) {
    return switch (reading) {
      TestPayment(:final amount, :final direction, :final payee) => () {
        final money = formatMoney(amount);
        final way = switch (direction) {
          TestDirection.spent => l10n.iosTestSpent,
          TestDirection.received => l10n.iosTestReceived,
          TestDirection.refunded => l10n.iosTestRefund,
        };
        return payee == null
            ? l10n.iosTestParsed(money, way)
            : l10n.iosTestParsedPayee(money, way, payee);
      }(),
      TestNotPayment(:final messageClass) => l10n.iosTestNotPayment(
        notPaymentReason(l10n, messageClass),
      ),
      TestUnreadable() => l10n.iosTestUnreadable,
      TestNoAmount() => l10n.iosTestNoAmount,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final result = widget.result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _text,
          minLines: 2,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(hintText: l10n.iosTestHint),
        ),
        SizedBox(height: metrics.spaceSm),
        OutlinedButton(
          onPressed: () => widget.onCheck(_text.text),
          child: Text(l10n.iosTestCheck),
        ),
        if (result != null) ...[
          SizedBox(height: metrics.spaceSm),
          Semantics(
            liveRegion: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  result is TestPayment
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: colors.accent,
                ),
                SizedBox(width: metrics.spaceSm),
                Expanded(
                  child: Text(
                    _describe(l10n, result),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
