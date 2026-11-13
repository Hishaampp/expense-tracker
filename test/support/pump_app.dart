import 'dart:async';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/data/backup/backup_codec.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/data/query_providers.dart';
import 'package:expense_tracker/data/sync/sync_controller.dart';
import 'package:expense_tracker/data/sync/sync_crypto.dart';
import 'package:expense_tracker/data/sync/sync_engine.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/keypad.dart';
import 'package:expense_tracker/routing/floating_tab_bar.dart';
import 'package:expense_tracker/services/app_link_source.dart';
import 'package:expense_tracker/services/clipboard_service.dart';
import 'package:expense_tracker/services/cloud/cloud_auth.dart';
import 'package:expense_tracker/services/cloud/sync_key_store.dart';
import 'package:expense_tracker/services/device_auth.dart';
import 'package:expense_tracker/services/file_share.dart';
import 'package:expense_tracker/services/haptics.dart';
import 'package:expense_tracker/services/native/capture_control_service.dart';
import 'package:expense_tracker/services/native/capture_queue_service.dart';
import 'package:expense_tracker/services/notification_service.dart';
import 'package:expense_tracker/services/service_providers.dart';
import 'package:expense_tracker/services/upi_pay_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

/// The "now" every app test runs at: Tuesday 10 November 2026, 2:30 pm.
final DateTime testNow = DateTime(2026, 11, 10, 14, 30);

/// Counts haptic events instead of vibrating.
final class FakeHaptics implements Haptics {
  /// Events fired so far, in order.
  final List<String> events = [];

  @override
  void commit() => events.add('commit');

  @override
  void reject() => events.add('reject');

  @override
  void select() => events.add('select');
}

/// A widget test of the whole app. After [body] it unmounts the app and
/// lets the database's stream-cleanup timers run, which the test binding
/// requires before it will pass.
void appTest(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    try {
      await body(tester);
    } finally {
      // Also on failure: a mounted app would leave the database's close
      // waiting on live queries, and the run would hang.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    }
  });
}

/// Records notifications instead of showing them.
final class FakeNotifications implements NotificationService {
  /// Whether the user allows notifications when asked.
  bool allow = true;

  /// What was shown or scheduled, in order, as `kind:title`.
  final List<String> shown = [];

  /// The weekly review's state: `on` or `off`, or null if never set.
  String? weekly;

  /// The payloads shown, by title.
  final Map<String, String> payloads = {};

  /// The buttons of each Room offer, by title.
  final Map<String, List<NotificationButton>> buttons = {};

  final StreamController<NotificationTap> _taps =
      StreamController<NotificationTap>.broadcast();

  /// Simulates the user tapping a notification or one of its buttons.
  void tap(String title, {String? actionId}) =>
      _taps.add((payload: payloads[title], actionId: actionId));

  @override
  Stream<NotificationTap> get taps => _taps.stream;

  @override
  Future<void> init(NotificationLabels labels) async {}

  @override
  Future<bool> requestPermission() async => allow;

  @override
  Future<void> showAlert({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    shown.add('alert:$title');
    payloads[title] = payload;
  }

  @override
  Future<void> showRoomOffer({
    required int id,
    required String title,
    required String body,
    required String payload,
    required List<NotificationButton> buttons,
  }) async {
    shown.add('room:$title');
    payloads[title] = payload;
    this.buttons[title] = buttons;
  }

  @override
  Future<void> scheduleWeekly({
    required String title,
    required String body,
    required String payload,
    required int hour,
  }) async => weekly = 'on';

  @override
  Future<void> cancelWeekly() async => weekly = 'off';
}

/// The phone lock, faked: [allow] decides each unlock.
final class FakeDeviceAuth implements DeviceAuth {
  /// Whether the phone has a lock.
  bool available = true;

  /// Whether the next unlock succeeds.
  bool allow = true;

  /// How many times an unlock was asked for.
  int asked = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> unlock(String reason) async {
    asked++;
    return allow;
  }
}

/// The share sheet and picker, faked.
final class FakeFileShare implements FileShare {
  /// Files shared, by name.
  final Map<String, Uint8List> shared = {};

  /// What the next pick returns.
  Uint8List? toPick;

  @override
  Future<bool> share({
    required String name,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    shared[name] = bytes;
    return true;
  }

  @override
  Future<Uint8List?> pick() async => toPick;
}

/// UPI apps, faked: [opens] says whether opening one works.
final class FakeUpiPayService implements UpiPayService {
  /// Installed apps.
  List<UpiApp> installed = const [(id: 'gpay', name: 'Google Pay')];

