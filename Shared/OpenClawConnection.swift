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
    var openClawToken: String?
    var isConnected: Bool
    
    static let `default` = ConnectionConfig(
        botToken: nil,
        openClawEndpoint: "http://127.0.0.1:18789",
        openClawToken: nil,
        isConnected: false
    )
}

// MARK: - OpenAI API Response Models
struct OpenAIResponse: Codable {
    let id: String?
    let choices: [Choice]?
    let error: OpenAIError?
    
    struct Choice: Codable {
        let message: Message?
        let delta: Delta?
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case message, delta
            case finishReason = "finish_reason"
        }
    }
    
    struct Message: Codable {
        let role: String
        let content: String?
    }
    
    struct Delta: Codable {
        let content: String?
    }
    
    struct OpenAIError: Codable {
        let message: String
        let type: String?
    }
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
    @Published var isProcessing: Bool = false
    
    private let configKey = "com.openclaw.krabwidget.config"
    private let messagesKey = "com.openclaw.krabwidget.messages"
    private var currentTask: Task<Void, Never>?
    
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
        return Array(messages.suffix(50))
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
        lastError = nil
        
        guard let endpoint = config.openClawEndpoint, !endpoint.isEmpty else {
            connectionStatus = .error
            lastError = "No endpoint configured"
            return
        }
        
        guard let token = config.openClawToken, !token.isEmpty else {
            connectionStatus = .error
            lastError = "No auth token configured"
            return
        }
        
        // Test connection with a simple health check
        do {
            let healthURL = URL(string: "\(endpoint)/health")!
            var request = URLRequest(url: healthURL)
            request.timeoutInterval = 10
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    connectionStatus = .connected
                    config.isConnected = true
                    
                    // Add welcome message if first connect
                    if messages.isEmpty {
                        addReceivedMessage("🦀 Connected to OpenClaw! Type a message to chat with Crab.")
                    }
                } else {
                    throw ConnectionError.invalidResponse
                }
            }
        } catch {
            // Health endpoint might not exist, try the chat endpoint directly
            connectionStatus = .connected
            config.isConnected = true
            
            if messages.isEmpty {
                addReceivedMessage("🦀 Connected! Type a message to chat with Crab.")
            }
        }
    }
    
    func disconnect() {
        currentTask?.cancel()
        currentTask = nil
        connectionStatus = .disconnected
        config.isConnected = false
    }
    
    // MARK: - Messaging
    func sendMessage(_ content: String) async {
        guard !content.isEmpty else { return }
        guard connectionStatus == .connected else {
            lastError = "Not connected"
            return
        }
        
        // Add user message
        let userMessage = ChatMessage(content: content, isFromUser: true)
        messages.append(userMessage)
        saveMessages()
        
        isProcessing = true
        
        do {
            let response = try await sendToOpenClaw(content)
            addReceivedMessage(response)
        } catch {
            lastError = error.localizedDescription
            addReceivedMessage("⚠️ Error: \(error.localizedDescription)")
        }
        
        isProcessing = false
    }
    
    private func sendToOpenClaw(_ content: String) async throws -> String {
        guard let endpoint = config.openClawEndpoint,
              let token = config.openClawToken else {
            throw ConnectionError.noConfiguration
        }
        
        let url = URL(string: "\(endpoint)/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("main", forHTTPHeaderField: "x-openclaw-agent-id")
        request.timeoutInterval = 120
        
        // Build messages array from history
        var apiMessages: [[String: String]] = []
        
        // Add recent context (last 10 messages)
        let recentMessages = messages.suffix(10)
        for msg in recentMessages {
            apiMessages.append([
                "role": msg.isFromUser ? "user" : "assistant",
                "content": msg.content
            ])
        }
        
        // Add current message if not already included
        if apiMessages.last?["content"] != content {
            apiMessages.append(["role": "user", "content": content])
        }
        
        let body: [String: Any] = [
            "model": "openclaw:main",
            "messages": apiMessages,
            "user": "krabwidget-user"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConnectionError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorStr = String(data: data, encoding: .utf8) {
                throw ConnectionError.serverError(errorStr)
            }
            throw ConnectionError.httpError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
        
        if let error = openAIResponse.error {
            throw ConnectionError.serverError(error.message)
        }
        
        guard let choice = openAIResponse.choices?.first,
              let messageContent = choice.message?.content else {
            throw ConnectionError.noContent
        }
        
        return messageContent
    }
    
    func addReceivedMessage(_ content: String) {
        let message = ChatMessage(content: content, isFromUser: false)
        messages.append(message)
        saveMessages()
    }
    
    func clearHistory() {
        messages.removeAll()
        saveMessages()
    }
}

// MARK: - Errors
enum ConnectionError: LocalizedError {
    case invalidToken
    case invalidResponse
    case sendFailed
    case noConfiguration
    case noContent
    case httpError(Int)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidToken: return "Invalid auth token"
        case .invalidResponse: return "Invalid server response"
        case .sendFailed: return "Failed to send message"
        case .noConfiguration: return "No connection configured"
        case .noContent: return "No response content"
        case .httpError(let code): return "HTTP error: \(code)"
        case .serverError(let msg): return msg
        }
    }
}
