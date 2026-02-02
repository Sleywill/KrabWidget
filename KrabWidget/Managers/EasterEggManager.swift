import Foundation
import SwiftUI
import AppKit

// MARK: - Easter Egg Manager
/// Manages fun surprises and interactive elements throughout the app
class EasterEggManager: ObservableObject {
    static let shared = EasterEggManager()
    
    @Published var discoveredEasterEggs: Set<String> = []
    @Published var crabClickCount = 0
    @Published var konamiProgress = 0
    @Published var currentParticleEffect: ParticleEffect?
    @Published var showConfetti = false
    @Published var showBubbles = false
    @Published var crabDanceMode = false
    
    private var konamiSequence: [String] = []
    private let konamiCode = ["up", "up", "down", "down", "left", "right", "left", "right", "b", "a"]
    
    private let secretPhrases: [String: EasterEgg] = [
        "do a barrel roll": .barrelRoll,
        "crab rave": .crabRave,
        "disco mode": .discoMode,
        "party time": .partyTime,
        "the answer": .theAnswer,
        "hello world": .helloWorld,
        "i love crabs": .crabLove,
        "secret menu": .secretMenu,
        "matrix": .matrixMode,
        "nyan": .nyanCrab,
    ]
    
    private init() {
        loadDiscoveredEggs()
    }
    
    // MARK: - Easter Egg Detection
    
    func checkPhrase(_ phrase: String) -> EasterEgg? {
        let normalized = phrase.lowercased().trimmingCharacters(in: .whitespaces)
        
        if let egg = secretPhrases[normalized] {
            trigger(egg)
            return egg
        }
        
        // Check for numeric easter eggs
        if normalized == "42" || normalized == "forty two" {
            trigger(.theAnswer)
            return .theAnswer
        }
        
        return nil
    }
    
    func addKonamiInput(_ direction: String) {
        konamiSequence.append(direction)
        
        // Keep only last 10 inputs
        if konamiSequence.count > 10 {
            konamiSequence.removeFirst()
        }
        
        // Check if matches Konami code
        if konamiSequence == konamiCode {
            trigger(.konamiCode)
            konamiSequence.removeAll()
        }
        
        konamiProgress = konamiSequence.count
    }
    
    func crabTapped() {
        crabClickCount += 1
        
        // Easter eggs based on click count
        switch crabClickCount {
        case 10:
            NotificationManager.shared.showCrabMessage("Hey! That tickles! 🦀")
        case 25:
            NotificationManager.shared.showCrabMessage("Okay okay, you found a secret!")
            trigger(.clickMaster)
        case 50:
            trigger(.crabRave)
            NotificationManager.shared.showCrabMessage("🦀🦀🦀 CRAB RAVE ACTIVATED! 🦀🦀🦀")
        case 100:
            trigger(.ultimateCrab)
            NotificationManager.shared.showCrabMessage("You are the ultimate crab whisperer!")
        default:
            break
        }
    }
    
    // MARK: - Trigger Effects
    