  /// Whether opening an app works.
  bool opens = true;

  /// The apps opened, in order.
  final List<String> opened = [];

  @override
  Future<List<UpiApp>> apps() async => installed;

  @override
  Future<bool> open(UpiApp app) async {
    opened.add(app.id);
    return opens;
  }
}

/// Links that open the app, faked: [send] delivers one.
final class FakeAppLinkSource implements AppLinkSource {
  final StreamController<Uri> _links = StreamController<Uri>.broadcast();

  /// The link the app was launched with.
  Uri? launchedWith;

  /// Delivers [uri] as if tapped while the app runs.
  void send(Uri uri) => _links.add(uri);

  @override
  Future<Uri?> initial() async => launchedWith;

  @override
  Stream<Uri> get links => _links.stream;
}

/// The account, faked: any email, the code `123456`.
final class FakeCloudAuth implements CloudAuth {
  /// Creates it, signed in as [signedIn] if given.
  new([this.signedIn]);

  /// The signed-in email.
  String? signedIn;

  /// Whether deleteAccount was called.
  bool deleted = false;

  final StreamController<String?> _email =
      StreamController<String?>.broadcast();

  @override
  Stream<String?> get email => _email.stream;

  @override
  String? get currentEmail => signedIn;

  @override
  Future<CloudAuthProblem?> sendCode(String address) async => null;

  @override
  Future<CloudAuthProblem?> verify(String address, String code) async {
    if (code != '123456') return CloudAuthProblem.badCode;
    signedIn = address;
    _email.add(address);
    return null;
  }

  /// Providers the fake project has turned on.
  Set<CloudProvider> enabled = {};

  /// The provider last opened.
  CloudProvider? opened;

  @override
  Future<Set<CloudProvider>> providers() async => enabled;

  @override
  Future<CloudAuthProblem?> signInWith(CloudProvider provider) async {
    opened = provider;
    return null;
  }

  /// Signs in as if the user tapped the email link.
  void signInByLink(String address) {
    signedIn = address;
    _email.add(address);
  }

  @override
  Future<void> signOut() async => signedIn = null;

  @override
  Future<CloudAuthProblem?> deleteAccount() async {
    deleted = true;
    signedIn = null;
    return null;
  }
}

/// The sync key store, in memory.
final class FakeSyncKeyStore implements SyncKeyStore {
  /// The key kept.
  SyncKey? key;

  @override
  Future<SyncKey?> read() async => key;

  @override
  Future<void> write(SyncKey value) async => key = value;

  @override
  Future<void> delete() async => key = null;
}

/// A clipboard holding [text].
final class FakeClipboard implements ClipboardService {
  /// Creates the clipboard.
  new([this.text]);

  /// What a paste reads.
  String? text;

  @override
  Future<String?> readText() async => text;
}

/// A native capture queue held in memory.
final class FakeCaptureQueue implements CaptureQueueService {
  /// Creates the queue holding [items].
  new([List<RawCapture>? items]) : items = [...?items];

  /// What is waiting.
  final List<RawCapture> items;

  /// Ids acked so far.
  final List<String> acked = [];

  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Simulates a share arriving while the app is open.
  void arrive(RawCapture capture) {
    items.add(capture);
    _changes.add(null);
  }

  @override
  Future<List<RawCapture>> drain() async => [...items];

  @override
  Future<void> ack(List<String> ids) async {
    acked.addAll(ids);
    items.removeWhere((c) => ids.contains(c.id));
  }

  @override
  Stream<void> get changes => _changes.stream;
}

/// The native auto-capture controls, faked.
final class FakeCaptureControl implements CaptureControlService {
  /// Creates the fake with the given status.
  new({
    this.platform = 'android',
    this.listenerEnabled = false,
    this.smsSupported = false,
    this.smsPermission = false,
    this.manufacturer = 'Xiaomi',
  });

  /// `android` or `ios`.
  String platform;

  /// Whether notification access is on.
  bool listenerEnabled;

  /// Whether this build reads SMS.
  bool smsSupported;

  /// Whether SMS access is granted.
  bool smsPermission;

  /// The phone maker.
  String manufacturer;

  /// Calls made, in order.
  final List<String> calls = [];

  /// The allowlist.
  List<String> allowed = [
    'com.google.android.apps.messaging',
    'com.phonepe.app',
  ];

  @override
  Future<CaptureStatus> status() async => CaptureStatus(
    platform: platform,
    listenerEnabled: listenerEnabled,
    smsSupported: smsSupported,
    smsPermission: smsPermission,
    queueSize: 0,
    manufacturer: manufacturer,
  );

