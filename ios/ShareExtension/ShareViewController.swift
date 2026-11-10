import UIKit
import UniformTypeIdentifiers

/// Receives text shared from another app (a bank SMS, a UPI receipt), adds
/// it to the capture queue in the App Group, and closes. The app reads the
/// queue the next time it opens and finishes the entry there (spec §6.4).
final class ShareViewController: UIViewController {
  private let queue = CaptureQueue()
  private let label = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    label.textAlignment = .center
    label.font = .preferredFont(forTextStyle: .headline)
    label.adjustsFontForContentSizeCategory = true
    view.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
    ])
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Task { await receive() }
  }

  private func receive() async {
    let text = await sharedText()
    if let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      queue.append([
        "id": UUID().uuidString,
        "source": "share",
        "origin": NSNull(),
        "title": NSNull(),
        "text": text,
        "receivedAt": Int(Date().timeIntervalSince1970 * 1000),
      ])
      show(NSLocalizedString(
        "Saved. Open the app to finish adding it.",
        comment: "Share extension: text queued"))
    } else {
      show(NSLocalizedString(
        "There's no text to add.",
        comment: "Share extension: nothing usable shared"))
    }
    try? await Task.sleep(nanoseconds: 1_200_000_000)
    extensionContext?.completeRequest(returningItems: nil)
  }

  private func show(_ message: String) {
    label.text = message
    UIAccessibility.post(notification: .announcement, argument: message)
  }

  private func sharedText() async -> String? {
    let items = extensionContext?.inputItems as? [NSExtensionItem] ?? []
    for item in items {
      for provider in item.attachments ?? [] {
        if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
           let text = try? await provider.loadItem(
             forTypeIdentifier: UTType.plainText.identifier) as? String {
          return text
        }
      }
      if let text = item.attributedContentText?.string, !text.isEmpty {
        return text
      }
    }
    return nil
  }
}