    func trigger(_ egg: EasterEgg) {
        // Mark as discovered
        discoveredEasterEggs.insert(egg.id)
        saveDiscoveredEggs()
        
        // Execute effect
        switch egg {
        case .barrelRoll:
            triggerBarrelRoll()
        case .crabRave:
            triggerCrabRave()
        case .discoMode:
            triggerDiscoMode()
        case .partyTime:
            triggerParty()
        case .theAnswer:
            VoiceManager().speak("The answer to life, the universe, and everything is... 42!")
        case .helloWorld:
            VoiceManager().speak("Hello, World! I'm Krab, your friendly neighborhood crab assistant!")
        case .crabLove:
            triggerCrabLove()
        case .secretMenu:
            NotificationManager.shared.showCrabMessage("🤫 You found the secret menu! More features coming soon...")
        case .matrixMode:
            triggerMatrixMode()
        case .nyanCrab:
            triggerNyanCrab()
        case .konamiCode:
            triggerKonamiCode()
        case .clickMaster:
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showConfetti = false
            }
        case .ultimateCrab:
            triggerUltimateCrab()
        }
    }
    
    // MARK: - Effect Implementations
    
    private func triggerBarrelRoll() {
        // Post notification for views to handle
        NotificationCenter.default.post(name: .triggerBarrelRoll, object: nil)
    }
    
    private func triggerCrabRave() {
        crabDanceMode = true
        showConfetti = true
        VoiceManager().speak("Crab rave activated! Let's dance!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.crabDanceMode = false
            self.showConfetti = false
        }
    }
    
    private func triggerDiscoMode() {
        NotificationCenter.default.post(name: .triggerDiscoMode, object: nil)
        VoiceManager().speak("Disco time! Feel the groove!")
    }
    
    private func triggerParty() {
        showConfetti = true
        showBubbles = true
        VoiceManager().speak("Party time! Let's celebrate!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showConfetti = false
            self.showBubbles = false
        }
    }
    
    private func triggerCrabLove() {
        currentParticleEffect = .hearts
        VoiceManager().speak("Aww, I love you too! Here's some hearts!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.currentParticleEffect = nil
        }
    }
    
    private func triggerMatrixMode() {
        NotificationCenter.default.post(name: .triggerMatrixMode, object: nil)
        VoiceManager().speak("Wake up, Neo. The Matrix has you.")
    }
    
    private func triggerNyanCrab() {
        VoiceManager().speak("Nyan nyan nyan nyan nyan!")
        currentParticleEffect = .rainbows
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.currentParticleEffect = nil
        }
    }
    
    private func triggerKonamiCode() {
        showConfetti = true
        VoiceManager().speak("Konami code activated! You are a true gamer!")
        NotificationManager.shared.showSuccess("🎮 Konami Code!", "+30 lives unlocked! Just kidding, but you're awesome!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showConfetti = false
        }
    }
    
    private func triggerUltimateCrab() {
        showConfetti = true
        crabDanceMode = true
        currentParticleEffect = .stars
        VoiceManager().speak("You have achieved the rank of ULTIMATE CRAB! You clicked me 100 times! I both respect and fear your dedication!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            self.showConfetti = false
            self.crabDanceMode = false
            self.currentParticleEffect = nil
        }
    }
    
    // MARK: - Persistence
    
    private func loadDiscoveredEggs() {
        if let data = UserDefaults.standard.data(forKey: "discoveredEasterEggs"),
           let eggs = try? JSONDecoder().decode(Set<String>.self, from: data) {
            discoveredEasterEggs = eggs
        }
    }
    
    private func saveDiscoveredEggs() {
        if let data = try? JSONEncoder().encode(discoveredEasterEggs) {
            UserDefaults.standard.set(data, forKey: "discoveredEasterEggs")
        }
    }
    
    // MARK: - Statistics
    
    var discoveryProgress: Double {
        Double(discoveredEasterEggs.count) / Double(EasterEgg.allCases.count)
    }
    
    var discoveryText: String {
        "\(discoveredEasterEggs.count)/\(EasterEgg.allCases.count) Easter Eggs Found"
    }
}

// MARK: - Easter Egg Types
enum EasterEgg: String, CaseIterable {
    case barrelRoll = "barrel_roll"
    case crabRave = "crab_rave"
    case discoMode = "disco_mode"
    case partyTime = "party_time"
    case theAnswer = "the_answer"
    case helloWorld = "hello_world"
    case crabLove = "crab_love"
    case secretMenu = "secret_menu"
    case matrixMode = "matrix_mode"
    case nyanCrab = "nyan_crab"
    case konamiCode = "konami_code"
    case clickMaster = "click_master"
    case ultimateCrab = "ultimate_crab"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .barrelRoll: return "Barrel Roll"
        case .crabRave: return "Crab Rave"
        case .discoMode: return "Disco Mode"
        case .partyTime: return "Party Time"
        case .theAnswer: return "The Answer"
        case .helloWorld: return "Hello World"
        case .crabLove: return "Crab Love"
        case .secretMenu: return "Secret Menu"
        case .matrixMode: return "Matrix Mode"
        case .nyanCrab: return "Nyan Crab"
        case .konamiCode: return "Konami Code"
        case .clickMaster: return "Click Master"
        case .ultimateCrab: return "Ultimate Crab"
        }
    }
    
    var hint: String {
        switch self {
        case .barrelRoll: return "Try asking me to do something acrobatic..."
        case .crabRave: return "Crabs love to dance! 🦀🎵"
        case .discoMode: return "Remember the 70s?"
        case .partyTime: return "Sometimes you just need to celebrate!"
        case .theAnswer: return "What's the meaning of life?"
        case .helloWorld: return "Every programmer knows this one"
        case .crabLove: return "Express your feelings..."
        case .secretMenu: return "There might be hidden options..."
        case .matrixMode: return "Follow the white rabbit"
        case .nyanCrab: return "A classic internet meme, but crabbier"
        case .konamiCode: return "⬆️⬆️⬇️⬇️⬅️➡️⬅️➡️🅱️🅰️"
        case .clickMaster: return "Click the crab... a lot"
        case .ultimateCrab: return "The ultimate clicking achievement"
        }
    }
    
    var icon: String {
        switch self {
        case .barrelRoll: return "arrow.clockwise.circle"
        case .crabRave: return "music.note.list"
        case .discoMode: return "sparkles"
        case .partyTime: return "party.popper.fill"
        case .theAnswer: return "42.circle"
        case .helloWorld: return "curlybraces"
        case .crabLove: return "heart.fill"
        case .secretMenu: return "list.bullet.rectangle"
        case .matrixMode: return "rectangle.stack.fill"
        case .nyanCrab: return "rainbow"
        case .konamiCode: return "gamecontroller.fill"
        case .clickMaster: return "hand.tap.fill"
        case .ultimateCrab: return "crown.fill"
        }
    }
}

