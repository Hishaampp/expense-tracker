import 'dart:async';

import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/transaction_filter.dart';
import 'package:expense_tracker/features/activity/presentation/activity_notifier.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/widgets/choice_pill.dart';
import 'package:expense_tracker/widgets/option_sheet.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:flutter/material.dart';

/// The search field and filter pills over Activity. Changes go to
/// [onChanged]; the list follows.
class ActivitySearch extends StatefulWidget {
  /// Creates the bar for [state].
  const new({required this.state, required this.onChanged, super.key});

  /// What Activity shows now, with the filter applied.
  final ActivityState state;

  /// Called with the new filter.
  final ValueChanged<TransactionFilter> onChanged;

  @override
  State<ActivitySearch> createState() => _ActivitySearchState();
}

class _ActivitySearchState extends State<ActivitySearch> {
  late final TextEditingController _query = TextEditingController(
    text: widget.state.filter.query,
  );

  @override
  void didUpdateWidget(ActivitySearch old) {
    super.didUpdateWidget(old);
    // "Clear filters" also clears the field.
    final query = widget.state.filter.query;
    if (query != _query.text) _query.text = query;
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  TransactionFilter get _filter => widget.state.filter;

  Future<void> _pick({
    required String title,
    required List<SheetOption> options,
    required String? selected,
    required TransactionFilter Function(String? value) apply,
  }) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppSheet<OptionPick>(
      context,
      OptionSheet(
        title: title,
        options: [
          (value: null, label: l10n.activityAny, icon: null),
          ...options,
        ],
        selected: selected,
      ),
    );
    // Null means dismissed: keep the filter.
    if (picked != null) widget.onChanged(apply(picked.value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final state = widget.state;
    final filter = _filter;
    String? nameOf<T>(
      Iterable<T> items,
      String? id,
      String Function(T) key,
      String Function(T) name,
    ) => id == null
        ? null
        : items.where((i) => key(i) == id).map(name).firstOrNull;
    final category = nameOf(
      state.categories,
      filter.categoryId,
      (c) => c.id,
      (c) => c.name,
    );
    final room = nameOf(state.rooms, filter.roomId, (r) => r.id, (r) => r.name);
    final account = nameOf(
      state.accounts,
      filter.accountId,
      (a) => a.id,
      (a) => a.name,
    );
    String kindName(TransactionKind kind) => switch (kind) {
      TransactionKind.expense => l10n.kindSpent,
      TransactionKind.income => l10n.kindMoneyIn,
      TransactionKind.transfer => l10n.kindTransfer,
      TransactionKind.refund => l10n.kindRefund,
    };
    String originName(TransactionOrigin origin) => switch (origin) {
      TransactionOrigin.manual => l10n.sourceManual,
      TransactionOrigin.auto => l10n.sourceAuto,
    };
    Widget pill(String name, String? value, VoidCallback onTap) => Semantics(
      container: true,
      button: true,
      selected: value != null,
      label: l10n.activityFilterSemantics(name, value ?? l10n.activityAny),
      onTap: onTap,
      child: ExcludeSemantics(
        child: ChoicePill(
          label: value ?? name,
          icon: value == null ? Icons.expand_more_rounded : null,
          selected: value != null,
          onTap: onTap,
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _query,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.activitySearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: filter.searches
                ? IconButton(
                    tooltip: l10n.activityClearSearch,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () =>
                        widget.onChanged(filter.copyWith(query: '')),
                  )
                : null,
          ),
          onChanged: (text) => widget.onChanged(filter.copyWith(query: text)),
        ),
        SizedBox(height: metrics.spaceSm),
        Wrap(
          spacing: metrics.spaceSm,
          runSpacing: metrics.spaceSm,
          children: [
            pill(
              l10n.activityFilterCategory,
              category,
              () => unawaited(
                _pick(
                  title: l10n.activityFilterCategory,
                  options: [
                    for (final c in state.categories)
                      (value: c.id, label: c.name, icon: null),
                  ],
                  selected: filter.categoryId,
                  apply: (v) => v == null
                      ? filter.copyWith(clear: {FilterField.category})
                      : filter.copyWith(categoryId: v),
                ),
              ),
            ),
            if (state.rooms.isNotEmpty)
              pill(
                l10n.activityFilterRoom,
                room,
                () => unawaited(
                  _pick(
                    title: l10n.activityFilterRoom,
                    options: [
                      for (final r in state.rooms)
                        (
                          value: r.id,
                          label: r.name,
                          icon: Icons.luggage_rounded,
                        ),
                    ],
                    selected: filter.roomId,
                    apply: (v) => v == null
                        ? filter.copyWith(clear: {FilterField.room})
                        : filter.copyWith(roomId: v),
                  ),
                ),
              ),
            pill(
              l10n.activityFilterAccount,
              account,
              () => unawaited(
                _pick(
                  title: l10n.activityFilterAccount,
                  options: [
                    for (final a in state.accounts)
                      (value: a.id, label: a.name, icon: null),
                  ],
                  selected: filter.accountId,
                  apply: (v) => v == null
                      ? filter.copyWith(clear: {FilterField.account})
                      : filter.copyWith(accountId: v),
                ),
              ),
            ),
            pill(
              l10n.activityFilterKind,
              filter.kind == null ? null : kindName(filter.kind!),
              () => unawaited(
                _pick(
                  title: l10n.activityFilterKind,
                  options: [
                    for (final k in TransactionKind.values)
                      (value: k.name, label: kindName(k), icon: null),
                  ],
                  selected: filter.kind?.name,
                  apply: (v) => v == null
                      ? filter.copyWith(clear: {FilterField.kind})
                      : filter.copyWith(kind: TransactionKind.values.byName(v)),
                ),
              ),
            ),
            pill(
              l10n.activityFilterSource,
              filter.origin == null ? null : originName(filter.origin!),
              () => unawaited(
                _pick(
                  title: l10n.activityFilterSource,
                  options: [
                    for (final o in TransactionOrigin.values)
                      (value: o.name, label: originName(o), icon: null),
                  ],
                  selected: filter.origin?.name,
                  apply: (v) => v == null
                      ? filter.copyWith(clear: {FilterField.origin})
                      : filter.copyWith(
                          origin: TransactionOrigin.values.byName(v),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
