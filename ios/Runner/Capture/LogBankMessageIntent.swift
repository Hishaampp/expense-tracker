import AppIntents
import Foundation

/// Receives a bank SMS from a Shortcuts "Message" automation and queues it
/// for the app (spec §6.3). Runs without opening the app and shows nothing,
/// so the automation never interrupts the user. All parsing happens in the
/// app when it next opens.
struct LogBankMessageIntent: AppIntent {
  static var title: LocalizedStringResource = "Log Bank Message"
  static var description = IntentDescription(
    "Adds a bank SMS to the app so the payment is recorded."
  )
  static var openAppWhenRun = false

  @Parameter(title: "Message")
  var message: String

  @Parameter(title: "Sender")
  var sender: String?

  func perform() async throws -> some IntentResult {
    let text = message.trimmingCharacters(in: .whitespacesAndNewlines)
    // Same filter as Android: only text with a rupee amount is kept, so a
    // too-broad automation never stores personal messages.
    if !text.isEmpty, CaptureFilter.hasAmount(text) {
      CaptureQueue().append([
        "id": UUID().uuidString,
        "source": "ios_shortcut",
        "origin": sender ?? NSNull(),
        "title": NSNull(),
        "text": text,
        "receivedAt": Int(Date().timeIntervalSince1970 * 1000),
      ])
    }
    return .result()
  }
}

/// Makes "Log Bank Message" appear in the Shortcuts app automatically.
struct ExpensesShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: LogBankMessageIntent(),
      phrases: ["Log a bank message in \(.applicationName)"],
      shortTitle: "Log Bank Message",
      systemImageName: "indianrupeesign.circle"
    )
  }
}

/// The only parsing native code does: is there a rupee amount at all?
enum CaptureFilter {
  private static let amount = try! NSRegularExpression(
    pattern: #"(?:₹|\bRs\.?|\bINR)\s*\d"#,
    options: [.caseInsensitive]
  )

  static func hasAmount(_ text: String) -> Bool {
    let range = NSRange(text.startIndex..., in: text)
    return amount.firstMatch(in: text, range: range) != nil
  }
}
