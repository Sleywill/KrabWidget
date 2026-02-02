import Foundation
import AVFoundation
import Combine

class VoiceManager: NSObject, ObservableObject {
    @Published var isSpeaking = false
    @Published var currentVoicePack: VoicePack
    @Published var availableVoices: [AVSpeechSynthesisVoice] = []
    
    private let synthesizer = AVSpeechSynthesizer()
    private var speechQueue: [String] = []
    private var settings: KrabSettings
    
    override init() {
        let loadedSettings = KrabSettings.load()
        self.settings = loadedSettings
        self.currentVoicePack = VoicePack.available.first(where: { $0.id == loadedSettings.selectedVoicePackId }) ?? VoicePack.available[0]
        super.init()
        
        synthesizer.delegate = self
        loadAvailableVoices()
    }
    
    private func loadAvailableVoices() {
        availableVoices = AVSpeechSynthesisVoice.speechVoices().filter { voice in
            voice.language.starts(with: "en")
        }
    }
    
    func speak(_ text: String, immediate: Bool = false) {
        if immediate {
            synthesizer.stopSpeaking(at: .immediate)
            speechQueue.removeAll()
        }
        
        let processedText = processSpecialCommands(text)
        
        let utterance = AVSpeechUtterance(string: processedText)
        utterance.pitchMultiplier = currentVoicePack.pitch
        utterance.rate = currentVoicePack.rate
        utterance.volume = currentVoicePack.volume
        
        // Try to use the voice pack's preferred voice
        if let voice = AVSpeechSynthesisVoice(identifier: currentVoicePack.voiceIdentifier) {
            utterance.voice = voice
        } else if let voice = availableVoices.first {
            utterance.voice = voice
        }
        
        // Add personality-specific modifications
        switch currentVoicePack.personality {
        case .playful:
            utterance.pitchMultiplier *= 1.1
        case .calm:
            utterance.rate *= 0.9
        case .robotic:
            utterance.pitchMultiplier *= 0.8
            utterance.rate *= 0.85
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
        
        synthesizer.speak(utterance)
    }
    
    private func processSpecialCommands(_ text: String) -> String {
        let lowerText = text.lowercased()
        
        if lowerText.contains("time") && lowerText.count < 20 {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "The time is \(formatter.string(from: Date()))"
        }
        
        if lowerText.contains("joke") {
            let jokes = [
                "Why don't crabs ever share? Because they're shellfish!",
                "What do you call a crab that plays baseball? A pinch hitter!",
                "Why did the crab never share his toys? Because he was a little shellfish!",
                "What's a crab's favorite fruit? Crab apples!",
                "Why are crabs so bad at sharing? They're too shellfish!",
                "What do you call a crab who's good at math? A crabculator!"
            ]
            return jokes.randomElement() ?? jokes[0]
        }
        
        if lowerText.contains("motivate") || lowerText.contains("motivation") {
            let motivations = [
                "You've got this! Even the mightiest wave started as a ripple!",
                "Keep going! Like a crab, sometimes sideways progress is still progress!",
                "Every shell you break through makes you stronger!",
                "The ocean didn't become great by giving up. Neither will you!",
                "Your potential is as deep as the ocean. Keep diving!",
                "Claws up! You're doing amazing!"
            ]
            return motivations.randomElement() ?? motivations[0]
        }
        
        if lowerText.contains("weather") {
            return "I wish I could check the weather for you! Maybe add that feature to my settings?"
        }
        
        return text
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        speechQueue.removeAll()
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func setVoicePack(_ pack: VoicePack) {
        currentVoicePack = pack
        settings.selectedVoicePackId = pack.id
        settings.save()
    }
    
    func previewVoice(_ pack: VoicePack) {
        let oldPack = currentVoicePack
        currentVoicePack = pack
        speak("Hi! I'm \(pack.name). \(pack.description)", immediate: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.currentVoicePack = oldPack
        }
    }
    
    // Krab-specific phrases
    func greet() {
        let greetings = [
            "Hey there! I'm Krab, your voice assistant! What can I do for you?",
            "Hello, friend! Ready to help you out!",
            "Greetings from the depths! How can I assist?",
            "Hey! Krab here, at your service!"
        ]
        speak(greetings.randomElement() ?? greetings[0])
    }
    
    func onboardingGreeting() {
        speak("Hey! I'm Krab, your new AI companion! Let me help you set things up. It'll be quick, I promise!")
    }
    
    func acknowledgeCommand(_ command: String) {
        let acknowledgments = [
            "Got it! Processing \(command)",
            "On it!",
            "Sure thing!",
            "Absolutely!"
        ]
        speak(acknowledgments.randomElement() ?? acknowledgments[0])
    }
    
    func notifyNewMessage(from sender: String) {
        speak("New message from \(sender)")
    }
    
    func readMessage(_ message: String, from sender: String) {
        speak("\(sender) says: \(message)")
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension VoiceManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}
