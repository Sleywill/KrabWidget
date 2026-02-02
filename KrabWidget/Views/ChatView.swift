import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var speechManager: SpeechManager
    @EnvironmentObject var voiceManager: VoiceManager
    @EnvironmentObject var telegramManager: TelegramManager
    
    @State private var inputText = ""
    @State private var messages: [ChatMessage] = []
    @State private var showVoiceIndicator = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(allMessages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: allMessages.count) { _, _ in
                    if let lastId = allMessages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Voice/Input area
            VStack(spacing: 8) {
                // Voice waveform when listening
                if speechManager.isListening {
                    WaveformView(level: speechManager.audioLevel)
                        .frame(height: 40)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Recognized text preview
                if !speechManager.recognizedText.isEmpty {
                    Text(speechManager.recognizedText)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .lineLimit(2)
                }
                
                // Input bar
                HStack(spacing: 12) {
                    // Voice button
                    VoiceButton()
                    
                    // Text input
                    TextField("Type a message...", text: $inputText)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    // Send button
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(inputText.isEmpty ? .gray : appState.currentTheme.accentColor)
                    }
                    .buttonStyle(.plain)
                    .disabled(inputText.isEmpty)
                }
                .padding()
            }
            .background(Color.black.opacity(0.2))
        }
    }
    
    private var allMessages: [ChatMessage] {
        (messages + telegramManager.messages).sorted { $0.timestamp < $1.timestamp }
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        let userMessage = ChatMessage(content: inputText, sender: .user)
        messages.append(userMessage)
        
        let text = inputText
        inputText = ""
        
        // Krab responds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let response = generateKrabResponse(to: text)
            let krabMessage = ChatMessage(content: response, sender: .krab)
            messages.append(krabMessage)
            voiceManager.speak(response)
        }
    }
    
    private func generateKrabResponse(to input: String) -> String {
        let lower = input.lowercased()
        
        if lower.contains("hello") || lower.contains("hi") || lower.contains("hey") {
            return ["Hey there! 🦀 How can I help you today?",
                    "Hello, friend! What's on your mind?",
                    "Hi! Great to hear from you!"].randomElement()!
        }
        
        if lower.contains("time") {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "It's currently \(formatter.string(from: Date())) 🕐"
        }
        
        if lower.contains("joke") {
            return ["Why don't crabs ever share? Because they're shellfish! 🦀",
                    "What do you call a crab that plays baseball? A pinch hitter!",
                    "Why did the crab cross the road? To get to the other tide!"].randomElement()!
        }
        
        if lower.contains("thank") {
            return ["You're welcome! Happy to help! 🦀",
                    "Anytime, friend!",
                    "My pleasure!"].randomElement()!
        }
        
        if lower.contains("how are you") {
            return "I'm doing great, living my best crab life! 🦀 How about you?"
        }
        
        return "I heard you say: \"\(input)\". I'm still learning new tricks! 🦀"
    }
}

struct MessageBubble: View {
    @EnvironmentObject var appState: AppState
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                // Sender name for non-user messages
                if message.sender != .user {
                    Text(message.sender.displayName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Message bubble
                Text(message.content)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.sender == .user
                            ? appState.currentTheme.primaryColor
                            : message.sender.bubbleColor.opacity(0.8)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                
                // Timestamp
                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            if message.sender != .user {
                Spacer(minLength: 50)
            }
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: message.timestamp)
    }
}

struct VoiceButton: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var speechManager: SpeechManager
    @EnvironmentObject var voiceManager: VoiceManager
    
    @State private var isPressed = false
    @State private var pulseAnimation = false
    
    var body: some View {
        Button(action: toggleListening) {
            ZStack {
                // Pulse effect when listening
                if speechManager.isListening {
                    Circle()
                        .fill(appState.currentTheme.accentColor.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseAnimation)
                }
                
                Circle()
                    .fill(
                        speechManager.isListening
                            ? appState.currentTheme.accentColor
                            : Color.gray.opacity(0.3)
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: speechManager.isListening ? "waveform" : "mic.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .symbolEffect(.variableColor.iterative, isActive: speechManager.isListening)
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            pulseAnimation = speechManager.isListening
        }
        .onChange(of: speechManager.isListening) { _, newValue in
            pulseAnimation = newValue
        }
    }
    
    private func toggleListening() {
        if speechManager.isListening {
            speechManager.stopListening()
        } else {
            speechManager.startListening()
        }
    }
}
