import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var speechManager: SpeechManager
    @EnvironmentObject var voiceManager: VoiceManager
    @EnvironmentObject var telegramManager: TelegramManager
    @EnvironmentObject var windowManager: ModularWindowManager
    
    @StateObject private var statusManager = CrabStatusManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var easterEggManager = EasterEggManager.shared
    @StateObject private var aiBackendManager = AIBackendManager.shared
    
    @State private var barrelRollAngle: Double = 0
    @State private var discoMode = false
    
    var body: some View {
        Group {
            if !appState.isOnboardingComplete {
                OnboardingView()
            } else {
                MainView()
                    .overlay(alignment: .topTrailing) {
                        NotificationPopupView()
                            .environmentObject(appState)
                    }
                    .overlay(alignment: .top) {
                        CrabStatusWidget()
                            .frame(maxWidth: 400)
                            .padding(.top, 8)
                            .environmentObject(appState)
                    }
                    .overlay {
                        // Easter egg effects
                        if easterEggManager.showConfetti {
                            ConfettiView(isActive: easterEggManager.showConfetti)
                        }
                        if easterEggManager.showBubbles {
                            BubbleView(isActive: easterEggManager.showBubbles)
                        }
                    }
            }
        }
        .rotation3DEffect(.degrees(barrelRollAngle), axis: (x: 1, y: 0, z: 0))
        .hueRotation(discoMode ? .degrees(360) : .degrees(0))
        .animation(discoMode ? .linear(duration: 2).repeatForever(autoreverses: false) : .default, value: discoMode)
        .onAppear {
            setupManagers()
            showWelcomeNotification()
        }
        .onReceive(NotificationCenter.default.publisher(for: .hotkeyPressed)) { _ in
            toggleListening()
        }
        .onReceive(NotificationCenter.default.publisher(for: .triggerBarrelRoll)) { _ in
            performBarrelRoll()
        }
        .onReceive(NotificationCenter.default.publisher(for: .triggerDiscoMode)) { _ in
            toggleDiscoMode()
        }
    }
    
    private func setupManagers() {
        // Setup speech recognition handler
        speechManager.setOnSpeechRecognized { text in
            handleSpeechCommand(text)
        }
        
        // Setup telegram message handler
        telegramManager.setOnNewMessage { message in
            voiceManager.notifyNewMessage(from: "Telegram")
            notificationManager.push(KrabNotification(
                type: .telegram,
                title: "📱 New Telegram Message",
                body: message.content,
                icon: "paperplane.fill",
                color: .blue
            ))
        }
        
        // Update status when speech manager state changes
        speechManager.$isListening
            .sink { listening in
                if listening {
                    statusManager.startListening()
                } else {
                    statusManager.setIdle()
                }
            }
            .store(in: &appState.cancellables)
    }
    
    private func showWelcomeNotification() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            notificationManager.showCrabMessage("Hey! I'm ready to help! Say 'Hey Krab' or press ⌘⌥Space to talk!")
            
            // Show daily tip after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                notificationManager.showDailyTip()
            }
        }
    }
    
    private func toggleListening() {
        if speechManager.isListening {
            speechManager.stopListening()
            statusManager.setIdle()
        } else {
            speechManager.startListening()
            statusManager.startListening()
        }
    }
    
    private func handleSpeechCommand(_ text: String) {
        // Check for easter eggs first
        if let _ = easterEggManager.checkPhrase(text) {
            return
        }
        
        // Update status
        statusManager.setThinking(text)
        
        // Try AI backend if connected
        if aiBackendManager.isConnected {
            Task {
                do {
                    let response = try await aiBackendManager.sendMessage(text)
                    await MainActor.run {
                        voiceManager.speak(response)
                        statusManager.setIdle()
                    }
                } catch {
                    await MainActor.run {
                        voiceManager.speak(text)
                        statusManager.setIdle()
                    }
                }
            }
        } else {
            // Fallback to local processing
            voiceManager.speak(text)
            statusManager.setIdle()
        }
    }
    
    private func performBarrelRoll() {
        withAnimation(.easeInOut(duration: 1.0)) {
            barrelRollAngle = 360
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            barrelRollAngle = 0
        }
    }
    
    private func toggleDiscoMode() {
        discoMode = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            discoMode = false
        }
    }
}

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var windowManager: ModularWindowManager
    @State private var showingAddWindow = false
    
    var body: some View {
        ZStack {
            // Background
            appState.currentTheme.backgroundColor
                .ignoresSafeArea()
            
            // Widget windows
            ForEach(windowManager.windowConfigs.filter { $0.isVisible }) { config in
                WidgetWindowView(config: config)
            }
            
            // Floating add button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    addWindowButton
                        .padding()
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .sheet(isPresented: $showingAddWindow) {
            AddWindowSheet(isPresented: $showingAddWindow)
        }
    }
    
    private var addWindowButton: some View {
        Button(action: { showingAddWindow = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [appState.currentTheme.accentColor, appState.currentTheme.primaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: appState.currentTheme.accentColor.opacity(0.5), radius: 10)
        }
        .buttonStyle(.plain)
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3), value: showingAddWindow)
    }
}

