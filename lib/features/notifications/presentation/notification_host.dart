import 'dart:async';

import 'package:expense_tracker/core/budget_alerts.dart';
import 'package:expense_tracker/core/local_day.dart';
import 'package:expense_tracker/core/models/money_transaction.dart';
import 'package:expense_tracker/core/models/room.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:expense_tracker/core/money.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/core/room_tagging.dart';
import 'package:expense_tracker/data/budget_providers.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/formatting/money_format.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/routing/app_router.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:expense_tracker/services/notification_service.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Every transaction waiting in the review inbox. Live.
final StreamProvider<List<MoneyTransaction>> _needsReviewProvider =
    StreamProvider.autoDispose<List<MoneyTransaction>>(
      (ref) => ref.watch(autoCaptureRepositoryProvider).watchNeedsReview(),
    );

/// Hour of the Sunday weekly review notification (spec §10).
const int weeklyReviewHour = 19;

/// Sends the app's local notifications (spec §10) and acts on taps:
///
/// * budget alerts, each threshold once, while the app runs;
/// * the Sunday weekly review, scheduled or cancelled with its setting;
/// * "Add to Room?" for a captured payment a suggest-mode Room may want,
///   when it arrives with the app in the background.
///
/// Wraps the app below the localizations; renders [child] unchanged.
class NotificationHost extends ConsumerStatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  ConsumerState<NotificationHost> createState() => _NotificationHostState();
}

