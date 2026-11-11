import 'dart:async';

import 'package:expense_tracker/data/sync/sync_controller.dart';
import 'package:expense_tracker/formatting/relative_time.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/services/cloud/cloud_auth.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/theme/app_metrics.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/app_card.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';
import 'package:expense_tracker/widgets/icon_tile.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:expense_tracker/widgets/pulsing_placeholder.dart';
import 'package:expense_tracker/widgets/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings → Account & sync (Phase 9): sign in with an email code, write
/// down or enter the recovery code, and see sync's state.
class AccountScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final async = ref.watch(syncControllerProvider);
    final back = RoundIconButton(
      icon: Icons.arrow_back_rounded,
      tooltip: l10n.back,
      floating: false,
      color: colors.onSurface,
      onPressed: context.pop,
    );
    final status = async.value;
    return LargeTitlePage(
      title: Text(l10n.accountTitle),
      leading: back,
      children: [
        switch (status) {
          null when async.hasError => ErrorStateView(
            message: l10n.failureLoad,
            actionLabel: l10n.tryAgain,
            onAction: () => ref.invalidate(syncControllerProvider),
          ),
          null => PulsingPlaceholder(semanticLabel: l10n.loading),
          SyncSignedOut() => const Entrance(child: _SignIn()),
          SyncNewKey(:final recoveryCode) => Entrance(
            child: _NewKey(code: recoveryCode),
          ),
          SyncNeedsCode() => const Entrance(child: _EnterCode()),
          final SyncOn on => Entrance(child: _Status(status: on)),
        },
      ],
    );
  }
}

String _problemText(AppLocalizations l10n, CloudAuthProblem problem) =>
    switch (problem) {
      CloudAuthProblem.badCode => l10n.accountProblemCode,
      CloudAuthProblem.tooMany => l10n.accountProblemTooMany,
      CloudAuthProblem.offline => l10n.accountProblemOffline,
    };

class _SignIn extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<_SignIn> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _code = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _sent = false;
  bool _busy = false;
  String? _problem;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<CloudAuthProblem?> Function() step) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _problem = null;
    });
    final problem = await step();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _problem = problem == null ? null : _problemText(l10n, problem);
      if (problem == null) _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final controller = ref.read(syncControllerProvider.notifier);
    final problem = _problem;
    return AppCard(
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconTile(
                  icon: Icons.cloud_sync_rounded,
                  color: CategoryColors.of(context).blue,
                ),
                SizedBox(width: metrics.spaceMd),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.accountIntroTitle,
                      style: textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: metrics.spaceSm),
            Text(l10n.accountIntroBody, style: textTheme.bodyMedium),
            SizedBox(height: metrics.spaceLg),
            if (!_sent) ...[
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: l10n.accountEmailLabel),
                validator: (text) =>
                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch((text ?? '').trim())
                    ? null
                    : l10n.accountEmailInvalid,
              ),
              SizedBox(height: metrics.spaceMd),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => unawaited(
                        _run(() => controller.sendCode(_email.text)),
                      ),
                child: Text(l10n.accountSendCode),
              ),
            ] else ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.accountCodeSent(_email.text.trim()),
                  style: textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: metrics.spaceMd),
              TextFormField(
                controller: _code,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: l10n.accountCodeLabel),
              ),
              SizedBox(height: metrics.spaceMd),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => unawaited(
                        _run(() => controller.verify(_email.text, _code.text)),
                      ),
                child: Text(l10n.accountVerify),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _sent = false;
                  _code.clear();
                }),
                child: Text(l10n.accountChangeEmail),
              ),
            ],
            if (problem != null) ...[
              SizedBox(height: metrics.spaceSm),
              Semantics(
                liveRegion: true,
                child: Text(
                  problem,
                  style: textTheme.bodyMedium?.copyWith(color: colors.danger),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const new({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final metrics = AppMetrics.of(context);
    final messenger = ScaffoldMessenger.of(context);
    return Container(
      padding: EdgeInsetsDirectional.all(metrics.spaceMd),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: BorderRadius.circular(metrics.radiusTileLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectableText(code, style: Theme.of(context).textTheme.titleMedium),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code));
                messenger
                  ..clearSnackBars()
                  ..showSnackBar(SnackBar(content: Text(l10n.accountCopied)));
              },
              icon: const Icon(Icons.copy_rounded),
              label: Text(l10n.accountCopy),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewKey extends ConsumerWidget {
  const new({required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.accountNewKeyTitle, style: textTheme.titleMedium),
          ),
          SizedBox(height: metrics.spaceSm),
          Text(l10n.accountNewKeyBody, style: textTheme.bodyMedium),
          SizedBox(height: metrics.spaceMd),
          _CodeBox(code: code),
          SizedBox(height: metrics.spaceMd),
          FilledButton(
            onPressed: ref
                .read(syncControllerProvider.notifier)
                .confirmCodeSaved,
            child: Text(l10n.accountNewKeySaved),
          ),
        ],
      ),
    );
  }
}

