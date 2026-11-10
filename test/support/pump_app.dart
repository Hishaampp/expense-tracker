import 'dart:async';

import 'package:clock/clock.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/core/models/raw_capture.dart';
import 'package:expense_tracker/data/data_providers.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:expense_tracker/features/quick_add/presentation/widgets/keypad.dart';
import 'package:expense_tracker/routing/floating_tab_bar.dart';
import 'package:expense_tracker/services/clipboard_service.dart';
import 'package:expense_tracker/services/haptics.dart';
import 'package:expense_tracker/services/native/capture_control_service.dart';
import 'package:expense_tracker/services/native/capture_queue_service.dart';
import 'package:expense_tracker/services/service_providers.dart';
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
  FakeCaptureControl({
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
