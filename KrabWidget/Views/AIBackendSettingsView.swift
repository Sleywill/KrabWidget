import SwiftUI

struct AIBackendSettingsView: View {
    @ObservedObject var aiManager = AIBackendManager.shared
    @State private var config = AIBackendConfig.load()
    @State private var showingTestResult = false
    @State private var testMessage = ""
    
    var body: some View {
        Form {
            // Backend Selection
            Section("AI Backend") {
                ForEach(AIBackendType.allCases, id: \.rawValue) { backend in
                    BackendOptionRow(
                        backend: backend,
                        isSelected: aiManager.currentBackend == backend,
                        status: aiManager.currentBackend == backend ? aiManager.connectionStatus : .disconnected
                    ) {
                        aiManager.setBackend(backend)
                    }
                }
            }
            
            // Configuration based on selected backend
            if aiManager.currentBackend != .none {
                Section("\(aiManager.currentBackend.displayName) Configuration") {
                    backendConfigView
                }
                
                Section("Connection") {
                    HStack {
                        Image(systemName: aiManager.connectionStatus.icon)
                            .foregroundColor(aiManager.connectionStatus.color)
                        
                        Text(connectionStatusText)
                            .foregroundColor(aiManager.connectionStatus.color)
                        
                        Spacer()
                        
                        Button(aiManager.isConnected ? "Disconnect" : "Connect") {
                            if aiManager.isConnected {
                                aiManager.disconnect()
                            } else {
                                aiManager.connect()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if let error = aiManager.lastError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Toggle("Auto-connect on launch", isOn: $config.autoConnect)
                        .onChange(of: config.autoConnect) { _, _ in
                            config.save()
                        }
                }
            }
        }
        .formStyle(.grouped)
    }
    
    private var connectionStatusText: String {
        switch aiManager.connectionStatus {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .error: return "Error"
        }
    }
    
    @ViewBuilder
    private var backendConfigView: some View {
        switch aiManager.currentBackend {
        case .openClaw:
            openClawConfig
        case .openAI:
            openAIConfig
        case .ollama:
            ollamaConfig
        case .anthropic:
            anthropicConfig
        case .custom:
            customConfig
        case .none:
            EmptyView()
        }
    }
    
    private var openClawConfig: some View {
        Group {
            TextField("Gateway URL", text: $config.openClawURL)
                .textFieldStyle(.roundedBorder)
                .onChange(of: config.openClawURL) { _, _ in config.save() }
            
            SecureField("API Token", text: $config.openClawToken)
                .textFieldStyle(.roundedBorder)
                .onChange(of: config.openClawToken) { _, _ in config.save() }
            
            TextField("Model", text: $config.openClawModel)
                .textFieldStyle(.roundedBorder)
                .onChange(of: config.openClawModel) { _, _ in config.save() }
            
            Text("Connect to your OpenClaw gateway for AI-powered responses")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var openAIConfig: some View {
        Group {
            SecureField("API Key", text: $config.openAIKey)
                .textFieldStyle(.roundedBorder)
                .onChange(of: config.openAIKey) { _, _ in config.save() }
            
            Picker("Model", selection: $config.openAIModel) {
                Text("GPT-4o Mini").tag("gpt-4o-mini")
                Text("GPT-4o").tag("gpt-4o")
                Text("GPT-4 Turbo").tag("gpt-4-turbo")
                Text("GPT-3.5 Turbo").tag("gpt-3.5-turbo")
            }
            .onChange(of: config.openAIModel) { _, _ in config.save() }
            
            Link("Get API Key", destination: URL(string: "https://platform.openai.com/api-keys")!)
                .font(.caption)
        }
    }
    
    private var ollamaConfig: some View {
        Group {
            TextField("Ollama URL", text: $config.ollamaURL)
                .textFieldStyle(.roundedBorder)
                .onChange(of: config.ollamaURL) { _, _ in config.save() }
            
            TextField("Model", text: $config.ollamaModel)
                .textFieldStyle(.roundedBorder)
                .onChange(of: config.ollamaModel) { _, _ in config.save() }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Popular models: llama3.2, mistral, codellama, phi")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Link("Install Ollama", destination: URL(string: "https://ollama.ai")!)
                    .font(.caption)
            }
        }
    }
    
    private var anthropicConfig: some View {
        Group {
            SecureField("API Key", text: $config.anthropicKey)
                .textFieldStyle(.roundedBorder)
                .onChange(of: config.anthropicKey) { _, _ in config.save() }
            
            Picker("Model", selection: $config.anthropicModel) {
                Text("Claude 3 Haiku").tag("claude-3-haiku-20240307")
                Text("Claude 3 Sonnet").tag("claude-3-sonnet-20240229")
                Text("Claude 3 Opus").tag("claude-3-opus-20240229")
            }
            .onChange(of: config.anthropicModel) { _, _ in config.save() }
            
            Link("Get API Key", destination: URL(string: "https://console.anthropic.com/")!)
                .font(.caption)
        }
    }
    
    private var customConfig: some View {
        Group {
            TextField("API URL", text: $config.customURL)
                .textFieldStyle(.roundedBorder)
                .onChange(of: config.customURL) { _, _ in config.save() }
            
            SecureField("Bearer Token (optional)", text: $config.customToken)
                .textFieldStyle(.roundedBorder)
                .onChange(of: config.customToken) { _, _ in config.save() }
            
            Text("Your API should accept POST with {\"message\": \"...\"} and return {\"response\": \"...\"}")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct BackendOptionRow: View {
    let backend: AIBackendType
    let isSelected: Bool
    let status: ConnectionStatus
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: backend.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .orange : .gray)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(backend.displayName)
                        .foregroundColor(.primary)
                        .fontWeight(isSelected ? .semibold : .regular)
                    
                    Text(backend.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(status.color)
                        .frame(width: 8, height: 8)
                    
                    Image(systemName: "checkmark")
                        .foregroundColor(.orange)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Setup Guide View
struct AISetupGuideView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedBackend: AIBackendType = .ollama
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🦀")
                            .font(.system(size: 60))
                        Text("Connect Krab to AI")
                            .font(.title.bold())
                        Text("Choose how you want Krab to think")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    // Options
                    VStack(spacing: 16) {
                        SetupOptionCard(
                            title: "🏠 Local AI (Ollama)",
                            subtitle: "Free • Private • Runs on your Mac",
                            steps: [
                                "Download Ollama from ollama.ai",
                                "Run: ollama pull llama3.2",
                                "Krab connects automatically!"
                            ],
                            isRecommended: true
                        )
                        
                        SetupOptionCard(
                            title: "☁️ OpenAI",
                            subtitle: "Powerful • Requires API key",
                            steps: [
                                "Get API key from platform.openai.com",
                                "Paste key in Settings → AI Backend",
                                "Choose your model (GPT-4o recommended)"
                            ]
                        )
                        
                        SetupOptionCard(
                            title: "🔌 OpenClaw",
                            subtitle: "Your existing AI gateway",
                            steps: [
                                "Start your OpenClaw gateway",
                                "Enter gateway URL in settings",
                                "Use your existing API token"
                            ]
                        )
                        
                        SetupOptionCard(
                            title: "🎨 Custom API",
                            subtitle: "Any OpenAI-compatible endpoint",
                            steps: [
                                "Enter your API endpoint URL",
                                "Add authentication token if needed",
                                "API should accept standard chat format"
                            ]
                        )
                    }
                    .padding(.horizontal)
                    
                    // Quick Start
                    VStack(alignment: .leading, spacing: 12) {
                        Text("⚡ Quick Start with Ollama")
                            .font(.headline)
                        
                        Text("Ollama lets you run AI completely locally and free!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            CodeBlock("# Install Ollama (macOS)")
                            CodeBlock("brew install ollama")
                            CodeBlock("")
                            CodeBlock("# Start Ollama")
                            CodeBlock("ollama serve")
                            CodeBlock("")
                            CodeBlock("# Pull a model")
                            CodeBlock("ollama pull llama3.2")
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("AI Setup Guide")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .frame(width: 500, height: 600)
    }
}

struct SetupOptionCard: View {
    let title: String
    let subtitle: String
    let steps: [String]
    var isRecommended: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isRecommended {
                    Text("Recommended")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.green.opacity(0.2)))
                        .foregroundColor(.green)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        Text(step)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .stroke(isRecommended ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct CodeBlock: View {
    let code: String
    
    init(_ code: String) {
        self.code = code
    }
    
    var body: some View {
        Text(code)
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(code.starts(with: "#") ? .gray : .green)
    }
}
