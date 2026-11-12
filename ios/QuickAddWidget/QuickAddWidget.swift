import AppIntents
import SwiftUI
import WidgetKit

// Opens the app on Add (handled by QuickAddLinkHost in Dart).
private let addURL = URL(string: "expensetracker://add")!

private struct QuickAddEntry: TimelineEntry {
  let date: Date
}

// The widget never changes, so one entry is enough.
private struct QuickAddProvider: TimelineProvider {
  func placeholder(in context: Context) -> QuickAddEntry {
    QuickAddEntry(date: .now)
  }

  func getSnapshot(in context: Context, completion: @escaping (QuickAddEntry) -> Void) {
    completion(QuickAddEntry(date: .now))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<QuickAddEntry>) -> Void) {
    completion(Timeline(entries: [QuickAddEntry(date: .now)], policy: .never))
  }
}

private struct QuickAddView: View {
  @Environment(\.widgetFamily) private var family

  var body: some View {
    switch family {
    case .accessoryCircular:
      ZStack {
        AccessoryWidgetBackground()
        Image(systemName: "indianrupeesign")
          .font(.title2.weight(.semibold))
      }
      .accessibilityLabel("Add expense")
    case .accessoryRectangular:
      HStack(spacing: 8) {
        Image(systemName: "indianrupeesign.circle.fill")
          .font(.title2)
        VStack(alignment: .leading, spacing: 2) {
          Text("Add expense")
            .font(.headline)
          Text("Tap after you pay")
            .font(.caption)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    case .accessoryInline:
      Label("Add expense", systemImage: "indianrupeesign.circle")
    default:
      VStack(alignment: .leading, spacing: 6) {
        Image(systemName: "indianrupeesign.circle.fill")
          .font(.largeTitle)
          .foregroundStyle(.tint)
        Spacer()
        Text("Add expense")
          .font(.headline)
        Text("Tap after you pay")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
  }
}

struct QuickAddWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "QuickAddWidget", provider: QuickAddProvider()) { _ in
      QuickAddView()
        .widgetURL(addURL)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Add expense")
    .description("Opens Add straight from your Lock Screen or Home Screen.")
    .supportedFamilies([
      .accessoryCircular, .accessoryRectangular, .accessoryInline, .systemSmall,
    ])
  }
}

// iOS 18: a button for Control Centre and the Lock Screen's bottom corners.
@available(iOS 18.0, *)
struct OpenAddIntent: AppIntent {
  static let title: LocalizedStringResource = "Add expense"

  func perform() async throws -> some IntentResult & OpensIntent {
    .result(opensIntent: OpenURLIntent(addURL))
  }
}

@available(iOS 18.0, *)
struct QuickAddControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "QuickAddControl") {
      ControlWidgetButton(action: OpenAddIntent()) {
        Label("Add expense", systemImage: "indianrupeesign.circle")
      }
    }
    .displayName("Add expense")
  }
}

@main
struct QuickAddWidgets: WidgetBundle {
  var body: some Widget {
    QuickAddWidget()
    if #available(iOS 18.0, *) {
      QuickAddControl()
    }
  }
}