struct WidgetWindowView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var windowManager: ModularWindowManager
    let config: WidgetWindowConfig
    
    @State private var position: CGPoint
    @State private var size: CGSize
    @State private var isHovered = false
    @State private var isDragging = false
    
    init(config: WidgetWindowConfig) {
        self.config = config
        _position = State(initialValue: config.position)
        _size = State(initialValue: config.size)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            windowTitleBar
            
            // Content
            windowContent
        }
        .frame(width: size.width, height: size.height)
        .glassCard(cornerRadius: 16, opacity: config.transparency)
        .shadow(color: .black.opacity(0.3), radius: isHovered ? 20 : 10)
        .position(x: position.x + size.width/2, y: position.y + size.height/2)
        .gesture(dragGesture)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    private var windowTitleBar: some View {
        HStack {
            Image(systemName: config.type.icon)
                .foregroundColor(appState.currentTheme.accentColor)
            
            Text(config.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            // Window controls
            HStack(spacing: 8) {
                windowControlButton(icon: "minus", color: .yellow) {
                    // Minimize (hide)
                    windowManager.toggleWindowVisibility(id: config.id)
                }
                
                windowControlButton(icon: "xmark", color: .red) {
                    windowManager.removeWindow(id: config.id)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.2))
        .contentShape(Rectangle())
    }
    
    private func windowControlButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(color.opacity(isHovered ? 1.0 : 0.5))
                .frame(width: 12, height: 12)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.black.opacity(isHovered ? 0.8 : 0))
                )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var windowContent: some View {
        switch config.type {
        case .chat:
            ChatView()
        case .quickActions:
            QuickActionsView()
        case .commandOutput:
            CommandOutputView()
        case .customInfo:
            CustomInfoView()
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                position = CGPoint(
                    x: position.x + value.translation.width,
                    y: position.y + value.translation.height
                )
            }
            .onEnded { _ in
                isDragging = false
                // Save position
                var updatedConfig = config
                updatedConfig.position = position
                windowManager.updateWindow(updatedConfig)
            }
    }
}

struct AddWindowSheet: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var windowManager: ModularWindowManager
    @Binding var isPresented: Bool
    
    @State private var selectedType: WidgetType = .chat
    @State private var windowTitle = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Window")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            // Window type selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Window Type")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                ForEach(WidgetType.allCases, id: \.self) { type in
                    Button(action: { selectedType = type }) {
                        HStack {
                            Image(systemName: type.icon)
                                .foregroundColor(selectedType == type ? appState.currentTheme.accentColor : .gray)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading) {
                                Text(type.rawValue)
                                    .foregroundColor(.white)
                                Text(type.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if selectedType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(appState.currentTheme.accentColor)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedType == type ? appState.currentTheme.primaryColor.opacity(0.3) : Color.clear)
                                .stroke(selectedType == type ? appState.currentTheme.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Title input
            VStack(alignment: .leading, spacing: 8) {
                Text("Window Title")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                TextField("Enter title...", text: $windowTitle)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Actions
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.plain)
                .foregroundColor(.gray)
                
                Spacer()
                
                Button("Add Window") {
                    let title = windowTitle.isEmpty ? selectedType.rawValue : windowTitle
                    windowManager.addWindow(type: selectedType, title: title)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(appState.currentTheme.accentColor)
            }
        }
        .padding(24)
        .frame(width: 400)
        .background(appState.currentTheme.backgroundColor)
    }
}

struct CustomInfoView: View {
    @EnvironmentObject var appState: AppState
    @State private var content = "Add your custom notes here...\n\n🦀 Tip: This panel is great for quick notes!"
    
    var body: some View {
        VStack {
            TextEditor(text: $content)
                .font(.body)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState.shared)
        .environmentObject(AppState.shared.speechManager)
        .environmentObject(AppState.shared.voiceManager)
        .environmentObject(AppState.shared.telegramManager)
        .environmentObject(AppState.shared.windowManager)
        .environmentObject(AppState.shared.hotkeyManager)
}
