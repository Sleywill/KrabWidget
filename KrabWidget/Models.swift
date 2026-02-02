import Foundation
import SwiftUI

// MARK: - Chat Message
struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let sender: MessageSender
    let timestamp: Date
    var isRead: Bool
    
    init(id: UUID = UUID(), content: String, sender: MessageSender, timestamp: Date = Date(), isRead: Bool = false) {
        self.id = id
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
        self.isRead = isRead
    }
}

enum MessageSender: String, Codable {
    case user
    case krab
    case telegram
    
    var displayName: String {
        switch self {
        case .user: return "You"
        case .krab: return "🦀 Krab"
        case .telegram: return "📱 Telegram"
        }
    }
    
    var bubbleColor: Color {
        switch self {
        case .user: return Color(red: 0.3, green: 0.5, blue: 0.8)
        case .krab: return Color(red: 0.9, green: 0.4, blue: 0.3)
        case .telegram: return Color(red: 0.2, green: 0.6, blue: 0.8)
        }
    }
}

// MARK: - Voice Pack
struct VoicePack: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let personality: VoicePersonality
    let voiceIdentifier: String
    let pitch: Float
    let rate: Float
    let volume: Float
    let description: String
    
    static let available: [VoicePack] = [
        VoicePack(
            id: "meme_krab",
            name: "Meme Krab",
            personality: .meme,
            voiceIdentifier: "com.apple.voice.compact.en-US.Samantha",
            pitch: 1.25,
            rate: 0.55,
            volume: 1.0,
            description: "CLACK CLACK! It's crab rave time! Talks like a real meme crab from the deep!"
        ),
        VoicePack(
            id: "friendly_krab",
            name: "Friendly Krab",
            personality: .friendly,
            voiceIdentifier: "com.apple.voice.compact.en-US.Samantha",
            pitch: 1.1,
            rate: 0.52,
            volume: 1.0,
            description: "Warm and welcoming! Occasional pinchy humor!"
        ),
        VoicePack(
            id: "mr_krabs",
            name: "Money Krab",
            personality: .greedy,
            voiceIdentifier: "com.apple.voice.compact.en-US.Alex",
            pitch: 0.85,
            rate: 0.48,
            volume: 1.0,
            description: "Arr arr arr! I like money! Spongebob reference mode activated!"
        ),
        VoicePack(
            id: "playful_pinchy",
            name: "Pinchy",
            personality: .playful,
            voiceIdentifier: "com.apple.voice.compact.en-US.Samantha",
            pitch: 1.3,
            rate: 0.58,
            volume: 1.0,
            description: "Snip snap! Energetic crab ready for adventures!"
        ),
        VoicePack(
            id: "crab_rave",
            name: "Crab Rave",
            personality: .rave,
            voiceIdentifier: "com.apple.voice.compact.en-US.Samantha",
            pitch: 1.4,
            rate: 0.62,
            volume: 1.0,
            description: "🦀🦀🦀 CRAB IS GONE 🦀🦀🦀 Party mode!"
        ),
        VoicePack(
            id: "robot_shell",
            name: "Shell-9000",
            personality: .robotic,
            voiceIdentifier: "com.apple.voice.compact.en-US.Samantha",
            pitch: 0.7,
            rate: 0.45,
            volume: 1.0,
            description: "Beep boop. I am a very serious artificial crab intelligence. Pinch protocols engaged."
        )
    ]
}

enum VoicePersonality: String, Codable {
    case friendly
    case professional
    case playful
    case calm
    case robotic
    case meme
    case greedy
    case rave
    
    var emoji: String {
        switch self {
        case .friendly: return "😊"
        case .professional: return "🎓"
        case .playful: return "🎉"
        case .calm: return "🌊"
        case .robotic: return "🤖"
        case .meme: return "🦀"
        case .greedy: return "💰"
        case .rave: return "🎵"
        }
    }
}

// MARK: - Widget Window Configuration
struct WidgetWindowConfig: Identifiable, Codable {
    let id: UUID
    var type: WidgetType
    var title: String
    var position: CGPoint
    var size: CGSize
    var isVisible: Bool
    var transparency: Double
    
