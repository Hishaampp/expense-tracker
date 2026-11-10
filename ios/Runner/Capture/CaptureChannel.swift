import Flutter
import UIKit

/// The bridge between the native capture queue and Dart (spec §6.1):
/// MethodChannel `app/capture` and EventChannel `app/capture/events`.
/// Native code only queues raw text; all parsing happens in Dart.
final class CaptureChannel: NSObject, FlutterStreamHandler {
  private let queue = CaptureQueue()
  private var sink: FlutterEventSink?

  init(messenger: FlutterBinaryMessenger) {
    super.init()
    FlutterMethodChannel(name: "app/capture", binaryMessenger: messenger)
      .setMethodCallHandler { [weak self] call, result in
        self?.handle(call, result: result)
      }
    FlutterEventChannel(name: "app/capture/events", binaryMessenger: messenger)
      .setStreamHandler(self)
    // The Share Extension writes while the app is in the background; tell
    // Dart to drain when the app comes back.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }

  private func handle(_ call: FlutterMethodCall, result: FlutterResult) {
    switch call.method {
    case "drainQueue":
      result(queue.readAll())
    case "ack":
      let ids = (call.arguments as? [String: Any])?["ids"] as? [String] ?? []
      queue.remove(ids: Set(ids))
      result(nil)
    case "status":
      result([
        "platform": "ios",
        "queueSize": queue.readAll().count,
        "appGroupAvailable": queue.isAvailable,
      ])
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  @objc private func didBecomeActive() {
    sink?("active")
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }
}
