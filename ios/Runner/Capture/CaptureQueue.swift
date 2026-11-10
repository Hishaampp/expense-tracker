import Foundation

/// Append-only queue of raw captures in the App Group container (spec §6.1),
/// shared by the app, the Share Extension and (Phase 4) the App Intent.
/// One JSON object per line. Never logs content. Delivery is at-least-once:
/// the app drains, records, then acks; Dart de-duplicates.
final class CaptureQueue {
  private let fileURL: URL?

  /// Opens the queue in the App Group named in Info.plist (`AppGroupIdentifier`).
  init(bundle: Bundle = .main) {
    let group = bundle.object(forInfoDictionaryKey: "AppGroupIdentifier") as? String
    let container = group.flatMap {
      FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: $0)
    }
    fileURL = container?.appendingPathComponent("capture_queue.jsonl")
  }

  /// Whether the App Group container is available.
  var isAvailable: Bool { fileURL != nil }

  /// Adds a capture to the end of the queue.
  func append(_ capture: [String: Any]) {
    guard let url = fileURL,
          let data = try? JSONSerialization.data(withJSONObject: capture),
          let line = String(data: data, encoding: .utf8)
    else { return }
    coordinate(url) { url in
      let bytes = Data((line + "\n").utf8)
      if FileManager.default.fileExists(atPath: url.path),
         let handle = try? FileHandle(forWritingTo: url) {
        defer { try? handle.close() }
        _ = try? handle.seekToEnd()
        try? handle.write(contentsOf: bytes)
      } else {
        try? bytes.write(to: url, options: .atomic)
      }
    }
  }

  /// Every queued capture as a JSON string, oldest first.
  func readAll() -> [String] {
    guard let url = fileURL else { return [] }
    var lines: [String] = []
    coordinate(url) { url in
      guard let text = try? String(contentsOf: url, encoding: .utf8) else { return }
      lines = text.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }
    return lines
  }

  /// Removes the captures whose ids are in `ids`.
  func remove(ids: Set<String>) {
    guard let url = fileURL else { return }
    coordinate(url) { url in
      guard let text = try? String(contentsOf: url, encoding: .utf8) else { return }
      let keep = text.split(separator: "\n").map(String.init).filter { line in
        guard let data = line.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let id = object["id"] as? String
        else { return false }
        return !ids.contains(id)
      }
      let output = keep.isEmpty ? "" : keep.joined(separator: "\n") + "\n"
      try? Data(output.utf8).write(to: url, options: .atomic)
    }
  }

  // Coordinates access across the app and its extension processes.
  private func coordinate(_ url: URL, _ body: (URL) -> Void) {
    var error: NSError?
    NSFileCoordinator().coordinate(writingItemAt: url, options: [], error: &error) { url in
      body(url)
    }
  }
}
