import Foundation
import SwiftUI
import Combine

// MARK: - Crab Status Manager
class CrabStatusManager: ObservableObject {
    static let shared = CrabStatusManager()
    
    @Published var currentStatus: CrabStatus = .idle
    @Published var statusHistory: [CrabStatusEntry] = []
    @Published var mood: CrabMood = .happy
    @Published var energy: Double = 1.0  // 0.0 to 1.0
    @Published var isThinking = false
    @Published var currentThought: String = ""
    
    private var statusTimer: Timer?
    private var idleTimer: Timer?
    private var thoughtCycleTimer: Timer?
    private let maxHistoryItems = 50
    
    // Fun idle thoughts
    private let idleThoughts = [
        "🌊 Dreaming of the ocean...",
        "🦐 Thinking about lunch...",
        "🏖️ Missing the beach vibes...",
        "💭 Contemplating the meaning of shells...",
        "🎵 Humming a sea shanty...",
        "📚 Reviewing crab facts...",
        "🌙 Stargazing through the screen...",
        "🎮 Wondering if crabs can play video games...",
        "☕ Wishing crabs could drink coffee...",
        "🎨 Imagining new shell colors...",
        "🤔 Why do humans walk forward anyway?",
        "🌈 Appreciating the coral reef memories...",
        "🎯 Planning world domination... just kidding!",
        "😴 Power napping with one eye open...",
        "🔮 Predicting your next command...",
    ]
    
    private init() {
        startIdleThoughtCycle()
    }
    
    // MARK: - Public Status Updates
    
    func setStatus(_ status: CrabStatus, duration: TimeInterval? = nil) {
        DispatchQueue.main.async {
            let entry = CrabStatusEntry(status: self.currentStatus, endTime: Date())
            self.statusHistory.append(entry)
            if self.statusHistory.count > self.maxHistoryItems {
                self.statusHistory.removeFirst()
            }
            
            withAnimation(.spring(response: 0.3)) {
                self.currentStatus = status
                self.isThinking = status.isThinking
                self.updateMoodForStatus(status)
            }
        }
        
        // Auto-return to idle after duration
        if let duration = duration {
            statusTimer?.invalidate()
            statusTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                self?.setIdle()
            }
        }
    }
    
    func setIdle() {
        setStatus(.idle)
    }
    
    func setThinking(_ thought: String) {
        currentThought = thought
        setStatus(.thinking(thought))
    }
    
    // MARK: - Convenience Status Methods
    
    func startListening() {
        setStatus(.listening)
    }
    
    func startProcessing(_ task: String) {
        setStatus(.processing(task))
    }
    
    func startSearching(_ query: String) {
        setStatus(.searching(query))
    }
    
    func startCheckingEmails() {
        setStatus(.checkingEmails)
    }
    
    func foundSomethingCool(_ what: String) {
        setStatus(.excited(what), duration: 5.0)
    }
    
    func showError(_ error: String) {
        setStatus(.error(error), duration: 8.0)
    }
    
    func celebrate(_ reason: String) {
        setStatus(.celebrating(reason), duration: 4.0)
    }
    
    // MARK: - Private Methods
    
    private func updateMoodForStatus(_ status: CrabStatus) {
        switch status {
        case .idle:
            mood = .relaxed
        case .listening:
            mood = .attentive
        case .processing, .searching, .thinking:
            mood = .focused
        case .checkingEmails, .checkingNews, .checkingWeather:
            mood = .curious
        case .excited, .celebrating:
            mood = .ecstatic
        case .error:
            mood = .concerned
        case .sleeping:
            mood = .sleepy
        }
    }
    
    private func startIdleThoughtCycle() {
        thoughtCycleTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            guard let self = self, case .idle = self.currentStatus else { return }
            
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.currentThought = self.idleThoughts.randomElement() ?? ""
                }
            }
        }
    }
    
    // MARK: - Energy System (Fun mechanic!)
    
    func useEnergy(_ amount: Double) {
        DispatchQueue.main.async {
            withAnimation(.spring) {
                self.energy = max(0, self.energy - amount)
                if self.energy < 0.2 {
                    self.mood = .tired
                }
                if self.energy <= 0 {
                    self.setStatus(.sleeping)
                }
            }
        }
    }
    
    func rechargeEnergy(_ amount: Double) {
        DispatchQueue.main.async {
            withAnimation(.spring) {
                self.energy = min(1.0, self.energy + amount)
            }
        }
    }
    
    func fullRecharge() {
        energy = 1.0
        mood = .happy
    }
}