class _NotificationHostState extends ConsumerState<NotificationHost> {
  StreamSubscription<NotificationTap>? _taps;
  Set<String>? _seenReview;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final l10n = AppLocalizations.of(context);
    final service = ref.read(notificationServiceProvider);
    _taps = service.taps.listen(_onTap);
    unawaited(
      service
          .init((
            alertsChannel: l10n.notifyAlertsChannel,
            alertsChannelInfo: l10n.notifyAlertsChannelInfo,
            weeklyChannel: l10n.notifyWeeklyChannel,
            weeklyChannelInfo: l10n.notifyWeeklyChannelInfo,
            roomChannel: l10n.notifyRoomChannel,
            roomChannelInfo: l10n.notifyRoomChannelInfo,
            addToRoom: l10n.notifyAddToRoom,
          ))
          .then((_) => _syncWeekly(ref.read(weeklyReviewOnProvider).value)),
    );
  }

  @override
  void dispose() {
    unawaited(_taps?.cancel());
    super.dispose();
  }

  AppLocalizations get _l10n => AppLocalizations.of(context);

  Future<void> _syncWeekly(bool? on) async {
    if (on == null || !mounted) return;
    final service = ref.read(notificationServiceProvider);
    if (on) {
      await service.scheduleWeekly(
        title: _l10n.notifyWeeklyTitle,
        body: _l10n.notifyWeeklyBody,
        payload: _routePayload(Routes.weeklyReview),
        hour: weeklyReviewHour,
      );
    } else {
      await service.cancelWeekly();
    }
  }

  // ---- Budget alerts -------------------------------------------------------

  Future<void> _checkBudgets(BudgetSnapshot snapshot) async {
    final reached = reachedAlerts(
      plan: snapshot.plan,
      summary: snapshot.summary,
      period: snapshot.period,
      rooms: snapshot.rooms,
      roomSpentPaise: snapshot.roomSpentPaise,
    );
    if (reached.isEmpty) return;
    final keys = {for (final a in reached) a.key};
    final fired = await ref.read(budgetRepositoryProvider).markFired(keys);
    if (fired case Ok(:final value) when value.isNotEmpty && mounted) {
      final fresh = reached.where((a) => value.contains(a.key));
      for (final alert in loudest(fresh)) {
        await _showAlert(alert, snapshot);
      }
    }
  }

  Future<void> _showAlert(BudgetAlert alert, BudgetSnapshot snapshot) async {
    final l10n = _l10n;
    String spentOf(Money spent, Money budget) =>
        l10n.notifySpentOf(formatMoney(spent), formatMoney(budget));
    final text = switch (alert.subject) {
      AlertSubject.month => switch (snapshot.plan.monthly) {
        final budget? => (
          alert.isFull ? l10n.notifyMonth100Title : l10n.notifyMonth80Title,
          alert.isFull
              ? spentOf(snapshot.summary.spentForBudget, budget)
              : l10n.notifyMonth80Body(
                  formatMoney(budget - snapshot.summary.spentForBudget),
                ),
          Routes.budgets,
        ),
        null => null,
      },
      AlertSubject.category => switch ((
        snapshot.plan.byCategory[alert.subjectId],
        snapshot.categories.where((c) => c.id == alert.subjectId).firstOrNull,
      )) {
        (final budget?, final category?) => (
          l10n.notifyCategoryTitle(category.name),
          spentOf(
            snapshot.summary.budgetByCategory[category.id] ?? Money.zero,
            budget,
          ),
          Routes.budgets,
        ),
        _ => null,
      },
      AlertSubject.room => switch (snapshot.rooms
          .where((r) => r.id == alert.subjectId)
          .firstOrNull) {
        Room(budget: final budget?, :final id, :final name) => (
          alert.isFull
              ? l10n.notifyRoom100Title(name)
              : l10n.notifyRoom80Title(name),
          spentOf(Money(snapshot.roomSpentPaise[id] ?? 0), budget),
          Routes.room(id),
        ),
        _ => null,
      },
    };
    if (text == null) return;
    await ref
        .read(notificationServiceProvider)
        .showAlert(
          id: _idFor(alert.key),
          title: text.$1,
          body: text.$2,
          payload: _routePayload(text.$3),
        );
  }

  // ---- "Add to Room?" ------------------------------------------------------

  Future<void> _offerRooms(List<MoneyTransaction> inbox) async {
    final seen = _seenReview;
    _seenReview = {for (final t in inbox) t.id};
    // The first list is what was already there: nothing new to offer.
    if (seen == null) return;
    // Only when the app is known to be out of sight: on screen, the review
    // card already offers the Room.
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == null || state == AppLifecycleState.resumed) return;
    final rooms = await ref.read(roomRepositoryProvider).all();
    for (final txn in inbox) {
      if (seen.contains(txn.id)) continue;
      if (txn.kind != TransactionKind.expense || txn.roomId != null) continue;
      final offers = switch (tagRoom(
        day: LocalDay.of(txn.occurredAt),
        rooms: rooms,
      )) {
        RoomSuggestion(:final rooms) || RoomChoice(:final rooms) => rooms,
        _ => const <Room>[],
      };
      if (offers.isEmpty || !mounted) continue;
      await _showRoomOffer(txn, offers.take(2).toList());
    }
  }

  Future<void> _showRoomOffer(MoneyTransaction txn, List<Room> rooms) async {
    final l10n = _l10n;
    final amount = formatMoney(txn.amount);
    final payee = txn.payeeDisplay;
    await ref
        .read(notificationServiceProvider)
        .showRoomOffer(
          id: _idFor('room-offer:${txn.id}'),
          title: payee == null
              ? l10n.notifyRoomOfferTitleNoPayee(amount)
              : l10n.notifyRoomOfferTitle(amount, payee),
          body: rooms.length == 1
              ? l10n.notifyRoomOfferBody(rooms.single.name)
              : l10n.notifyRoomOfferChoiceBody,
          payload: _roomPayload(txn.id, [for (final r in rooms) r.id]),
          buttons: [
            for (final (i, room) in rooms.indexed)
              (id: roomActionId(i), label: l10n.notifyAddTo(room.name)),
          ],
        );
  }

  // ---- Taps ----------------------------------------------------------------

  void _onTap(NotificationTap tap) => unawaited(_handleTap(tap));

  Future<void> _handleTap(NotificationTap tap) async {
    final payload = tap.payload ?? '';
    final router = ref.read(routerProvider);
    if (payload.startsWith(_routePrefix)) {
      final location = payload.substring(_routePrefix.length);
      if (_allowedRoute(location)) unawaited(router.push(location));
      return;
    }
    if (payload.startsWith(_roomPrefix)) {
      final parts = payload.substring(_roomPrefix.length).split('|');
      if (parts.length != 2) return;
      final txnId = parts[0];
      final roomIds = parts[1].split(',');
      final action = tap.actionId;
      for (final (i, roomId) in roomIds.indexed) {
        if (action == roomActionId(i)) {
          final result = await ref
              .read(roomRepositoryProvider)
              .setRoom(txnId, roomId);
          if (result is Ok) unawaited(router.push(Routes.room(roomId)));
          return;
        }
      }
      // The notification itself: the payment waits in Review.
      unawaited(router.push(Routes.review));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(budgetSnapshotProvider, (_, next) {
        if (next case AsyncData(:final value)) {
          unawaited(_checkBudgets(value));
        }
      })
      ..listen(weeklyReviewOnProvider, (previous, next) {
        if (next case AsyncData(:final value) when previous?.value != value) {
          unawaited(_syncWeekly(value));
        }
      })
      ..listen(_needsReviewProvider, (_, next) {
        if (next case AsyncData(:final value)) unawaited(_offerRooms(value));
      });
    return widget.child;
  }
}

const String _routePrefix = 'route:';
const String _roomPrefix = 'room:';

String _routePayload(String location) => '$_routePrefix$location';

String _roomPayload(String txnId, List<String> roomIds) =>
    '$_roomPrefix$txnId|${roomIds.join(',')}';

// Only screens a notification may open; a payload is never trusted to
// navigate anywhere else.
bool _allowedRoute(String location) =>
    location == Routes.budgets ||
    location == Routes.weeklyReview ||
    location == Routes.review ||
    RegExp(r'^/rooms/[\w-]+$').hasMatch(location);

// Notification ids: stable per key, clear of the weekly review's id (1).
int _idFor(String key) => 1000 + (key.hashCode & 0x3fffffff) % 1000000000;
