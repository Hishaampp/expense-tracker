import 'dart:async';

import 'package:expense_tracker/core/app_identity.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/services/web_link_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens [url] in the browser, or says where to find it when no browser
/// could.
Future<void> openWebPage(BuildContext context, WidgetRef ref, Uri url) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final opened = await ref.read(webLinkServiceProvider).open(url);
  if (opened) return;
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(l10n.linkOpenFailed('${url.host}${url.path}'))),
    );
}

/// The terms of use and privacy policy as two links, for the sign-in card.
class LegalLinks extends ConsumerWidget {
  /// Creates the links.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextButton(
          onPressed: () => unawaited(openWebPage(context, ref, termsUrl)),
          child: Text(l10n.settingsTerms),
        ),
        TextButton(
          onPressed: () =>
              unawaited(openWebPage(context, ref, privacyPolicyUrl)),
          child: Text(l10n.settingsPrivacyPolicy),
        ),
      ],
    );
  }
}
