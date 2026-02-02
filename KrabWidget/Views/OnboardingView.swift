import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceManager: VoiceManager
    @EnvironmentObject var telegramManager: TelegramManager
    @EnvironmentObject var windowManager: ModularWindowManager
    
    @State private var currentStep = 0
    @State private var telegramToken = ""
    @State private var selectedVoicePack: VoicePack = VoicePack.available[0]
    @State private var selectedLayout: LayoutPreset = .productive
    @State private var animateWelcome = false
    @State private var showCrab = false
    
    private let totalSteps = 4
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    appState.currentTheme.backgroundColor,
                    appState.currentTheme.primaryColor.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Progress indicator
                progressIndicator
                
                // Content based on step
                stepContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                Spacer()
                
                // Navigation buttons
                navigationButtons
            }
            .padding(40)
        }
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            // Greet user with voice
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.6)) {
                    showCrab = true
                    animateWelcome = true
                }
                voiceManager.onboardingGreeting()
            }
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? appState.currentTheme.accentColor : Color.gray.opacity(0.3))
                    .frame(width: step == currentStep ? 30 : 10, height: 10)
                    .animation(.spring, value: currentStep)
            }
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            welcomeStep
        case 1:
            voicePackStep
        case 2:
            telegramStep
        case 3:
            layoutStep
        default:
            EmptyView()
        }
    }
    
    // MARK: - Step 0: Welcome
    private var welcomeStep: some View {
        VStack(spacing: 24) {
            // Animated crab mascot
            Image("KrabMascot")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .scaleEffect(showCrab ? 1.0 : 0.5)
                .opacity(showCrab ? 1.0 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showCrab)
            
            VStack(spacing: 12) {
                Text("Welcome to KrabWidget!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, appState.currentTheme.accentColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(animateWelcome ? 1 : 0)
                    .offset(y: animateWelcome ? 0 : 20)
                
                Text("Your AI companion, always listening")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .opacity(animateWelcome ? 1 : 0)
                    .offset(y: animateWelcome ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: animateWelcome)
            }
            
            // Features preview
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "mic.fill", title: "Voice Commands", description: "Talk naturally, Krab listens")
                FeatureRow(icon: "speaker.wave.2.fill", title: "Voice Responses", description: "Krab talks back with personality")
                FeatureRow(icon: "bubble.left.and.bubble.right.fill", title: "Telegram Integration", description: "Receive messages in real-time")
                FeatureRow(icon: "rectangle.on.rectangle", title: "Modular Windows", description: "Customize your workspace")
            }
            .padding()
            .glassCard(cornerRadius: 16, opacity: 0.3)
            .opacity(animateWelcome ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.4), value: animateWelcome)
        }
    }
    
    // MARK: - Step 1: Voice Pack
    private var voicePackStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Choose Krab's Voice")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Pick a personality for your AI companion")
                    .foregroundColor(.gray)
            }
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(VoicePack.available) { pack in
                        VoicePackCard(
                            pack: pack,
                            isSelected: selectedVoicePack.id == pack.id,
                            onSelect: {
                                selectedVoicePack = pack
                                voiceManager.previewVoice(pack)
                            }
                        )
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .onAppear {
            voiceManager.speak("Pick a voice that suits you! Tap any option to hear a preview.")
        }
    }
    
    // MARK: - Step 2: Telegram
    private var telegramStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Connect Telegram")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Optional: Receive messages from your Telegram bot")
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("How to get a bot token:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    StepText(number: 1, text: "Open Telegram and search for @BotFather")
                    StepText(number: 2, text: "Send /newbot and follow instructions")
                    StepText(number: 3, text: "Copy the token and paste it below")
                }
                
                TextField("Paste your bot token here...", text: $telegramToken)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                
                if !telegramToken.isEmpty {
                    Button("Test Connection") {
                        telegramManager.botToken = telegramToken
                        telegramManager.connect()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(appState.currentTheme.accentColor)
                    
                    if telegramManager.isConnected {
                        Label("Connected!", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if let error = telegramManager.errorMessage {
                        Label(error, systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .glassCard(cornerRadius: 16, opacity: 0.3)
            
            Text("You can skip this and set it up later in Settings")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .onAppear {
            voiceManager.speak("If you want to receive Telegram messages, enter your bot token here. Otherwise, feel free to skip!")
        }
    }
    
    // MARK: - Step 3: Layout
    private var layoutStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Choose Your Layout")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Pick a window setup to start with")
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 20) {
                ForEach(LayoutPreset.allCases, id: \.self) { preset in
                    LayoutPresetCard(
                        preset: preset,
                        isSelected: selectedLayout == preset,
                        onSelect: { selectedLayout = preset }
                    )
                }
            }
            
            Text("You can always add or remove windows later!")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .onAppear {
            voiceManager.speak("Almost done! Pick a layout to start with. You can customize everything later.")
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(currentStep == totalSteps - 1 ? "Get Started 🦀" : "Next") {
                if currentStep == totalSteps - 1 {
                    completeOnboarding()
                } else {
                    withAnimation {
                        currentStep += 1
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(appState.currentTheme.accentColor)
        }
    }
    
    private func completeOnboarding() {
        // Save settings
        voiceManager.setVoicePack(selectedVoicePack)
        windowManager.applyPreset(selectedLayout)
        
        if !telegramToken.isEmpty {
            telegramManager.botToken = telegramToken
        }
        
        // Complete onboarding
        withAnimation {
            appState.isOnboardingComplete = true
        }
        
        // Welcome message
        voiceManager.speak("Awesome! You're all set! Just say 'Hey Krab' or press the hotkey to start talking!")
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

struct StepText: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.orange))
            
            Text(text)
                .foregroundColor(.gray)
        }
    }
}

struct VoicePackCard: View {
    @EnvironmentObject var appState: AppState
    let pack: VoicePack
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Text(pack.personality.emoji)
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(pack.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(pack.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(appState.currentTheme.accentColor)
                        .font(.title2)
                }
                
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? appState.currentTheme.primaryColor.opacity(0.3) : Color.clear)
                    .stroke(isSelected ? appState.currentTheme.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct LayoutPresetCard: View {
    @EnvironmentObject var appState: AppState
    let preset: LayoutPreset
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                Image(systemName: preset.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? appState.currentTheme.accentColor : .gray)
                
                Text(preset.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(preset.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? appState.currentTheme.primaryColor.opacity(0.3) : Color.clear)
                    .stroke(isSelected ? appState.currentTheme.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