// MARK: - Particle Effects
enum ParticleEffect {
    case hearts
    case stars
    case rainbows
    case bubbles
    case confetti
}

// MARK: - Notification Names
extension Notification.Name {
    static let triggerBarrelRoll = Notification.Name("triggerBarrelRoll")
    static let triggerDiscoMode = Notification.Name("triggerDiscoMode")
    static let triggerMatrixMode = Notification.Name("triggerMatrixMode")
}

// MARK: - Easter Egg Collection View
struct EasterEggCollectionView: View {
    @ObservedObject var easterEggManager = EasterEggManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Text("🥚 Easter Egg Collection")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text(easterEggManager.discoveryText)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * easterEggManager.discoveryProgress)
                    }
                }
                .frame(height: 8)
            }
            .padding()
            
            // Egg grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(EasterEgg.allCases, id: \.rawValue) { egg in
                        EasterEggCard(egg: egg, isDiscovered: easterEggManager.discoveredEasterEggs.contains(egg.id))
                    }
                }
                .padding()
            }
        }
    }
}

struct EasterEggCard: View {
    let egg: EasterEgg
    let isDiscovered: Bool
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isDiscovered ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                if isDiscovered {
                    Image(systemName: egg.icon)
                        .font(.title2)
                        .foregroundColor(.orange)
                } else {
                    Text("?")
                        .font(.title2.bold())
                        .foregroundColor(.gray)
                }
            }
            
            Text(isDiscovered ? egg.name : "???")
                .font(.caption)
                .foregroundColor(isDiscovered ? .white : .gray)
                .lineLimit(1)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isHovered ? 0.1 : 0.05))
                .stroke(isDiscovered ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3)) {
                isHovered = hovering
            }
        }
        .help(isDiscovered ? egg.name : egg.hint)
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    let isActive: Bool
    
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Text(particle.emoji)
                        .font(.system(size: particle.size))
                        .position(particle.position)
                        .rotationEffect(.degrees(particle.rotation))
                        .opacity(particle.opacity)
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startConfetti(in: geo.size)
                } else {
                    particles.removeAll()
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func startConfetti(in size: CGSize) {
        let emojis = ["🎉", "🎊", "✨", "⭐", "🦀", "🌟", "💫", "🎈"]
        
        for _ in 0..<50 {
            let particle = ConfettiParticle(
                emoji: emojis.randomElement()!,
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: -20),
                size: CGFloat.random(in: 20...40),
                rotation: Double.random(in: 0...360),
                velocity: CGPoint(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: 200...400)),
                opacity: 1.0
            )
            particles.append(particle)
        }
        
        // Animate particles falling
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            if !isActive || particles.isEmpty {
                timer.invalidate()
                return
            }
            
            for i in particles.indices {
                particles[i].position.x += particles[i].velocity.x * 0.016
                particles[i].position.y += particles[i].velocity.y * 0.016
                particles[i].rotation += 5
                particles[i].velocity.y += 200 * 0.016 // gravity
                
                if particles[i].position.y > size.height + 50 {
                    particles[i].opacity = 0
                }
            }
            
            particles.removeAll { $0.opacity == 0 }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    var position: CGPoint
    let size: CGFloat
    var rotation: Double
    var velocity: CGPoint
    var opacity: Double
}

// MARK: - Bubble View
struct BubbleView: View {
    let isActive: Bool
    
    @State private var bubbles: [Bubble] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(bubbles) { bubble in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.3), .clear],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: bubble.size
                            )
                        )
                        .frame(width: bubble.size, height: bubble.size)
                        .position(bubble.position)
                        .opacity(bubble.opacity)
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startBubbles(in: geo.size)
                } else {
                    bubbles.removeAll()
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func startBubbles(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if !isActive {
                timer.invalidate()
                return
            }
            
            let bubble = Bubble(
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height + 20),
                size: CGFloat.random(in: 10...40),
                velocity: CGFloat.random(in: 50...150),
                opacity: Double.random(in: 0.3...0.7)
            )
            bubbles.append(bubble)
        }
        
        // Animate bubbles rising
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            if !isActive || bubbles.isEmpty {
                timer.invalidate()
                return
            }
            
            for i in bubbles.indices {
                bubbles[i].position.y -= bubbles[i].velocity * 0.016
                bubbles[i].position.x += sin(bubbles[i].position.y * 0.05) * 0.5
                
                if bubbles[i].position.y < -50 {
                    bubbles[i].opacity = 0
                }
            }
            
            bubbles.removeAll { $0.opacity == 0 }
        }
    }
}

struct Bubble: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let velocity: CGFloat
    var opacity: Double
}
