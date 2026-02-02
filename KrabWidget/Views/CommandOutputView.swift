import SwiftUI

struct CommandOutputView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var commandHistory: [CommandEntry] = []
    @State private var currentCommand = ""
    @State private var isRunning = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Output area
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        // Welcome message
                        if commandHistory.isEmpty {
                            welcomeMessage
                        }
                        
                        // Command history
                        ForEach(commandHistory) { entry in
                            CommandEntryView(entry: entry)
                                .id(entry.id)
                        }
                        
                        if isRunning {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Running...")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: commandHistory.count) { _, _ in
                    if let lastId = commandHistory.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Input area
            HStack(spacing: 8) {
                Text("🦀 $")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(appState.currentTheme.accentColor)
                
                TextField("Enter command...", text: $currentCommand)
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                    .onSubmit {
                        executeCommand()
                    }
                
                Button(action: executeCommand) {
                    Image(systemName: "play.fill")
                        .foregroundColor(currentCommand.isEmpty ? .gray : .green)
                }
                .buttonStyle(.plain)
                .disabled(currentCommand.isEmpty || isRunning)
            }
            .padding()
            .background(Color.black.opacity(0.3))
        }
    }
    
    private var welcomeMessage: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🦀 KrabWidget Terminal")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(appState.currentTheme.accentColor)
            
            Text("Type a command and press Enter")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
            
            Text("")
            Text("Available commands:")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
            
            Group {
                Text("  help     - Show available commands")
                Text("  echo     - Echo text back")
                Text("  date     - Show current date/time")
                Text("  crab     - Get a crab fact")
                Text("  fortune  - Get a fortune")
                Text("  clear    - Clear terminal")
            }
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(.gray.opacity(0.7))
        }
    }
    
    private func executeCommand() {
        guard !currentCommand.isEmpty else { return }
        
        let cmd = currentCommand
        currentCommand = ""
        
        let entry = CommandEntry(command: cmd, output: "", isError: false)
        commandHistory.append(entry)
        
        isRunning = true
        
        // Process command
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let output = processCommand(cmd)
            
            if let index = commandHistory.firstIndex(where: { $0.id == entry.id }) {
                commandHistory[index].output = output.text
                commandHistory[index].isError = output.isError
            }
            
            isRunning = false
        }
    }
    
    private func processCommand(_ command: String) -> (text: String, isError: Bool) {
        let parts = command.split(separator: " ", maxSplits: 1)
        let cmd = String(parts.first ?? "").lowercased()
        let args = parts.count > 1 ? String(parts[1]) : ""
        
        switch cmd {
        case "help":
            return ("""
            Available commands:
              help     - Show this help
              echo     - Echo text back
              date     - Show current date/time
              crab     - Get a crab fact
              fortune  - Get a fortune
              say      - Make Krab speak
              clear    - Clear terminal
              whoami   - Who are you?
            """, false)
            
        case "echo":
            return (args.isEmpty ? "(empty)" : args, false)
            
        case "date":
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d, yyyy 'at' h:mm:ss a"
            return (formatter.string(from: Date()), false)
            
        case "crab":
            let facts = [
                "🦀 Crabs have 10 legs! The first pair are claws called chelae.",
                "🦀 A group of crabs is called a 'cast'.",
                "🦀 Crabs can walk in all directions, but mostly walk sideways.",
                "🦀 The Japanese Spider Crab has the longest leg span of any arthropod.",
                "🦀 Crabs communicate by drumming or waving their pincers.",
                "🦀 Some crabs can live for more than 30 years!",
                "🦀 Hermit crabs don't have their own shells - they borrow them!",
                "🦀 Crabs are decapod crustaceans, related to lobsters and shrimp."
            ]
            return (facts.randomElement()!, false)
            
        case "fortune":
            let fortunes = [
                "🔮 A beautiful day awaits you. The stars align in your favor!",
                "🔮 Good things come to those who code... I mean, wait.",
                "🔮 Your perseverance will be rewarded. Keep going!",
                "🔮 An unexpected opportunity is on the horizon.",
                "🔮 Trust your instincts today. They won't lead you astray.",
                "🔮 A crab in the shell is worth two in the tide. - Ancient Crab Proverb"
            ]
            return (fortunes.randomElement()!, false)
            
        case "say":
            if args.isEmpty {
                return ("Usage: say <text>", true)
            }
            // This would normally trigger voice, but we'll just confirm
            return ("🔊 Speaking: \"\(args)\"", false)
            
        case "clear":
            commandHistory.removeAll()
            return ("", false)
            
        case "whoami":
            return ("🦀 You are a friend of Krab!", false)
            
        case "ls":
            return ("📁 Documents  📁 Downloads  📁 Projects  🦀 krab.txt", false)
            
        case "pwd":
            return ("~/KrabWidget/home", false)
            
        case "":
            return ("", false)
            
        default:
            return ("Command not found: \(cmd). Type 'help' for available commands.", true)
        }
    }
}

struct CommandEntry: Identifiable {
    let id = UUID()
    let command: String
    var output: String
    var isError: Bool
}

struct CommandEntryView: View {
    @EnvironmentObject var appState: AppState
    let entry: CommandEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Command line
            HStack(spacing: 4) {
                Text("🦀 $")
                    .foregroundColor(appState.currentTheme.accentColor)
                Text(entry.command)
                    .foregroundColor(.white)
            }
            .font(.system(.body, design: .monospaced))
            
            // Output
            if !entry.output.isEmpty {
                Text(entry.output)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(entry.isError ? .red : .gray)
                    .textSelection(.enabled)
            }
        }
    }
}
