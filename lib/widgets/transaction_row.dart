import 'package:expense_tracker/formatting/transaction_row_text.dart';
import 'package:expense_tracker/widgets/category_style.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/info_row.dart';
import 'package:flutter/material.dart';

/// One transaction as a row inside a card.
class TransactionRow extends StatelessWidget {
  /// Creates the row from already-localized [text].
  const new({required this.text, required this.onTap, super.key});

  /// What the row shows.
  final TransactionRowText text;

  /// Opens the transaction.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyle(context, text.iconKey);
    return InfoRow(
      leading: IconTile(icon: style.icon, color: style.color),
      title: text.title,
      subtitle: text.subtitle,
      trailingText: text.amountText,
      tone: text.tone,
      semanticLabel: text.semanticLabel,
      onTap: onTap,
    );
  }
}
