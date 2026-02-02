import Foundation
import WidgetKit

// MARK: - Widget Data shared between App and Widget Extension

struct WidgetData: Codable {
    let lastMessage: String?
    let messageCount: Int
    let isConnected: Bool
    let lastUpdate: Date
    let crabMood: CrabMood
    
    static let placeholder = WidgetData(
        lastMessage: "Hello! I'm Krab 🦀",
        messageCount: 0,
        isConnected: false,
        lastUpdate: Date(),
        crabMood: .happy
    )
    
    static let disconnected = WidgetData(
        lastMessage: nil,
        messageCount: 0,
        isConnected: false,
        lastUpdate: Date(),
        crabMood: .sleeping
    )
}

enum CrabMood: String, Codable {
    case happy = "happy"
    case thinking = "thinking"
    case sleeping = "sleeping"
    case excited = "excited"
    case working = "working"
    
    var emoji: String {
        switch self {
        case .happy: return "🦀"
        case .thinking: return "🤔"
        case .sleeping: return "😴"
        case .excited: return "✨"
        case .working: return "⚙️"
        }
    }
    
    var statusText: String {
        switch self {
        case .happy: return "Ready to help!"
        case .thinking: return "Thinking..."
        case .sleeping: return "Connect me!"
        case .excited: return "New message!"
        case .working: return "Processing..."
        }
    }
}

// MARK: - App Group Storage
class WidgetDataStore {
    static let shared = WidgetDataStore()
    
    private let suiteName = "group.com.openclaw.krabwidget"
    private let dataKey = "widgetData"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    func save(_ data: WidgetData) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        userDefaults?.set(encoded, forKey: dataKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func load() -> WidgetData {
        guard let data = userDefaults?.data(forKey: dataKey),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return .disconnected
        }
        return decoded
    }
    
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
            lastMessage: connection.messages.last?.content,
            messageCount: connection.messages.count,
            isConnected: connection.connectionStatus == .connected,
            lastUpdate: Date(),
            crabMood: mood
        )
        save(data)
    }
}
