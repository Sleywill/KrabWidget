import Foundation
import Combine

// MARK: - AI Backend Manager
/// Manages connections to AI backends (OpenClaw, OpenAI, Ollama, etc.)
class AIBackendManager: ObservableObject {
    static let shared = AIBackendManager()
    
    @Published var currentBackend: AIBackendType = .none
    @Published var isConnected = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var lastError: String?
    @Published var config: AIBackendConfig
    
    private var cancellables = Set<AnyCancellable>()
    private var healthCheckTimer: Timer?
    
    private init() {
        self.config = AIBackendConfig.load()
        if let savedBackend = AIBackendType(rawValue: config.selectedBackend) {
            self.currentBackend = savedBackend
        }
        
        // Auto-connect if configured
        if config.autoConnect && currentBackend != .none {
            connect()
        }
    }
    
    // MARK: - Connection Management
    
    func connect() {
        guard currentBackend != .none else {
            connectionStatus = .disconnected
            return
        }
        
        connectionStatus = .connecting
        CrabStatusManager.shared.setStatus(.processing("Connecting to AI backend"))
        
        // Test connection based on backend type
        Task {
            do {
                try await testConnection()
                await MainActor.run {
                    self.connectionStatus = .connected
                    self.isConnected = true
                    self.lastError = nil
                    CrabStatusManager.shared.foundSomethingCool("Connected to \(self.currentBackend.displayName)!")
                    self.startHealthCheck()
                }
            } catch {
                await MainActor.run {
                    self.connectionStatus = .error
                    self.isConnected = false
                    self.lastError = error.localizedDescription
                    CrabStatusManager.shared.showError("Connection failed")
                }
            }
        }
    }
    
    func disconnect() {
        healthCheckTimer?.invalidate()
        healthCheckTimer = nil
        connectionStatus = .disconnected
        isConnected = false
    }
    
    func setBackend(_ backend: AIBackendType) {
        disconnect()
        currentBackend = backend
        config.selectedBackend = backend.rawValue
        config.save()
    }
    
    // MARK: - API Calls
    
    func sendMessage(_ message: String) async throws -> String {
        guard isConnected else {
            throw AIBackendError.notConnected
        }
        
        CrabStatusManager.shared.setThinking("your message")
        
        switch currentBackend {
        case .openClaw:
            return try await sendToOpenClaw(message)
        case .openAI:
            return try await sendToOpenAI(message)
        case .ollama:
            return try await sendToOllama(message)
        case .anthropic:
            return try await sendToAnthropic(message)
        case .custom:
            return try await sendToCustom(message)
        case .none:
            throw AIBackendError.notConfigured
        }
    }
    
    // MARK: - Backend-Specific Implementations
    
