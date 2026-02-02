import SwiftUI

struct QuickActionsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceManager: VoiceManager
    @EnvironmentObject var speechManager: SpeechManager
    
    @State private var actions = QuickAction.defaults
    @State private var isEditing = false
    @State private var showingAddAction = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Quick Actions")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Button(action: { isEditing.toggle() }) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle")
                        .foregroundColor(appState.currentTheme.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Actions grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(actions) { action in
                        ActionButton(action: action, isEditing: isEditing) {
                            executeAction(action)
                        } onDelete: {
                            deleteAction(action)
                        }
                    }
                    
                    // Add button
                    if isEditing {
                        Button(action: { showingAddAction = true }) {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 30))
                                Text("Add")
                                    .font(.caption)
                            }
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    .foregroundColor(.gray.opacity(0.5))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddAction) {
            AddActionSheet(isPresented: $showingAddAction) { newAction in
                actions.append(newAction)
            }
        }
    }
    
    private func executeAction(_ action: QuickAction) {
        let command = action.command
        
        if command.starts(with: "say:") {
            let text = String(command.dropFirst(4))
            voiceManager.speak(text)
        } else if command == "stop_listening" {
            speechManager.stopListening()
            voiceManager.speak("Okay, I'll stop listening now")
        } else if command == "start_listening" {
            speechManager.startListening()
            voiceManager.speak("I'm listening!")
        }
    }
    
    private func deleteAction(_ action: QuickAction) {
        actions.removeAll { $0.id == action.id }
    }
}

struct ActionButton: View {
    @EnvironmentObject var appState: AppState
    let action: QuickAction
    let isEditing: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    private var buttonColor: Color {
        switch action.color {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "cyan": return .cyan
        default: return appState.currentTheme.accentColor
        }
    }
    
    var body: some View {
        Button(action: {
            if !isEditing {
                onTap()
            }
        }) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    Image(systemName: action.icon)
                        .font(.system(size: 24))
                        .foregroundColor(buttonColor)
                    
                    Text(action.name)
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(buttonColor.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(buttonColor.opacity(0.5), lineWidth: 1)
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                
                // Delete button when editing
                if isEditing {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                            .background(Circle().fill(Color.white))
                    }
                    .buttonStyle(.plain)
                    .offset(x: 8, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            withAnimation(.spring(response: 0.2)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct AddActionSheet: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    let onAdd: (QuickAction) -> Void
    
    @State private var name = ""
    @State private var selectedIcon = "star.fill"
    @State private var command = ""
    @State private var selectedColor = "blue"
    
    private let icons = [
        "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "moon.fill", "sun.max.fill", "cloud.fill", "leaf.fill",
        "music.note", "bell.fill", "clock.fill", "calendar",
        "folder.fill", "doc.fill", "terminal.fill", "gear"
    ]
    
    private let colors = [
        "red", "orange", "yellow", "green", "blue", "purple", "pink", "cyan"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Quick Action")
                .font(.title2.bold())
            
            VStack(alignment: .leading, spacing: 16) {
                // Name
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Action name...", text: $name)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Icon
                VStack(alignment: .leading, spacing: 4) {
                    Text("Icon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedIcon == icon ? appState.currentTheme.accentColor : .gray)
                                    .frame(width: 35, height: 35)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(selectedIcon == icon ? appState.currentTheme.accentColor.opacity(0.2) : Color.clear)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Color
                VStack(alignment: .leading, spacing: 4) {
                    Text("Color")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: { selectedColor = color }) {
                                Circle()
                                    .fill(colorFromString(color))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Command
                VStack(alignment: .leading, spacing: 4) {
                    Text("Command")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("say:Hello! or command...", text: $command)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("Use 'say:text' to speak, or custom commands")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button("Add") {
                    let action = QuickAction(
                        name: name,
                        icon: selectedIcon,
                        command: command,
                        color: selectedColor
                    )
                    onAdd(action)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || command.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
    
    private func colorFromString(_ string: String) -> Color {
        switch string {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "cyan": return .cyan
        default: return .blue
        }
    }
}
