import Foundation
import Combine

// MARK: - Models
struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}

struct ConnectionConfig: Codable {
    var botToken: String?
    var openClawEndpoint: String?
    var isConnected: Bool
    
    static let `default` = ConnectionConfig(botToken: nil, openClawEndpoint: nil, isConnected: false)
}

// MARK: - Connection Manager
@MainActor
class OpenClawConnection: ObservableObject {
    static let shared = OpenClawConnection()
    
    @Published var config: ConnectionConfig {
        didSet { saveConfig() }
    }
    @Published var messages: [ChatMessage] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var lastError: String?
    
    private let configKey = "com.openclaw.krabwidget.config"
    private let messagesKey = "com.openclaw.krabwidget.messages"
    private var pollingTask: Task<Void, Never>?
    
    enum ConnectionStatus: String {
        case disconnected = "Disconnected"
        case connecting = "Connecting..."
        case connected = "Connected"
        case error = "Error"
    }
    
    private init() {
        self.config = Self.loadConfig()
        self.messages = Self.loadMessages()
        
        if config.isConnected {
            Task { await connect() }
        }
    }
    
    // MARK: - Persistence
    private static func loadConfig() -> ConnectionConfig {
        guard let data = UserDefaults.standard.data(forKey: "com.openclaw.krabwidget.config"),
              let config = try? JSONDecoder().decode(ConnectionConfig.self, from: data) else {
            return .default
        }
        return config
    }
    
    private func saveConfig() {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }
    
    private static func loadMessages() -> [ChatMessage] {
        guard let data = UserDefaults.standard.data(forKey: "com.openclaw.krabwidget.messages"),
              let messages = try? JSONDecoder().decode([ChatMessage].self, from: data) else {
            return []
        }
        return Array(messages.suffix(50)) // Keep last 50
    }
    
    private func saveMessages() {
        let toSave = Array(messages.suffix(50))
        if let data = try? JSONEncoder().encode(toSave) {
            UserDefaults.standard.set(data, forKey: messagesKey)
        }
    }
    
    // MARK: - Connection
    func connect() async {
        connectionStatus = .connecting
        
        // Validate configuration
        guard config.botToken != nil || config.openClawEndpoint != nil else {
            connectionStatus = .error
            lastError = "No connection configured"
            return
        }
        
        // Test connection
        do {
            try await testConnection()
            connectionStatus = .connected
            config.isConnected = true
            lastError = nil
            startPolling()
        } catch {
            connectionStatus = .error
            lastError = error.localizedDescription
        }
    }
    
    func disconnect() {
        pollingTask?.cancel()
        pollingTask = nil
        connectionStatus = .disconnected
        config.isConnected = false
    }
    
    private func testConnection() async throws {
        // If using OpenClaw endpoint
        if let endpoint = config.openClawEndpoint, !endpoint.isEmpty {
            let url = URL(string: "\(endpoint)/health")!
            let (_, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw ConnectionError.invalidResponse
            }
        }
        
        // If using Telegram bot token
        if let token = config.botToken, !token.isEmpty {
            let url = URL(string: "https://api.telegram.org/bot\(token)/getMe")!
            let (_, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw ConnectionError.invalidToken
            }
        }
    }
    
    private func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled && connectionStatus == .connected {
                await fetchMessages()
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            }
        }
    }
    
    private func fetchMessages() async {
        // Implement actual message fetching based on connection type
        // This is a placeholder for the actual implementation
    }
    
    // MARK: - Messaging
    func sendMessage(_ content: String) async -> Bool {
        let message = ChatMessage(content: content, isFromUser: true)
        messages.append(message)
        saveMessages()
        
        // Send to backend
        do {
            try await sendToBackend(content)
            return true
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }
    
    private func sendToBackend(_ content: String) async throws {
        if let endpoint = config.openClawEndpoint {
            var request = URLRequest(url: URL(string: "\(endpoint)/message")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(["message": content])
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw ConnectionError.sendFailed
            }
        }
    }
    
    func addReceivedMessage(_ content: String) {
        let message = ChatMessage(content: content, isFromUser: false)
        messages.append(message)
        saveMessages()
    }
}

// MARK: - Errors
enum ConnectionError: LocalizedError {
    case invalidToken
    case invalidResponse
    case sendFailed
    case noConfiguration
    
    var errorDescription: String? {
        switch self {
        case .invalidToken: return "Invalid bot token"
        case .invalidResponse: return "Invalid server response"
        case .sendFailed: return "Failed to send message"
        case .noConfiguration: return "No connection configured"
        }
    }
}
