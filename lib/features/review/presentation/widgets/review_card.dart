import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/features/review/presentation/review_notifier.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/app_text_styles.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/category_style.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/money_tone.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// One captured payment waiting for review: amount, payee, account and
/// time, then category choices. Tapping a choice confirms it.
class ReviewCard extends StatelessWidget {
  /// Creates the card for [item].
  const new({
    required this.item,
    required this.onPick,
    required this.onMore,
    required this.onTransfer,
    super.key,
  });

  /// The payment.
  final ReviewItem item;

  /// Confirms in the category tapped.
  final ValueChanged<Category> onPick;

  /// Opens every category.
  final VoidCallback onMore;

  /// Marks it as a transfer.
  final VoidCallback onTransfer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final txn = item.transaction;
    final isIn =
        txn.kind == TransactionKind.income ||
        txn.kind == TransactionKind.refund;
    final amount = isIn ? formatMoneyIn(txn.amount) : formatMoney(txn.amount);
    final payee = txn.payeeDisplay ?? l10n.reviewUnknownPayee;
    final when =
        '${formatShortDate(txn.occurredAt.toLocal(), locale)}, '
        '${formatTime(txn.occurredAt.toLocal(), locale)}';
    final details = item.accountName.isEmpty
        ? when
        : '${item.accountName}, $when';
    final style = categoryStyle(context, item.suggested?.iconKey ?? 'other');
    final tone = isIn ? MoneyTone.moneyIn : MoneyTone.spent;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            label: l10n.reviewCardSemantics(amount, payee, details),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  IconTile(icon: style.icon, color: style.color),
                  SizedBox(width: metrics.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(payee, style: textTheme.bodyLarge),
                        Text(details, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  SizedBox(width: metrics.spaceMd),
                  Text(
                    amount,
                    style: AppTextStyles.of(context).amountRow
                        .copyWith(color: tone.colorIn(colors)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: metrics.spaceMd),
          Wrap(
            spacing: metrics.spaceSm,
            runSpacing: metrics.spaceSm,
            children: [
              for (final category in item.choices)
                _ChoicePill(
                  category: category,
                  suggested: category.id == item.suggested?.id,
                  onTap: () => onPick(category),
                ),
              _MorePill(onTap: onMore),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onTransfer,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: Text(l10n.reviewTransfer),
            ),
          ),
        ],
      ),
    );
  }
}

/// A category choice. The suggestion is filled and marked with a tick, so
/// it stands out by shape as well as colour.
class _ChoicePill extends StatelessWidget {
  const new({
    required this.category,
    required this.suggested,
    required this.onTap,
  });

  final Category category;
  final bool suggested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final style = categoryStyle(context, category.iconKey);
    final foreground = suggested ? colors.onAccentFill : colors.onSurface;
    return Semantics(
      button: true,
      label: suggested
          ? l10n.reviewPickSuggestedSemantics(category.name)
          : l10n.reviewPickSemantics(category.name),
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: suggested ? colors.accentFill : colors.surfaceSunken,
          shape: const StadiumBorder(),
          child: Pressable(
            onTap: onTap,
            shape: const StadiumBorder(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: metrics.minTapTarget),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: metrics.spaceMd,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      suggested ? Icons.check_rounded : style.icon,
                      size: metrics.iconSize,
                      color: suggested ? foreground : style.color,
                    ),
                    SizedBox(width: metrics.spaceSm),
                    Flexible(
                      child: Text(
                        category.name,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: foreground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MorePill extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    return Semantics(
      button: true,
      label: l10n.quickAddMore,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: colors.surfaceSunken,
          shape: const StadiumBorder(),
          child: Pressable(
            onTap: onTap,
            shape: const StadiumBorder(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: metrics.minTapTarget),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: metrics.spaceMd,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.more_horiz_rounded,
                      size: metrics.iconSize,
                      color: colors.onSurfaceMuted,
                    ),
                    SizedBox(width: metrics.spaceSm),
                    Text(
                      l10n.quickAddMore,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
