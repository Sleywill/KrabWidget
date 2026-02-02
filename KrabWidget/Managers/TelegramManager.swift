import Foundation
import Combine

class TelegramManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isConnected = false
    @Published var errorMessage: String?
    @Published var botToken: String {
        didSet {
            settings.telegramBotToken = botToken
            settings.save()
        }
    }
    
    private var settings: KrabSettings
    private var pollingTimer: Timer?
    private var lastUpdateId: Int = 0
    private var onNewMessage: ((ChatMessage) -> Void)?
    
    init() {
        self.settings = KrabSettings.load()
        self.botToken = settings.telegramBotToken
        
        if !botToken.isEmpty {
            startPolling()
        }
    }
    
    func setOnNewMessage(_ handler: @escaping (ChatMessage) -> Void) {
        self.onNewMessage = handler
    }
    
    func connect() {
        guard !botToken.isEmpty else {
            errorMessage = "Please enter a Telegram bot token in settings"
            return
        }
        
        // Test connection first
        testConnection { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.isConnected = true
                    self?.startPolling()
                    self?.errorMessage = nil
                } else {
                    self?.isConnected = false
                    self?.errorMessage = "Failed to connect. Check your bot token."
                }
            }
        }
    }
    
    func disconnect() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        isConnected = false
    }
    
    private func testConnection(completion: @escaping (Bool) -> Void) {
        let urlString = "https://api.telegram.org/bot\(botToken)/getMe"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Telegram connection error: \(error)")
                completion(false)
                return
            }
            
            guard let data = data else {
                completion(false)
                return
            }
            
            // Check if response indicates success
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let ok = json["ok"] as? Bool {
                completion(ok)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    private func startPolling() {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.pollUpdates()
        }
        // Poll immediately
        pollUpdates()
    }
    
    private func pollUpdates() {
        guard !botToken.isEmpty else { return }
        
        var urlString = "https://api.telegram.org/bot\(botToken)/getUpdates?timeout=30"
        if lastUpdateId > 0 {
            urlString += "&offset=\(lastUpdateId + 1)"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(TelegramResponse.self, from: data)
                
                if response.ok, let updates = response.result {
                    for update in updates {
                        self.lastUpdateId = max(self.lastUpdateId, update.updateId)
                        
                        if let message = update.message, let text = message.text {
                            let chatMessage = ChatMessage(
                                content: text,
                                sender: .telegram,
                                timestamp: Date(timeIntervalSince1970: TimeInterval(message.date))
                            )
                            
                            DispatchQueue.main.async {
                                self.messages.append(chatMessage)
                                self.onNewMessage?(chatMessage)
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.isConnected = true
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error parsing Telegram response"
                }
            }
        }.resume()
    }
    
    func sendMessage(_ text: String, chatId: Int) {
        guard !botToken.isEmpty else { return }
        
        let urlString = "https://api.telegram.org/bot\(botToken)/sendMessage"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "chat_id": chatId,
            "text": text
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to send message: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func clearMessages() {
        messages.removeAll()
    }
}