    init(id: UUID = UUID(), type: WidgetType, title: String, position: CGPoint = .zero, size: CGSize = CGSize(width: 350, height: 400), isVisible: Bool = true, transparency: Double = 0.85) {
        self.id = id
        self.type = type
        self.title = title
        self.position = position
        self.size = size
        self.isVisible = isVisible
        self.transparency = transparency
    }
}

enum WidgetType: String, Codable, CaseIterable {
    case chat = "Chat"
    case quickActions = "Quick Actions"
    case commandOutput = "Command Output"
    case customInfo = "Custom Info"
    
    var icon: String {
        switch self {
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .quickActions: return "square.grid.2x2.fill"
        case .commandOutput: return "terminal.fill"
        case .customInfo: return "doc.text.fill"
        }
    }
    
    var description: String {
        switch self {
        case .chat: return "Voice chat with Krab and receive Telegram messages"
        case .quickActions: return "Quick action buttons for common tasks"
        case .commandOutput: return "View command and script outputs"
        case .customInfo: return "Display custom information panels"
        }
    }
}

// MARK: - Quick Action
struct QuickAction: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var command: String
    var color: String
    
    init(id: UUID = UUID(), name: String, icon: String, command: String, color: String = "blue") {
        self.id = id
        self.name = name
        self.icon = icon
        self.command = command
        self.color = color
    }
    
    static let defaults: [QuickAction] = [
        QuickAction(name: "Say Hello", icon: "hand.wave.fill", command: "say:Hello! How are you?", color: "orange"),
        QuickAction(name: "Time", icon: "clock.fill", command: "say:time", color: "blue"),
        QuickAction(name: "Weather", icon: "cloud.sun.fill", command: "say:weather", color: "cyan"),
        QuickAction(name: "Joke", icon: "face.smiling.fill", command: "say:joke", color: "yellow"),
        QuickAction(name: "Motivate Me", icon: "flame.fill", command: "say:motivate", color: "red"),
        QuickAction(name: "Stop Listening", icon: "mic.slash.fill", command: "stop_listening", color: "gray")
    ]
}

// MARK: - Settings
struct KrabSettings: Codable {
    var telegramBotToken: String
    var selectedVoicePackId: String
    var windowTransparency: Double
    var enableWakeWord: Bool
    var wakeWord: String
    var enableNotificationSounds: Bool
    var selectedMicrophone: String?
    var alwaysOnTop: Bool
    var enableAnimations: Bool
    
    static var `default`: KrabSettings {
        KrabSettings(
            telegramBotToken: "",
            selectedVoicePackId: "friendly_krab",
            windowTransparency: 0.85,
            enableWakeWord: true,
            wakeWord: "Hey Krab",
            enableNotificationSounds: true,
            selectedMicrophone: nil,
            alwaysOnTop: true,
            enableAnimations: true
        )
    }
    
    static func load() -> KrabSettings {
        guard let data = UserDefaults.standard.data(forKey: "krabSettings"),
              let settings = try? JSONDecoder().decode(KrabSettings.self, from: data) else {
            return .default
        }
        return settings
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "krabSettings")
        }
    }
}

// MARK: - Telegram Message
struct TelegramMessage: Codable {
    let messageId: Int
    let from: TelegramUser?
    let chat: TelegramChat
    let text: String?
    let date: Int
    
    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case from
        case chat
        case text
        case date
    }
}

struct TelegramUser: Codable {
    let id: Int
    let firstName: String
    let lastName: String?
    let username: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case username
    }
    
    var displayName: String {
        if let username = username {
            return "@\(username)"
        }
        return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
}

struct TelegramChat: Codable {
    let id: Int
    let type: String
    let title: String?
}

struct TelegramUpdate: Codable {
    let updateId: Int
    let message: TelegramMessage?
    
    enum CodingKeys: String, CodingKey {
        case updateId = "update_id"
        case message
    }
}

struct TelegramResponse: Codable {
    let ok: Bool
    let result: [TelegramUpdate]?
}
