import 'dart:async';

import 'package:clock/clock.dart';
import 'package:expense_tracker/services/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// A button on a notification: its id comes back in the tap.
typedef NotificationButton = ({String id, String label});

/// What the user tapped: the notification's payload and, for a button,
/// that button's id.
typedef NotificationTap = ({String? payload, String? actionId});

/// Localized names the system shows: channel names in Android settings
/// and the iPhone's "Add to Room" button.
typedef NotificationLabels = ({
  String alertsChannel,
  String alertsChannelInfo,
  String weeklyChannel,
  String weeklyChannelInfo,
  String roomChannel,
  String roomChannelInfo,
  String addToRoom,
});

/// The device's local notifications (spec §10). Every text is passed in
/// already localized. No notification ever carries raw message text.
abstract interface class NotificationService {
  /// Sets up the channels with [labels]. Until it is called, nothing is
  /// shown. Safe to call more than once; the first call wins.
  Future<void> init(NotificationLabels labels);

  /// Taps on notifications while the app runs, and the tap that opened it.
  Stream<NotificationTap> get taps;

  /// Asks the user to allow notifications. Returns whether allowed.
  Future<bool> requestPermission();

  /// Shows a budget alert now.
  Future<void> showAlert({
    required int id,
    required String title,
    required String body,
    required String payload,
  });

  /// Shows a captured payment with up to two "Add to Room" [buttons]
  /// (one on iPhone, labelled by the category set up in [init]). Hidden
  /// on a locked screen.
  Future<void> showRoomOffer({
    required int id,
    required String title,
    required String body,
    required String payload,
    required List<NotificationButton> buttons,
  });

  /// Schedules the weekly review every Sunday at [hour], replacing any
  /// earlier schedule.
  Future<void> scheduleWeekly({
    required String title,
    required String body,
    required String payload,
    required int hour,
  });

  /// Cancels the weekly review.
  Future<void> cancelWeekly();
}

/// [NotificationService] over `flutter_local_notifications`. Failures are
/// logged and swallowed: a missing alert must never break the app.
class LocalNotificationService implements NotificationService {
  /// Creates the service.
  new(this._log, [this._clock = const Clock()]);

  final AppLogger _log;
  final Clock _clock;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<NotificationTap> _taps =
      StreamController<NotificationTap>.broadcast();
  Future<void>? _ready;

  static const int _weeklyId = 1;
  static const String _roomCategory = 'room_offer';

  NotificationLabels? _labels;

  @override
  Stream<NotificationTap> get taps => _taps.stream;

  @override
  Future<void> init(NotificationLabels labels) {
    _labels ??= labels;
    return _ready ??= _init(labels);
  }

  // Null until init: callers skip quietly.
  Future<NotificationLabels?> _whenReady() async {
    await _ready;
    return _labels;
  }

  Future<void> _init(NotificationLabels labels) async {
    await _guard('notify.init', () async {
      await _plugin.initialize(
        settings: InitializationSettings(
          android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            // Asked at a moment that explains why, not at launch.
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            notificationCategories: [
              DarwinNotificationCategory(
                _roomCategory,
                actions: [
                  DarwinNotificationAction.plain(
                    roomActionId(0),
                    labels.addToRoom,
                    options: {DarwinNotificationActionOption.foreground},
                  ),
                ],
              ),
            ],
          ),
        ),
        onDidReceiveNotificationResponse: (response) =>
            _taps.add((payload: response.payload, actionId: response.actionId)),
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      final response = launch?.notificationResponse;
      if ((launch?.didNotificationLaunchApp ?? false) && response != null) {
        // After the listeners below the app have subscribed.
        scheduleMicrotask(
          () => _taps.add((
            payload: response.payload,
            actionId: response.actionId,
          )),
        );
      }
    });
  }

  @override
  Future<bool> requestPermission() async {
    if (await _whenReady() == null) return false;
    var allowed = false;
    await _guard('notify.permission', () async {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      allowed =
          await android?.requestNotificationsPermission() ??
          await ios?.requestPermissions(alert: true, sound: true) ??
          false;
    });
    return allowed;
  }

  @override
  Future<void> showAlert({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final labels = await _whenReady();
    if (labels == null) return;
    await _guard(
      'notify.alert',
      () => _plugin.show(
        id: id,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'budget_alerts',
            labels.alertsChannel,
            channelDescription: labels.alertsChannelInfo,
            importance: Importance.high,
            priority: Priority.high,
            visibility: NotificationVisibility.private,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      ),
    );
  }

  @override
  Future<void> showRoomOffer({
    required int id,
    required String title,
    required String body,
    required String payload,
    required List<NotificationButton> buttons,
  }) async {
    final labels = await _whenReady();
    if (labels == null) return;
    await _guard(
      'notify.room_offer',
      () => _plugin.show(
        id: id,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'room_offers',
            labels.roomChannel,
            channelDescription: labels.roomChannelInfo,
            visibility: NotificationVisibility.private,
            actions: [
              for (final button in buttons.take(2))
                AndroidNotificationAction(
                  button.id,
                  button.label,
                  showsUserInterface: true,
                ),
            ],
          ),
          iOS: const DarwinNotificationDetails(
            categoryIdentifier: _roomCategory,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> scheduleWeekly({
    required String title,
    required String body,
    required String payload,
    required int hour,
  }) async {
    final labels = await _whenReady();
    if (labels == null) return;
    await _guard('notify.weekly', () async {
      await _plugin.cancel(id: _weeklyId);
      // Scheduled in UTC so no time-zone database is needed. India has no
      // daylight saving; elsewhere the review can drift by an hour.
      final next = nextSundayAt(_clock.now(), hour).toUtc();
      await _plugin.zonedSchedule(
        id: _weeklyId,
        title: title,
        body: body,
        payload: payload,
        scheduledDate: tz.TZDateTime.from(next, tz.UTC),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_review',
            labels.weeklyChannel,
            channelDescription: labels.weeklyChannelInfo,
            visibility: NotificationVisibility.private,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        // Inexact: no exact-alarm permission is needed.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    });
  }

  @override
  Future<void> cancelWeekly() async {
    if (await _whenReady() == null) return;
    await _guard('notify.weekly_cancel', () => _plugin.cancel(id: _weeklyId));
  }

  Future<void> _guard(String event, Future<void> Function() action) async {
    try {
      await action();
    } on PlatformException catch (e, st) {
      _log.error(event, e.runtimeType, st);
    } on MissingPluginException catch (e, st) {
      _log.error(event, e.runtimeType, st);
    }
  }
}

/// The action id of the [index]th "Add to Room" button.
String roomActionId(int index) => 'room_$index';

/// The next Sunday at [hour]:00 local time after [now] (today, if it is
/// Sunday before that hour).
DateTime nextSundayAt(DateTime now, int hour) {
  final local = now.toLocal();
  var day = DateTime(local.year, local.month, local.day, hour);
  final daysToSunday = (DateTime.sunday - local.weekday) % 7;
  day = DateTime(day.year, day.month, day.day + daysToSunday, hour);
  if (!day.isAfter(local)) {
    day = DateTime(day.year, day.month, day.day + 7, hour);
  }
  return day;
}
