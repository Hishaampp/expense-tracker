import 'dart:async';

import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/payee_rule.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/category/all_categories_sheet.dart';
import 'package:expense_tracker/widgets/choice_pill.dart';
import 'package:expense_tracker/widgets/room_picker_sheet.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';

/// What the payee sheet returns: the rule to save (an empty one forgets
/// it). The sheet pops null when dismissed.
typedef PayeeEdit = ({PayeeRule rule});

/// Edits one payee: its name, the category it always gets, and the Room
/// its payments go to.
class PayeeSheet extends StatefulWidget {
  /// Creates the sheet.
  const new({
    required this.entry,
    required this.categories,
    required this.rooms,
    super.key,
  });

  /// The payee.
  final PayeeEntry entry;

  /// Expense categories to choose from.
  final List<Category> categories;

  /// Active Rooms to choose from.
  final List<Room> rooms;

  @override
  State<PayeeSheet> createState() => _PayeeSheetState();
}

class _PayeeSheetState extends State<PayeeSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.entry.rule?.displayName ?? widget.entry.name,
  );
  late String? _categoryId = widget.entry.rule?.categoryId;
  late String? _roomId = widget.entry.rule?.roomId;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppSheet<String>(
      context,
      AllCategoriesSheet(
        title: l10n.payeesPickCategory,
        categories: widget.categories,
        selectedId: _categoryId,
        selectedLabel: l10n.selected,
      ),
    );
    if (picked != null && mounted) setState(() => _categoryId = picked);
  }

  Future<void> _pickRoom() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppSheet<RoomPick>(
      context,
      RoomPickerSheet(
        title: l10n.payeesPickRoom,
        rooms: widget.rooms,
        selectedId: _roomId,
      ),
    );
    if (picked != null && mounted) setState(() => _roomId = picked.roomId);
  }

  void _save() {
    final typed = _name.text.trim();
    // The bank's own name is not a rename.
    final name = typed.isEmpty || typed == widget.entry.name ? null : typed;
    Navigator.of(context).pop<PayeeEdit>((
      rule: PayeeRule(
        payeeKey: widget.entry.payeeKey,
        categoryId: _categoryId,
        roomId: _roomId,
        displayName: name ?? widget.entry.rule?.displayName,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final category = widget.categories
        .where((c) => c.id == _categoryId)
        .firstOrNull;
    final room = widget.rooms.where((r) => r.id == _roomId).firstOrNull;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SheetFrame(
        title: widget.entry.name,
        subtitle: widget.entry.payeeKey,
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: metrics.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.payeesNameLabel,
                  hintText: l10n.payeesNameHint,
                ),
              ),
              SizedBox(height: metrics.spaceLg),
              Text(l10n.payeesCategory, style: textTheme.labelLarge),
              SizedBox(height: metrics.spaceSm),
              Wrap(
                spacing: metrics.spaceSm,
                runSpacing: metrics.spaceSm,
                children: [
                  ChoicePill(
                    label: l10n.payeesAskEachTime,
                    selected: category == null,
                    onTap: () => setState(() => _categoryId = null),
                  ),
                  ChoicePill(
                    label: category?.name ?? l10n.quickAddMore,
                    icon: Icons.category_rounded,
                    selected: category != null,
                    onTap: () => unawaited(_pickCategory()),
                  ),
                ],
              ),
              if (widget.rooms.isNotEmpty || room != null) ...[
                SizedBox(height: metrics.spaceLg),
                Text(l10n.payeesRoom, style: textTheme.labelLarge),
                SizedBox(height: metrics.spaceSm),
                Wrap(
                  spacing: metrics.spaceSm,
                  runSpacing: metrics.spaceSm,
                  children: [
                    ChoicePill(
                      label: l10n.payeesNoRoom,
                      selected: _roomId == null,
                      onTap: () => setState(() => _roomId = null),
                    ),
                    ChoicePill(
                      label: room?.name ?? l10n.quickAddPickRoom,
                      icon: Icons.luggage_rounded,
                      selected: room != null,
                      onTap: () => unawaited(_pickRoom()),
                    ),
                  ],
                ),
              ],
              SizedBox(height: metrics.spaceXl),
              FilledButton(onPressed: _save, child: Text(l10n.payeesSave)),
              if (widget.entry.rule != null) ...[
                SizedBox(height: metrics.spaceSm),
                TextButton(
                  onPressed: () => Navigator.of(context).pop<PayeeEdit>((
                    rule: PayeeRule(payeeKey: widget.entry.payeeKey),
                  )),
                  child: Text(l10n.payeesForget),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
