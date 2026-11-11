import 'dart:async';

import 'package:expense_tracker/core/budget_input.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/features/rooms/presentation/room_editor_notifier.dart';
import 'package:expense_tracker/formatting/date_format.dart';
import 'package:expense_tracker/formatting/room_text.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/l10n/failure_messages.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/choice_pill.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:expense_tracker/widgets/switch_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Create or edit a Room: name, type, emoji, dates, budget, how expenses
/// join, and whether it counts in the monthly budget (spec §9.1, §9.2).
class RoomEditorScreen extends ConsumerStatefulWidget {
  /// Creates the form; [roomId] edits that Room, null creates one.
  const new({this.roomId, super.key});

  /// The Room edited, or null to create.
  final String? roomId;

  @override
  ConsumerState<RoomEditorScreen> createState() => _RoomEditorScreenState();
}

class _RoomEditorScreenState extends ConsumerState<RoomEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _budget = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _name.dispose();
    _budget.dispose();
    super.dispose();
  }

  // Fills the text fields once, from the Room being edited.
  void _fill(RoomEditorState state) {
    if (_filled) return;
    _filled = true;
    final room = state.original;
    if (room == null) return;
    _name.text = room.name;
    final budget = room.budget;
    if (budget != null) _budget.text = '${budget.wholeRupees}';
  }

  Future<void> _pickDate({
    required DateTime? current,
    required DateTime? first,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final today = ref.read(clockProvider).now().toLocal();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          current ?? (first != null && first.isAfter(today) ? first : today),
      firstDate: first ?? DateTime(today.year - 5),
      lastDate: DateTime(today.year + 5),
    );
    // Null means dismissed: keep the date.
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final provider = roomEditorNotifierProvider(widget.roomId);
    ref.listen(provider.select((s) => s.value?.savedId), (previous, next) {
      if (next == null) return;
      if (widget.roomId == null) {
        // A new Room opens straight away.
        context.pushReplacement(Routes.room(next));
      } else {
        context.pop();
      }
    });
    final async = ref.watch(provider);
    final state = async.value;
    final close = RoundIconButton(
      icon: Icons.close_rounded,
      tooltip: l10n.close,
      floating: false,
      color: colors.onSurface,
      onPressed: context.pop,
    );
    final title = Text(
      widget.roomId == null ? l10n.roomNewTitle : l10n.roomEditTitle,
    );
    if (state == null) {
      return LargeTitlePage(
        title: title,
        leading: close,
        children: [
          if (async is AsyncError)
            ErrorStateView(
              message: l10n.failureLoad,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(provider),
            )
          else
            PulsingPlaceholder(semanticLabel: l10n.loading),
        ],
      );
    }
    _fill(state);
    final notifier = ref.read(provider.notifier);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final start = state.start;
    final end = state.end;
    final failure = state.failure;
    final dateError = switch (state.dateError) {
      RoomDateError.startRequired =>
        state.type.needsDates
            ? l10n.roomStartRequired
            : l10n.roomWindowNeedsStart,
      RoomDateError.endBeforeStart => l10n.roomEndBeforeStart,
      null => null,
    };
    Widget heading(String text) => Padding(
      padding: EdgeInsetsDirectional.only(
        top: metrics.spaceLg,
        bottom: metrics.spaceSm,
        start: metrics.spaceXs,
      ),
      child: Semantics(
        header: true,
        child: Text(text, style: textTheme.titleMedium),
      ),
    );
    final pillGap = metrics.spaceSm;

    return LargeTitlePage(
      title: title,
      leading: close,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                autofocus: widget.roomId == null,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.roomNameLabel,
                  hintText: l10n.roomNameHint,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.roomNameRequired : null,
              ),
              heading(l10n.roomTypeLabel),
              Wrap(
                spacing: pillGap,
                runSpacing: pillGap,
                children: [
                  for (final type in RoomType.values)
                    ChoicePill(
                      label: roomTypeName(l10n, type),
                      selected: state.type == type,
                      onTap: () => notifier.setType(type),
                    ),
                ],
              ),
              heading(l10n.roomEmojiLabel),
              Wrap(
                spacing: pillGap,
                runSpacing: pillGap,
                children: [
                  for (final emoji in RoomEditorState.emojis)
                    ChoicePill(
                      label: emoji,
                      semanticLabel: l10n.roomEmojiSemantics(emoji),
                      selected: state.emoji == emoji,
                      onTap: () => notifier.setEmoji(emoji),
                    ),
                  ChoicePill(
                    label: l10n.roomNoEmoji,
                    selected: state.emoji == null,
                    onTap: () => notifier.setEmoji(null),
                  ),
                ],
              ),
              heading(l10n.roomDatesLabel),
              Wrap(
                spacing: pillGap,
                runSpacing: pillGap,
                children: [
                  ChoicePill(
                    icon: Icons.event_rounded,
                    label: start == null
                        ? l10n.roomStartLabel
                        : l10n.roomStartValue(
                            formatShortDate(start.date, locale),
                          ),
                    selected: false,
                    onTap: () => unawaited(
                      _pickDate(
                        current: start?.date,
                        first: null,
                        onPicked: notifier.setStart,
                      ),
                    ),
                  ),
                  ChoicePill(
                    icon: Icons.event_available_rounded,
                    label: end == null
                        ? (state.type == RoomType.trip
                              ? l10n.roomNoEnd
                              : l10n.roomEndLabel)
                        : l10n.roomEndValue(formatShortDate(end.date, locale)),
                    selected: false,
                    onTap: () => unawaited(
                      _pickDate(
                        current: end?.date,
                        first: start?.date,
                        onPicked: notifier.setEnd,
                      ),
                    ),
                  ),
                  if (end != null)
                    TextButton(
                      onPressed: () => notifier.setEnd(null),
                      child: Text(l10n.roomClearEnd),
                    ),
                ],
              ),
              if (dateError != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: metrics.spaceSm,
                    start: metrics.spaceXs,
                  ),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      dateError,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.danger,
                      ),
                    ),
                  ),
                ),
              heading(l10n.roomModeLabel),
              if (state.type.choosesMode)
                Wrap(
                  spacing: pillGap,
                  runSpacing: pillGap,
                  children: [
                    for (final mode in [
                      AutoTagMode.suggest,
                      AutoTagMode.dateWindow,
                      AutoTagMode.manual,
                    ])
                      ChoicePill(
                        label: switch (mode) {
                          AutoTagMode.dateWindow => l10n.roomModeDateWindow,
                          AutoTagMode.suggest => l10n.roomModeSuggest,
                          AutoTagMode.manual => l10n.roomModeManual,
                        },
                        selected: state.mode == mode,
                        onTap: () => notifier.setMode(mode),
                      ),
                  ],
                )
              else
                Padding(
                  padding: EdgeInsetsDirectional.only(start: metrics.spaceXs),
                  child: Text(
                    state.type == RoomType.trip
                        ? l10n.roomModeTripNote
                        : l10n.roomModeWeddingNote,
                    style: textTheme.bodyMedium,
                  ),
                ),
              SizedBox(height: metrics.spaceLg),
              TextFormField(
                controller: _budget,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(maxBudgetDigits),
                ],
                decoration: InputDecoration(
                  labelText: l10n.roomBudgetLabel,
                  hintText: l10n.roomBudgetHint,
                ),
              ),
              SizedBox(height: metrics.spaceLg),
              AppCard(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: metrics.spaceLg,
                  vertical: metrics.spaceSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchRow(
                      leading: IconTile(
                        icon: Icons.account_balance_wallet_rounded,
                        color: CategoryColors.of(context).amber,
                      ),
                      title: l10n.roomCountsInBudget,
                      value: state.countsInBudget,
                      onChanged: (v) => notifier.setCountsInBudget(value: v),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        bottom: metrics.spaceSm,
                      ),
                      child: Text(
                        l10n.roomCountsInBudgetNote,
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              if (failure != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(top: metrics.spaceMd),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      failureMessage(l10n, failure),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.danger,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: metrics.spaceLg),
              FilledButton(
                onPressed: state.isSaving
                    ? null
                    : () {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        unawaited(
                          notifier.save(
                            name: _name.text,
                            budgetText: _budget.text,
                          ),
                        );
                      },
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