  @override
  Future<CaptureSourceList> sources() async => (
    allowed: allowed,
    defaults: const [
      'com.google.android.apps.messaging',
      'com.phonepe.app',
      'net.one97.paytm',
    ],
    defaultSms: null,
  );

  @override
  Future<void> setSources(List<String> packages) async {
    calls.add('setSources:${packages.join(',')}');
    allowed = packages;
  }

  @override
  Future<void> openCaptureSettings() async => calls.add('openCaptureSettings');

  @override
  Future<void> openBatterySettings() async => calls.add('openBatterySettings');

  @override
  Future<void> openAppSettings() async => calls.add('openAppSettings');

  @override
  Future<void> requestSmsPermission() async => calls.add('requestSms');

  @override
  Future<int> importSmsHistory(int months) async {
    calls.add('import:$months');
    return 12;
  }
}

/// Pumps the whole app over a fresh in-memory database and a fixed clock.
/// Returns the database so a test can seed or inspect it.
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  FakeHaptics? haptics,
  FakeClipboard? clipboard,
  FakeCaptureQueue? captureQueue,
  FakeCaptureControl? captureControl,
  FakeNotifications? notifications,
  bool onboarded = true,
  bool appLock = false,
  FakeDeviceAuth? deviceAuth,
  FakeFileShare? fileShare,
  FakeCloudAuth? cloudAuth,
  FakeAppLinkSource? appLinks,
  FakeUpiPayService? upi,
  FakeSyncKeyStore? syncKeys,
  MemorySyncServer? syncServer,
  Size? size,
  double textScale = 1,
}) async {
  final clock = Clock.fixed(testNow);
  final db = openTestDatabase(clock: clock);
  // A typical phone unless a test asks for another size.
  tester.view
    ..physicalSize = size ?? const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        hapticsProvider.overrideWithValue(haptics ?? FakeHaptics()),
        clipboardProvider.overrideWithValue(clipboard ?? FakeClipboard()),
        captureQueueProvider.overrideWithValue(
          captureQueue ?? FakeCaptureQueue(),
        ),
        captureControlProvider.overrideWithValue(
          captureControl ?? FakeCaptureControl(),
        ),
        notificationServiceProvider.overrideWithValue(
          notifications ?? FakeNotifications(),
        ),
        initialOnboardedProvider.overrideWithValue(onboarded),
        initialAppLockProvider.overrideWithValue(appLock),
        deviceAuthProvider.overrideWithValue(deviceAuth ?? FakeDeviceAuth()),
        fileShareProvider.overrideWithValue(fileShare ?? FakeFileShare()),
        cloudAuthProvider.overrideWithValue(cloudAuth ?? FakeCloudAuth()),
        upiPayServiceProvider.overrideWithValue(upi ?? FakeUpiPayService()),
        appLinkSourceProvider.overrideWithValue(
          appLinks ?? FakeAppLinkSource(),
        ),
        syncKeyStoreProvider.overrideWithValue(syncKeys ?? FakeSyncKeyStore()),
        syncServerProvider.overrideWithValue(syncServer ?? MemorySyncServer()),
        // Fast key stretching: the real 600,000 rounds take seconds.
        backupCodecProvider.overrideWith(
          (ref) =>
              BackupCodec(ref.watch(appDatabaseProvider), iterations: 1000),
        ),
      ],
      child: const App(),
    ),
  );
  addTearDown(db.close);
  await tester.pumpAndSettle();
  return db;
}

/// Types [amount] on the Quick Add keypad, for example `240` or `12.5`.
Future<void> typeAmount(WidgetTester tester, String amount) async {
  for (final key in amount.split('')) {
    final button = find.descendant(
      of: find.byType(Keypad),
      matching: find.text(key),
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

/// Taps the tab labelled [label] in the floating tab bar.
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(FloatingTabBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens Quick Add, types [amount] and taps [category] to save it.
Future<void> addExpense(
  WidgetTester tester,
  String amount,
  String category,
) async {
  await tester.tap(find.byTooltip('Add expense').first);
  await tester.pumpAndSettle();
  await typeAmount(tester, amount);
  final tile = find.text(category);
  await tester.ensureVisible(tile);
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

/// Scrolls [finder] to the middle of its list, clear of the pinned header,
/// so a tap lands on it.
Future<void> bringIntoView(WidgetTester tester, Finder finder) async {
  // The list on screen, not one in a hidden tab underneath.
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).hitTestable().first,
  );
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
}
