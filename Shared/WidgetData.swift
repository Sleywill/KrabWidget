import Foundation
import WidgetKit

// MARK: - Widget Data shared between App and Widget Extension

/// Data model shared between the Krab app and its widget extension via App Groups.
///
/// Encoded into `UserDefaults(suiteName:)` so both targets can read the
/// same state without an IPC round-trip.
struct WidgetData: Codable {
    /// The most recently received message from the AI assistant, if any.
    let lastMessage: String?
    /// Total number of messages exchanged in the current session.
    let messageCount: Int
    /// Whether the app is currently connected to the AI backend.
    let isConnected: Bool
    /// Timestamp of the last data update; used by the widget timeline.
    let lastUpdate: Date
    /// Current mood of the Krab mascot, reflected in the widget UI.
    let crabMood: CrabMood

    /// Placeholder shown while the widget is loading or in preview mode.
    static let placeholder = WidgetData(
        lastMessage: "Hello! I'm Krab",
        messageCount: 0,
        isConnected: false,
        lastUpdate: Date(),
        crabMood: .happy
    )

    /// Default state used when there is no active connection.
    static let disconnected = WidgetData(
        lastMessage: nil,
        messageCount: 0,
        isConnected: false,
        lastUpdate: Date(),
        crabMood: .sleeping
    )
}

/// The emotional state of the Krab AI mascot.
///
/// Each case maps to a distinct emoji and short status string displayed
/// in both the widget and the main app UI.
enum CrabMood: String, Codable {
    /// Default idle state — ready to accept a new query.
    case happy = "happy"
    /// The assistant is formulating a response.
    case thinking = "thinking"
    /// No active connection; prompts the user to connect.
    case sleeping = "sleeping"
    /// A new message just arrived.
    case excited = "excited"
    /// A background task (e.g. indexing) is running.
    case working = "working"

    /// Visual representation used in the widget and app UI.
    var emoji: String {
        switch self {
        case .happy:    return "🦀"
        case .thinking: return "🤔"
        case .sleeping: return "😴"
        case .excited:  return "✨"
        case .working:  return "⚙️"
        }
    }

    /// Short human-readable status string shown below the emoji.
    var statusText: String {
        switch self {
        case .happy:    return "Ready to help!"
        case .thinking: return "Thinking..."
        case .sleeping: return "Connect me!"
        case .excited:  return "New message!"
        case .working:  return "Processing..."
        }
    }
}

// MARK: - App Group Storage

/// Persists WidgetData in a shared App Group container so the widget
/// extension can read it without launching the main app.
///
/// Call save(_:) from the app whenever state changes; the widget timeline
/// is automatically reloaded via WidgetCenter.
class WidgetDataStore {
    /// Singleton instance.
    static let shared = WidgetDataStore()

    private let suiteName = "group.com.openclaw.krabwidget"
    private let dataKey   = "widgetData"

    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    /// Persists data to the shared container and triggers a widget reload.
    ///
    /// - Parameter data: The latest widget state to persist.
    func save(_ data: WidgetData) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        userDefaults?.set(encoded, forKey: dataKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Loads the most recently saved WidgetData, or .disconnected if none exists.
    ///
    /// - Returns: The last persisted WidgetData, or a sensible default.
    func load() -> WidgetData {
        guard let data    = userDefaults?.data(forKey: dataKey),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return .disconnected
        }
        return decoded
    }

    /// Derives and saves WidgetData from the live OpenClawConnection state.
    ///
    /// This is the primary update path: call it from the app whenever the
    /// connection state or message list changes.
    ///
    /// - Parameter connection: The current OpenClawConnection observed object.
    @MainActor
    func updateFromConnection(_ connection: OpenClawConnection) {
        let mood: CrabMood
        switch connection.connectionStatus {
        case .connected:
            mood = connection.messages.isEmpty ? .happy : .excited
        case .connecting:
            mood = .working
        case .disconnected, .error:
            mood = .sleeping
        }

        let data = WidgetData(
            lastMessage:  connection.messages.last?.content,
            messageCount: connection.messages.count,
            isConnected:  connection.connectionStatus == .connected,
            lastUpdate:   Date(),
            crabMood:     mood
        )
        save(data)
    }
}