    private func sendToOpenClaw(_ message: String) async throws -> String {
        guard let url = URL(string: "\(config.openClawURL)/v1/chat/completions") else {
            throw AIBackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.openClawToken)", forHTTPHeaderField: "Authorization")
        
        let systemPrompt = "You are Krab, a friendly AI crab assistant. Be helpful, fun, and occasionally make crab-related jokes. Keep responses concise."
        let body: [String: Any] = [
            "model": config.openClawModel,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": message]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIBackendError.requestFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let choices = json?["choices"] as? [[String: Any]],
           let first = choices.first,
           let message = first["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw AIBackendError.invalidResponse
    }
    
    private func sendToOpenAI(_ message: String) async throws -> String {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw AIBackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.openAIKey)", forHTTPHeaderField: "Authorization")
        
        let systemPrompt = "You are Krab, a friendly AI crab assistant. Be helpful, fun, and occasionally make crab-related jokes. Keep responses concise."
        let body: [String: Any] = [
            "model": config.openAIModel,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": message]
            ],
            "max_tokens": 500
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIBackendError.requestFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let choices = json?["choices"] as? [[String: Any]],
           let first = choices.first,
           let message = first["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw AIBackendError.invalidResponse
    }
    
    private func sendToOllama(_ message: String) async throws -> String {
        guard let url = URL(string: "\(config.ollamaURL)/api/generate") else {
            throw AIBackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = "You are Krab, a friendly AI crab assistant. Be helpful and fun.\n\nUser: \(message)\n\nKrab:"
        let body: [String: Any] = [
            "model": config.ollamaModel,
            "prompt": prompt,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIBackendError.requestFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let responseText = json?["response"] as? String {
            return responseText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        throw AIBackendError.invalidResponse
    }
    
    private func sendToAnthropic(_ message: String) async throws -> String {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw AIBackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.anthropicKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let systemPrompt = "You are Krab, a friendly AI crab assistant. Be helpful, fun, and occasionally make crab-related jokes. Keep responses concise."
        let body: [String: Any] = [
            "model": config.anthropicModel,
            "max_tokens": 500,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": message]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIBackendError.requestFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let content = json?["content"] as? [[String: Any]],
           let first = content.first,
           let text = first["text"] as? String {
            return text
        }
        
        throw AIBackendError.invalidResponse
    }
    
    private func sendToCustom(_ message: String) async throws -> String {
        guard let url = URL(string: config.customURL) else {
            throw AIBackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if !config.customToken.isEmpty {
            request.setValue("Bearer \(config.customToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Custom endpoints should accept this format
        let body: [String: Any] = [
            "message": message,
            "context": "You are Krab, the meme crab! CLACK CLACK! Make crab puns, reference crab rave!"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIBackendError.requestFailed
        }
        
        // Try to parse response - custom endpoints should return {"response": "..."} or {"message": "..."}
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let response = json?["response"] as? String {
            return response
        }
        if let message = json?["message"] as? String {
            return message
        }
        if let text = String(data: data, encoding: .utf8) {
            return text
        }
        
        throw AIBackendError.invalidResponse
    }
    
    // MARK: - Health Check
    
    private func testConnection() async throws {
        switch currentBackend {
        case .openClaw:
            guard let url = URL(string: "\(config.openClawURL)/health") else {
                throw AIBackendError.invalidURL
            }
            let (_, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw AIBackendError.requestFailed
            }
            
        case .openAI:
            // OpenAI doesn't have a health endpoint, so we just validate the key format
            guard !config.openAIKey.isEmpty && config.openAIKey.starts(with: "sk-") else {
                throw AIBackendError.invalidCredentials
            }
            
        case .ollama:
            guard let url = URL(string: "\(config.ollamaURL)/api/tags") else {
                throw AIBackendError.invalidURL
            }
            let (_, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw AIBackendError.requestFailed
            }
            
        case .anthropic:
            guard !config.anthropicKey.isEmpty else {
                throw AIBackendError.invalidCredentials
            }
            
        case .custom:
            guard let url = URL(string: config.customURL) else {
                throw AIBackendError.invalidURL
            }
            let (_, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw AIBackendError.requestFailed
            }
            
        case .none:
            throw AIBackendError.notConfigured
        }
    }
    
    private func startHealthCheck() {
        healthCheckTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task {
                do {
                    try await self?.testConnection()
                } catch {
                    await MainActor.run {
                        self?.connectionStatus = .error
                        self?.lastError = "Connection lost"
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Types

enum AIBackendType: String, CaseIterable {
    case none = "none"
    case openClaw = "openclaw"
    case openAI = "openai"
    case ollama = "ollama"
    case anthropic = "anthropic"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .none: return "Not Configured"
        case .openClaw: return "OpenClaw"
        case .openAI: return "OpenAI"
        case .ollama: return "Ollama (Local)"
        case .anthropic: return "Anthropic Claude"
        case .custom: return "Custom API"
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "xmark.circle"
        case .openClaw: return "terminal"
        case .openAI: return "brain"
        case .ollama: return "desktopcomputer"
        case .anthropic: return "sparkles"
        case .custom: return "gear"
        }
    }
    
    var description: String {
        switch self {
        case .none:
            return "No AI backend configured"
        case .openClaw:
            return "Connect to your OpenClaw gateway for AI responses"
        case .openAI:
            return "Use OpenAI's GPT models (requires API key)"
        case .ollama:
            return "Run AI locally with Ollama (free, private)"
        case .anthropic:
            return "Use Anthropic's Claude models (requires API key)"
        case .custom:
            return "Connect to any OpenAI-compatible API"
        }
    }
}

enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    case error
    
    var color: Color {
        switch self {
        case .disconnected: return .gray
        case .connecting: return .yellow
        case .connected: return .green
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .disconnected: return "circle"
        case .connecting: return "circle.dotted"
        case .connected: return "circle.fill"
        case .error: return "exclamationmark.circle.fill"
        }
    }
}

enum AIBackendError: LocalizedError {
    case notConnected
    case notConfigured
    case invalidURL
    case invalidCredentials
    case requestFailed
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .notConnected: return "Not connected to AI backend"
        case .notConfigured: return "AI backend not configured"
        case .invalidURL: return "Invalid API URL"
        case .invalidCredentials: return "Invalid credentials"
        case .requestFailed: return "Request failed"
        case .invalidResponse: return "Invalid response from API"
        }
    }
}

// MARK: - Configuration
struct AIBackendConfig: Codable {
    var selectedBackend: String = "none"
    var autoConnect: Bool = true
    
    // OpenClaw
    var openClawURL: String = "http://localhost:3000"
    var openClawToken: String = ""
    var openClawModel: String = "default"
    
    // OpenAI
    var openAIKey: String = ""
    var openAIModel: String = "gpt-4o-mini"
    
    // Ollama
    var ollamaURL: String = "http://localhost:11434"
    var ollamaModel: String = "llama3.2"
    
    // Anthropic
    var anthropicKey: String = ""
    var anthropicModel: String = "claude-3-haiku-20240307"
    
    // Custom
    var customURL: String = ""
    var customToken: String = ""
    
    static func load() -> AIBackendConfig {
        guard let data = UserDefaults.standard.data(forKey: "aiBackendConfig"),
              let config = try? JSONDecoder().decode(AIBackendConfig.self, from: data) else {
            return AIBackendConfig()
        }
        return config
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "aiBackendConfig")
        }
    }
}

import SwiftUI
