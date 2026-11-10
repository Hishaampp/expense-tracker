import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/theme/category_colors.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/entrance.dart';
import 'package:expense_tracker/widgets/large_title_page.dart';
import 'package:flutter/material.dart';

/// Rooms. Until Rooms are built (spec Phase 5) this says what they are and
/// that they are coming; it offers no action that does not work yet.
class RoomsScreen extends StatelessWidget {
  /// Creates the Rooms screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LargeTitlePage(
      title: Text(l10n.roomsTitle),
      children: [
        Entrance(
          child: EmptyStateView(
            icon: Icons.luggage_rounded,
            iconColor: CategoryColors.of(context).blue,
            title: l10n.roomsComingTitle,
            body: l10n.roomsComingBody,
          ),
        ),
      ],
    );
  }
}
