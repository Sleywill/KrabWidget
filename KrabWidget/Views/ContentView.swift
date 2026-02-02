import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connection: OpenClawConnection
    @State private var showingSetup = false
    
    var body: some View {
        Group {
            if !connection.config.isConnected {
                OnboardingView(showingSetup: $showingSetup)
            } else {
                MainView()
            }
        }
        .frame(minWidth: 400, minHeight: 500)
        .background(GlassBackground())
    }
}

// MARK: - Glass Background
struct GlassBackground: View {
    var body: some View {
        ZStack {
            // Dark gradient base
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.07, blue: 0.14),
                    Color(red: 0.12, green: 0.10, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle noise texture
            Color.white.opacity(0.02)
            
            // Accent glow
            Circle()
                .fill(Color.red.opacity(0.15))
                .blur(radius: 100)
                .offset(x: -100, y: -150)
            
            Circle()
                .fill(Color.orange.opacity(0.1))
                .blur(radius: 80)
                .offset(x: 150, y: 200)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var connection: OpenClawConnection
    @Binding var showingSetup: Bool
    @State private var botToken = ""
    @State private var openClawEndpoint = ""
    @State private var selectedTab = 0
    @State private var isConnecting = false
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with mascot
            VStack(spacing: 16) {
                Image("KrabMascot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .shadow(color: .red.opacity(0.5), radius: 20)
                
                Text("KrabWidget")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("Powered by OpenClaw")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            // Connection tabs
            VStack(spacing: 20) {
                // Tab picker
                Picker("Connection Type", selection: $selectedTab) {
                    Text("Telegram Bot").tag(0)
                    Text("OpenClaw").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)
                
                // Tab content
                VStack(spacing: 16) {
                    if selectedTab == 0 {
                        TelegramSetupView(botToken: $botToken)
                    } else {
                        OpenClawSetupView(endpoint: $openClawEndpoint)
                    }
                }
                .padding(.horizontal, 40)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
            
            Spacer()
            
            // Connect button
            VStack(spacing: 12) {
                if showError, let error = connection.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button(action: connect) {
                    HStack {
                        if isConnecting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "link")
                        }
                        Text(isConnecting ? "Connecting..." : "Connect")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: canConnect ? [.red, .orange] : [.gray, .gray.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!canConnect || isConnecting)
                .padding(.horizontal, 40)
                
                Text("Connection is required to use KrabWidget")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.7))
            }
            .padding(.bottom, 40)
        }
    }
    
    private var canConnect: Bool {
        !botToken.isEmpty || !openClawEndpoint.isEmpty
    }
    
    private func connect() {
        isConnecting = true
        showError = false
        
        if selectedTab == 0 {
            connection.config.botToken = botToken
            connection.config.openClawEndpoint = nil
        } else {
            connection.config.openClawEndpoint = openClawEndpoint
            connection.config.botToken = nil
        }
        
        Task {
            await connection.connect()
            await MainActor.run {
                isConnecting = false
                if connection.connectionStatus == .error {
                    showError = true
                }
            }
        }
    }
}

// MARK: - Setup Views
struct TelegramSetupView: View {
    @Binding var botToken: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Telegram Bot Token")
                .font(.headline)
                .foregroundColor(.white)
            
            SecureField("Enter your bot token", text: $botToken)
                .textFieldStyle(GlassTextFieldStyle())
            
            VStack(alignment: .leading, spacing: 8) {
                Text("How to get a bot token:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                VStack(alignment: .leading, spacing: 4) {
                    StepText(number: 1, text: "Open Telegram and search @BotFather")
                    StepText(number: 2, text: "Send /newbot and follow instructions")
                    StepText(number: 3, text: "Copy the token and paste above")
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
        }
    }
}

struct OpenClawSetupView: View {
    @Binding var endpoint: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OpenClaw Endpoint")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("http://localhost:3000", text: $endpoint)
                .textFieldStyle(GlassTextFieldStyle())
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Connect to OpenClaw:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                VStack(alignment: .leading, spacing: 4) {
                    StepText(number: 1, text: "Start OpenClaw gateway")
                    StepText(number: 2, text: "Enter the endpoint URL above")
                    StepText(number: 3, text: "Default: http://localhost:3000")
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
        }
    }
}

struct StepText: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .font(.caption)
                .foregroundColor(.orange)
                .frame(width: 16)
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Glass Text Field Style
struct GlassTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

// MARK: - Main View (After Connection)
struct MainView: View {
    @EnvironmentObject var connection: OpenClawConnection
    @State private var messageText = ""
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image("KrabMascot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("KrabWidget")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(connection.connectionStatus == .connected ? Color.green : Color.red)
                            .frame(width: 6, height: 6)
                        Text(connection.connectionStatus.rawValue)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.black.opacity(0.2))
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(connection.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: connection.messages.count) { _ in
                    if let lastMessage = connection.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(GlassTextFieldStyle())
                    .onSubmit(sendMessage)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color.black.opacity(0.2))
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        let text = messageText
        messageText = ""
        Task {
            await connection.sendMessage(text)
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isFromUser
                            ? LinearGradient(colors: [.red.opacity(0.8), .orange.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !message.isFromUser { Spacer() }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var connection: OpenClawConnection
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") { dismiss() }
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Connection")
                    .font(.headline)
                
                HStack {
                    Circle()
                        .fill(connection.connectionStatus == .connected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(connection.connectionStatus.rawValue)
                    Spacer()
                }
                
                Button(action: { connection.disconnect() }) {
                    Text("Disconnect")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            Text("Powered by OpenClaw 🦀")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
        }
        .frame(width: 350, height: 400)
    }
}

#Preview {
    ContentView()
        .environmentObject(OpenClawConnection.shared)
}
