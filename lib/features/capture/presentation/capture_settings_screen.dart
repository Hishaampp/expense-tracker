import 'dart:async';

import 'package:expense_tracker/core/oem_guidance.dart';
import 'package:expense_tracker/features/capture/presentation/capture_settings_notifier.dart';
import 'package:expense_tracker/features/capture/presentation/widgets/capture_status_card.dart';
import 'package:expense_tracker/features/capture/presentation/widgets/info_card.dart';
import 'package:expense_tracker/formatting/app_names.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/pressable.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:expense_tracker/widgets/sheet_frame.dart';
import 'package:expense_tracker/widgets/switch_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings → Auto-capture (spec §6.2): whether capture is on and healthy,
/// what it reads (the disclosure, shown before access is asked for), how
/// to keep it running on this phone, and which apps it reads.
class CaptureSettingsScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<CaptureSettingsScreen> createState() =>
      _CaptureSettingsScreenState();
}

class _CaptureSettingsScreenState extends ConsumerState<CaptureSettingsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Coming back from system settings may have changed the status.
    _lifecycle = AppLifecycleListener(
      onResume: () =>
          ref.read(captureSettingsNotifierProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  // Runs a phone action; says so if the phone refused it.
  Future<void> _report(
    BuildContext context,
    Future<bool> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (await action()) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.autoCaptureActionFailed)));
  }

  Future<void> _import(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(captureSettingsNotifierProvider.notifier);
    final months = await showAppSheet<int>(
      context,
      _MonthsSheet(title: l10n.autoCaptureImport),
    );
    // Null means dismissed: import nothing.
    if (months == null) return;
    final count = await notifier.importHistory(months);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            count == null
                ? l10n.autoCaptureActionFailed
                : l10n.autoCaptureImported(count),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final async = ref.watch(captureSettingsNotifierProvider);
    final notifier = ref.read(captureSettingsNotifierProvider.notifier);
    final state = async.value;

    final List<Widget> children;
    if (state == null) {
      children = [
        if (async.hasError)
          ErrorStateView(
            message: l10n.autoCaptureUnavailable,
            actionLabel: l10n.tryAgain,
            onAction: notifier.refresh,
          )
        else
          PulsingPlaceholder(semanticLabel: l10n.loading),
      ];
    } else if (!state.status.isAndroid) {
      children = _iphone(context, state);
    } else {
      children = _android(context, state, notifier);
    }
    return LargeTitlePage(
      title: Text(l10n.autoCaptureTitle),
      leading: RoundIconButton(
        icon: Icons.arrow_back_rounded,
        tooltip: l10n.back,
        floating: false,
        color: colors.onSurface,
        onPressed: context.pop,
      ),
      children: children,
    );
  }

  List<Widget> _iphone(BuildContext context, CaptureSettingsState state) {
    final l10n = AppLocalizations.of(context);
    final ready = state.iosSetupAt != null;
    final last = state.lastShortcutCaptureAt;
    void open() => unawaited(context.push(Routes.iphoneSetup));
    return [
      Entrance(
        child: CaptureStatusCard(
          on: ready,
          offIcon: Icons.phone_iphone_rounded,
          title: ready ? l10n.iosStatusOn : l10n.iosStatusOff,
          lastCaptureAt: last,
          now: state.now,
        ),
      ),
      Entrance(
        index: 1,
        child: InfoCard(
          title: l10n.autoCaptureIosTitle,
          body: l10n.iosSetupIntro,
          extra: l10n.iosLimitsBody,
          actions: [
            if (ready)
              OutlinedButton(onPressed: open, child: Text(l10n.iosReviewSetup))
            else
              FilledButton(onPressed: open, child: Text(l10n.iosOpenSetup)),
          ],
        ),
      ),
    ];
  }

  List<Widget> _android(
    BuildContext context,
    CaptureSettingsState state,
    CaptureSettingsNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final tiles = CategoryColors.of(context);
    final on = state.status.listenerEnabled;
    final last = state.status.lastCaptureAt;
    final textTheme = Theme.of(context).textTheme;
    var index = 0;
    Widget enter(Widget child) => Entrance(index: index++, child: child);
    return [
      enter(
        CaptureStatusCard(
          on: on,
          offIcon: Icons.power_settings_new_rounded,
          title: on ? l10n.autoCaptureOnTitle : l10n.autoCaptureOffTitle,
          lastCaptureAt: last,
          now: state.now,
        ),
      ),
      enter(
        InfoCard(
          title: l10n.autoCaptureDisclosureTitle,
          body: l10n.autoCaptureDisclosureBody,
          extra: l10n.autoCaptureLimitations,
          actions: [
            if (on)
              OutlinedButton(
                onPressed: () =>
                    unawaited(_report(context, notifier.openAccess)),
                child: Text(l10n.autoCaptureManage),
              )
            else
              FilledButton(
                onPressed: () =>
                    unawaited(_report(context, notifier.openAccess)),
                child: Text(l10n.autoCaptureTurnOn),
              ),
          ],
        ),
      ),
      if (!on)
        enter(
          InfoCard(
            title: l10n.autoCaptureRestrictedTitle,
            body: l10n.autoCaptureRestrictedBody,
            actions: [
              OutlinedButton(
                onPressed: () =>
                    unawaited(_report(context, notifier.openAppInfo)),
                child: Text(l10n.autoCaptureOpenAppInfo),
              ),
            ],
          ),
        ),
      enter(
        InfoCard(
          title: l10n.autoCaptureBatteryTitle,
          body: switch (state.oem) {
            OemFamily.xiaomi => l10n.oemXiaomi,
            OemFamily.vivo => l10n.oemVivo,
            OemFamily.oppo => l10n.oemOppo,
            OemFamily.samsung => l10n.oemSamsung,
            OemFamily.other => l10n.oemOther,
          },
          actions: [
            OutlinedButton(
              onPressed: () =>
                  unawaited(_report(context, notifier.openBattery)),
              child: Text(l10n.autoCaptureBatteryOpen),
            ),
          ],
        ),
      ),
      if (state.sources.isNotEmpty)
        enter(
          AppCard(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: metrics.spaceLg,
              vertical: metrics.spaceSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.only(top: metrics.spaceSm),
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.autoCaptureSourcesTitle,
                      style: textTheme.titleMedium,
                    ),
                  ),
                ),
                for (final (i, source) in state.sources.indexed) ...[
                  if (i > 0) const Divider(),
                  SwitchRow(
                    key: ValueKey(source.package),
                    leading: IconTile(
                      icon: Icons.apps_rounded,
                      color: tiles.blue,
                    ),
                    title: appNameFor(
                      l10n,
                      source.package,
                      defaultSms: state.defaultSms,
                    ),
                    value: source.enabled,
                    onChanged: (enabled) => unawaited(
                      _report(
                        context,
                        () => notifier.setSource(
                          source.package,
                          enabled: enabled,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      if (state.status.smsSupported)
        enter(
          InfoCard(
            title: l10n.autoCaptureSmsTitle,
            body: l10n.autoCaptureSmsBody,
            extra: state.status.smsPermission
                ? l10n.autoCaptureSmsAllowed
                : null,
            actions: [
              if (state.status.smsPermission)
                OutlinedButton(
                  onPressed: () => unawaited(_import(context)),
                  child: Text(l10n.autoCaptureImport),
                )
              else
                OutlinedButton(
                  onPressed: () =>
                      unawaited(_report(context, notifier.requestSms)),
                  child: Text(l10n.autoCaptureSmsAllow),
                ),
            ],
          ),
        ),
    ];
  }
}

/// Picks how far back to import: 1, 3 or 6 months.
class _MonthsSheet extends StatelessWidget {
  const new({required this.title});

  final String title;

  static const List<int> _choices = [1, 3, 6];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    return SheetFrame(
      title: title,
      child: Column(
        children: [
          for (final months in _choices)
            Semantics(
              button: true,
              label: l10n.autoCaptureImportMonths(months),
              onTap: () => Navigator.of(context).pop(months),
              child: ExcludeSemantics(
                child: Pressable(
                  onTap: () => Navigator.of(context).pop(months),
                  shape: const StadiumBorder(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: metrics.minTapTarget,
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: metrics.spaceLg,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l10n.autoCaptureImportMonths(months),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