// MARK: - Crab Status Enum
enum CrabStatus: Equatable {
    case idle
    case listening
    case thinking(String)
    case processing(String)
    case searching(String)
    case checkingEmails
    case checkingNews
    case checkingWeather
    case excited(String)
    case celebrating(String)
    case error(String)
    case sleeping
    
    var displayText: String {
        switch self {
        case .idle:
            return "😴 Chilling, waiting for you..."
        case .listening:
            return "👂 Listening... speak to me!"
        case .thinking(let thought):
            return "🤔 Thinking about \(thought)..."
        case .processing(let task):
            return "⚙️ Processing: \(task)..."
        case .searching(let query):
            return "🔍 Searching for \(query)..."
        case .checkingEmails:
            return "📧 Checking your emails..."
        case .checkingNews:
            return "📰 Browsing the latest news..."
        case .checkingWeather:
            return "🌤️ Checking the weather..."
        case .excited(let what):
            return "🎉 Found something cool: \(what)!"
        case .celebrating(let reason):
            return "🥳 \(reason)!"
        case .error(let error):
            return "😰 Oops: \(error)"
        case .sleeping:
            return "💤 Zzz... (low energy, tap to wake!)"
        }
    }
    
    var emoji: String {
        switch self {
        case .idle: return "🦀"
        case .listening: return "👂"
        case .thinking: return "🤔"
        case .processing: return "⚙️"
        case .searching: return "🔍"
        case .checkingEmails: return "📧"
        case .checkingNews: return "📰"
        case .checkingWeather: return "🌤️"
        case .excited: return "🎉"
        case .celebrating: return "🥳"
        case .error: return "😰"
        case .sleeping: return "💤"
        }
    }
    
    var color: Color {
        switch self {
        case .idle: return .gray
        case .listening: return .blue
        case .thinking, .processing: return .orange
        case .searching: return .cyan
        case .checkingEmails: return .purple
        case .checkingNews: return .indigo
        case .checkingWeather: return .teal
        case .excited, .celebrating: return .green
        case .error: return .red
        case .sleeping: return .gray.opacity(0.5)
        }
    }
    
    var isThinking: Bool {
        switch self {
        case .thinking, .processing, .searching:
            return true
        default:
            return false
        }
    }
    
    var isActive: Bool {
        switch self {
        case .idle, .sleeping:
            return false
        default:
            return true
        }
    }
}

// MARK: - Crab Mood
enum CrabMood: String {
    case happy = "😊"
    case relaxed = "😌"
    case attentive = "🧐"
    case focused = "😤"
    case curious = "🤨"
    case ecstatic = "🤩"
    case concerned = "😟"
    case tired = "😫"
    case sleepy = "😴"
    
    var description: String {
        switch self {
        case .happy: return "Happy"
        case .relaxed: return "Relaxed"
        case .attentive: return "Attentive"
        case .focused: return "Focused"
        case .curious: return "Curious"
        case .ecstatic: return "Ecstatic"
        case .concerned: return "Concerned"
        case .tired: return "Tired"
        case .sleepy: return "Sleepy"
        }
    }
}

// MARK: - Status History Entry
struct CrabStatusEntry: Identifiable {
    let id = UUID()
    let status: CrabStatus
    let endTime: Date
}

