import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceManager: VoiceManager
    @EnvironmentObject var telegramManager: TelegramManager
    @EnvironmentObject var hotkeyManager: HotkeyManager
    
    @State private var settings = KrabSettings.load()
    @State private var showingVoicePackSheet = false
    
    var body: some View {
        TabView {
            // General Settings
            generalSettingsTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            // AI Backend
            AIBackendSettingsView()
                .tabItem {
                    Label("AI Backend", systemImage: "brain")
                }
            
            // Voice Settings
            voiceSettingsTab
                .tabItem {
                    Label("Voice", systemImage: "speaker.wave.2.fill")
                }
            
            // Telegram Settings
            telegramSettingsTab
                .tabItem {
                    Label("Telegram", systemImage: "paperplane.fill")
                }
            
            // Appearance
            appearanceTab
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush.fill")
                }
            
            // Hotkeys
            hotkeysTab
                .tabItem {
                    Label("Hotkeys", systemImage: "keyboard")
                }
            
            // Easter Eggs
            easterEggsTab
                .tabItem {
                    Label("Easter Eggs", systemImage: "egg.fill")
                }
        }
        .frame(width: 600, height: 500)
        .padding()
    }
    
    // MARK: - Easter Eggs Tab
    private var easterEggsTab: some View {
        EasterEggCollectionView()
    }
    
    // MARK: - General Settings
    private var generalSettingsTab: some View {
        Form {
            Section("Window Behavior") {
                Toggle("Always on top", isOn: $settings.alwaysOnTop)
                    .onChange(of: settings.alwaysOnTop) { _, newValue in
                        settings.save()
                        updateWindowLevel(newValue)
                    }
                
                Toggle("Enable animations", isOn: $settings.enableAnimations)
                    .onChange(of: settings.enableAnimations) { _, _ in
                        settings.save()
                    }
            }
            
            Section("Audio") {
                Toggle("Notification sounds", isOn: $settings.enableNotificationSounds)
                    .onChange(of: settings.enableNotificationSounds) { _, _ in
                        settings.save()
                    }
                
                Picker("Microphone", selection: Binding(
                    get: { settings.selectedMicrophone ?? "" },
                    set: { settings.selectedMicrophone = $0.isEmpty ? nil : $0 }
                )) {
                    Text("Default").tag("")
                    ForEach(SpeechManager().getAvailableMicrophones(), id: \.self) { mic in
                        Text(mic).tag(mic)
                    }
                }
            }
            
            Section("Reset") {
                Button("Reset Onboarding") {
                    appState.isOnboardingComplete = false
                }
                .foregroundColor(.orange)
                
                Button("Reset All Settings") {
                    settings = .default
                    settings.save()
                }
                .foregroundColor(.red)
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Voice Settings
    private var voiceSettingsTab: some View {
        Form {
            Section("Current Voice Pack") {
                HStack {
                    Text(voiceManager.currentVoicePack.personality.emoji)
                        .font(.largeTitle)
                    
                    VStack(alignment: .leading) {
                        Text(voiceManager.currentVoicePack.name)
                            .font(.headline)
                        Text(voiceManager.currentVoicePack.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Change") {
                        showingVoicePackSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 8)
                
                Button("Preview Voice") {
                    voiceManager.speak("Hello! This is how I sound. Pretty cool, right?")
                }
            }
            
            Section("Wake Word") {
                Toggle("Enable wake word detection", isOn: $settings.enableWakeWord)
                    .onChange(of: settings.enableWakeWord) { _, _ in
                        settings.save()
                    }
                
                if settings.enableWakeWord {
                    TextField("Wake word", text: $settings.wakeWord)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: settings.wakeWord) { _, _ in
                            settings.save()
                        }
                    
                    Text("Say \"\(settings.wakeWord)\" followed by your command")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Voice Tuning") {
                VStack(alignment: .leading) {
                    Text("These settings modify the selected voice pack")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $showingVoicePackSheet) {
            VoicePackSelectionSheet(isPresented: $showingVoicePackSheet)
        }
    }
    
    // MARK: - Telegram Settings
    private var telegramSettingsTab: some View {
        Form {
            Section("Bot Configuration") {
                SecureField("Bot Token", text: $settings.telegramBotToken)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: settings.telegramBotToken) { _, newValue in
                        settings.save()
                        telegramManager.botToken = newValue
                    }
                
                HStack {
                    if telegramManager.isConnected {
                        Label("Connected", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Label("Disconnected", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    Button(telegramManager.isConnected ? "Disconnect" : "Connect") {
                        if telegramManager.isConnected {
                            telegramManager.disconnect()
                        } else {
                            telegramManager.connect()
                        }
                    }
                }
                
                if let error = telegramManager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Section("Message Handling") {
                Toggle("Read messages aloud", isOn: .constant(true))
                Toggle("Show notification badge", isOn: .constant(true))
            }
            
            Section("Setup Help") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to create a Telegram bot:")
                        .font(.headline)
                    
                    Text("1. Open Telegram and search for @BotFather")
                    Text("2. Send /newbot and follow the instructions")
                    Text("3. Copy the token and paste it above")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Appearance
    private var appearanceTab: some View {
        Form {
            Section("Theme") {
                ForEach(KrabTheme.allCases, id: \.self) { theme in
                    Button(action: { appState.currentTheme = theme }) {
                        HStack {
                            Circle()
                                .fill(theme.primaryColor)
                                .frame(width: 24, height: 24)
                            
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 24, height: 24)
                            
                            Text(theme.rawValue)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if appState.currentTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Section("Window Transparency") {
                Slider(value: $settings.windowTransparency, in: 0.3...1.0, step: 0.05) {
                    Text("Transparency")
                }
                .onChange(of: settings.windowTransparency) { _, _ in
                    settings.save()
                }
                
                Text("Current: \(Int(settings.windowTransparency * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Hotkeys
    private var hotkeysTab: some View {
        Form {
            Section("Voice Activation Hotkey") {
                Text("Current: \(hotkeyManager.currentHotkey.displayString)")
                    .font(.headline)
                
                Text("Press this hotkey to toggle voice listening")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("Preset Hotkeys")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(HotkeyManager.presets.indices, id: \.self) { index in
                    let preset = HotkeyManager.presets[index]
                    Button(action: { hotkeyManager.setHotkey(preset) }) {
                        HStack {
                            Text(preset.displayString)
                            Spacer()
                            if hotkeyManager.currentHotkey == preset {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Section("Tips") {
                Text("• Use the hotkey to quickly toggle voice listening")
                Text("• Say \"\(settings.wakeWord)\" to activate hands-free")
                Text("• Voice commands are processed when you pause speaking")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .formStyle(.grouped)
    }
    
    private func updateWindowLevel(_ alwaysOnTop: Bool) {
        NSApp.windows.forEach { window in
            window.level = alwaysOnTop ? .floating : .normal
        }
    }
}

struct VoicePackSelectionSheet: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceManager: VoiceManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Voice Pack")
                .font(.title2.bold())
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(VoicePack.available) { pack in
                        VoicePackRow(pack: pack, isSelected: voiceManager.currentVoicePack.id == pack.id) {
                            voiceManager.setVoicePack(pack)
                            voiceManager.previewVoice(pack)
                        }
                    }
                }
                .padding()
            }
            
            Button("Done") {
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(width: 450, height: 400)
        .padding()
    }
}

struct VoicePackRow: View {
    @EnvironmentObject var appState: AppState
    let pack: VoicePack
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Text(pack.personality.emoji)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(pack.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(pack.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(appState.currentTheme.accentColor)
                }
                
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? appState.currentTheme.primaryColor.opacity(0.2) : Color.clear)
                    .stroke(isSelected ? appState.currentTheme.accentColor : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