class _EnterCode extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_EnterCode> createState() => _EnterCodeState();
}

class _EnterCodeState extends ConsumerState<_EnterCode> {
  final TextEditingController _code = TextEditingController();
  bool _wrong = false;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    setState(() {
      _busy = true;
      _wrong = false;
    });
    final ok = await ref
        .read(syncControllerProvider.notifier)
        .enterCode(_code.text);
    if (mounted) {
      setState(() {
        _busy = false;
        _wrong = !ok;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.accountNeedsCodeTitle,
              style: textTheme.titleMedium,
            ),
          ),
          SizedBox(height: metrics.spaceSm),
          Text(l10n.accountNeedsCodeBody, style: textTheme.bodyMedium),
          SizedBox(height: metrics.spaceMd),
          TextField(
            controller: _code,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: l10n.accountRecoveryLabel,
              errorText: _wrong ? l10n.accountRecoveryWrong : null,
            ),
            onSubmitted: (_) => unawaited(_unlock()),
          ),
          SizedBox(height: metrics.spaceMd),
          FilledButton(
            onPressed: _busy ? null : () => unawaited(_unlock()),
            child: Text(l10n.accountUnlock),
          ),
        ],
      ),
    );
  }
}

class _Status extends ConsumerWidget {
  const new({required this.status});

  final SyncOn status;

  Future<void> _showCode(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ref
        .read(deviceAuthProvider)
        .unlock(l10n.accountShowCodeReason);
    if (!ok || !context.mounted) return;
    final code = await ref.read(syncControllerProvider.notifier).recoveryCode();
    if (code == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountRecoveryLabel),
        content: _CodeBox(code: code),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(syncControllerProvider.notifier).signOut();
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.accountSignedOut)));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountDeleteTitle),
        content: Text(l10n.accountDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.accountDelete),
          ),
        ],
      ),
    );
    // Null means dismissed: keep the account.
    if (sure != true) return;
    final problem = await ref
        .read(syncControllerProvider.notifier)
        .deleteAccount();
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            problem == null ? l10n.accountDeleted : _problemText(l10n, problem),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = AppMetrics.of(context);
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final now = ref.watch(clockProvider).now();
    final last = status.lastSynced;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconTile(
                icon: status.offline
                    ? Icons.cloud_off_rounded
                    : Icons.cloud_done_rounded,
                color: CategoryColors.of(context).green,
              ),
              SizedBox(width: metrics.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.accountSignedInAs(status.email),
                      style: textTheme.titleMedium,
                    ),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        last == null
                            ? l10n.accountNeverSynced
                            : l10n.accountLastSynced(
                                formatTimeAgo(l10n, last, now),
                              ),
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (status.offline) ...[
            SizedBox(height: metrics.spaceSm),
            Text(
              l10n.accountOffline,
              style: textTheme.bodyMedium?.copyWith(color: colors.danger),
            ),
          ],
          SizedBox(height: metrics.spaceLg),
          FilledButton(
            onPressed: () =>
                unawaited(ref.read(syncControllerProvider.notifier).syncNow()),
            child: Text(l10n.accountSyncNow),
          ),
          SizedBox(height: metrics.spaceSm),
          OutlinedButton(
            onPressed: () => unawaited(_showCode(context, ref)),
            child: Text(l10n.accountShowCode),
          ),
          SizedBox(height: metrics.spaceSm),
          TextButton(
            onPressed: () => unawaited(_signOut(context, ref)),
            child: Text(l10n.accountSignOut),
          ),
          TextButton(
            onPressed: () => unawaited(_delete(context, ref)),
            child: Text(
              l10n.accountDelete,
              style: TextStyle(color: colors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