// MARK: - Crab Status Widget View
struct CrabStatusWidget: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var statusManager = CrabStatusManager.shared
    
    @State private var isExpanded = false
    @State private var crabWiggle = false
    @State private var pulseAnimation = false
    @State private var textAnimation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main status bar
            mainStatusBar
            
            // Expanded details
            if isExpanded {
                expandedDetails
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .glassCard(cornerRadius: 16, opacity: 0.9)
        .shadow(color: statusManager.currentStatus.color.opacity(0.3), radius: pulseAnimation ? 15 : 8)
        .onAppear {
            startAnimations()
        }
    }
    
    private var mainStatusBar: some View {
        Button(action: { withAnimation(.spring) { isExpanded.toggle() } }) {
            HStack(spacing: 12) {
                // Animated crab
                animatedCrab
                
                // Status text
                VStack(alignment: .leading, spacing: 2) {
                    Text(statusManager.currentStatus.displayText)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .opacity(textAnimation ? 1 : 0.8)
                    
                    if !statusManager.currentThought.isEmpty && !statusManager.currentStatus.isActive {
                        Text(statusManager.currentThought)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .transition(.opacity)
                    }
                }
                
                Spacer()
                
                // Energy indicator
                energyIndicator
                
                // Expand arrow
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
    
    private var animatedCrab: some View {
        ZStack {
            // Pulse ring when active
            if statusManager.currentStatus.isActive {
                Circle()
                    .stroke(statusManager.currentStatus.color.opacity(0.5), lineWidth: 2)
                    .frame(width: 44, height: 44)
                    .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                    .opacity(pulseAnimation ? 0 : 0.8)
            }
            
            // Crab emoji
            Text("🦀")
                .font(.system(size: 28))
                .rotationEffect(.degrees(crabWiggle ? 5 : -5))
                .scaleEffect(statusManager.currentStatus.isActive ? 1.1 : 1.0)
        }
        .frame(width: 44, height: 44)
    }
    
    private var energyIndicator: some View {
        VStack(spacing: 2) {
            // Energy bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                    
                    Capsule()
                        .fill(energyColor)
                        .frame(width: geo.size.width * statusManager.energy)
                }
            }
            .frame(width: 40, height: 6)
            
            // Mood emoji
            Text(statusManager.mood.rawValue)
                .font(.caption2)
        }
    }
    
    private var energyColor: Color {
        if statusManager.energy > 0.6 {
            return .green
        } else if statusManager.energy > 0.3 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private var expandedDetails: some View {
        VStack(spacing: 12) {
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Stats row
            HStack(spacing: 20) {
                StatBadge(label: "Mood", value: statusManager.mood.description, icon: statusManager.mood.rawValue)
                StatBadge(label: "Energy", value: "\(Int(statusManager.energy * 100))%", icon: "⚡")
                StatBadge(label: "Tasks", value: "\(statusManager.statusHistory.count)", icon: "✅")
            }
            
            // Recent activity
            if !statusManager.statusHistory.suffix(3).isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Recent Activity")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ForEach(statusManager.statusHistory.suffix(3).reversed()) { entry in
                        HStack {
                            Text(entry.status.emoji)
                            Text(entry.status.displayText)
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            // Quick actions
            HStack(spacing: 12) {
                QuickStatusButton(label: "Wake Up", icon: "sun.max.fill") {
                    statusManager.fullRecharge()
                    statusManager.setIdle()
                }
                
                QuickStatusButton(label: "Recharge", icon: "bolt.fill") {
                    statusManager.rechargeEnergy(0.5)
                }
            }
        }
        .padding()
    }
    
    private func startAnimations() {
        // Crab wiggle
        withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
            crabWiggle = true
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
            pulseAnimation = true
        }
        
        // Text fade animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            textAnimation = true
        }
    }
}

struct StatBadge: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title3)
            Text(value)
                .font(.caption.bold())
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickStatusButton: View {
    let label: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(label)
            }
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.15)))
        }
        .buttonStyle(.plain)
    }
}
