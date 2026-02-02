import Foundation
import Speech
import AVFoundation
import Combine

class SpeechManager: NSObject, ObservableObject {
    @Published var isListening = false
    @Published var isAuthorized = false
    @Published var recognizedText = ""
    @Published var audioLevel: Float = 0.0
    @Published var errorMessage: String?
    @Published var isProcessing = false
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var levelTimer: Timer?
    
    private var settings: KrabSettings
    private var onSpeechRecognized: ((String) -> Void)?
    
    override init() {
        self.settings = KrabSettings.load()
        super.init()
        setupSpeechRecognizer()
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.isAuthorized = true
                case .denied:
                    self?.errorMessage = "Speech recognition denied. Please enable in System Preferences."
                case .restricted:
                    self?.errorMessage = "Speech recognition is restricted on this device."
                case .notDetermined:
                    self?.errorMessage = "Speech recognition not yet authorized."
                @unknown default:
                    self?.errorMessage = "Unknown authorization status."
                }
            }
        }
    }
    
    func setOnSpeechRecognized(_ handler: @escaping (String) -> Void) {
        self.onSpeechRecognized = handler
    }
    
    func startListening() {
        guard isAuthorized else {
            errorMessage = "Speech recognition not authorized"
            return
        }
        
        guard !isListening else { return }
        
        // Reset any existing session
        stopListening()
        
        do {
            try startRecognition()
            isListening = true
            startLevelMonitoring()
        } catch {
            errorMessage = "Failed to start listening: \(error.localizedDescription)"
        }
    }
    
    private func startRecognition() throws {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "SpeechManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.taskHint = .dictation
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            
            // Calculate audio level
            let channelData = buffer.floatChannelData?[0]
            let frameLength = Int(buffer.frameLength)
            if let data = channelData {
                var sum: Float = 0
                for i in 0..<frameLength {
                    sum += abs(data[i])
                }
                let average = sum / Float(frameLength)
                DispatchQueue.main.async {
                    self?.audioLevel = min(average * 50, 1.0)
                }
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.recognizedText = text
                }
                
                // Check for wake word
                if self.settings.enableWakeWord {
                    let lowerText = text.lowercased()
                    let wakeWord = self.settings.wakeWord.lowercased()
                    if lowerText.contains(wakeWord) {
                        // Extract command after wake word
                        if let range = lowerText.range(of: wakeWord) {
                            let afterWakeWord = String(text[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                            if !afterWakeWord.isEmpty && result.isFinal {
                                DispatchQueue.main.async {
                                    self.onSpeechRecognized?(afterWakeWord)
                                }
                            }
                        }
                    }
                }
                
                // If not using wake word, trigger on final result
                if result.isFinal && !self.settings.enableWakeWord {
                    DispatchQueue.main.async {
                        self.onSpeechRecognized?(text)
                    }
                }
            }
            
            if error != nil || result?.isFinal == true {
                // Restart listening if we're still supposed to be listening
                if self.isListening {
                    self.restartRecognition()
                }
            }
        }
    }
    
    private func restartRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self, self.isListening else { return }
            do {
                try self.startRecognition()
            } catch {
                self.errorMessage = "Failed to restart recognition: \(error.localizedDescription)"
                self.isListening = false
            }
        }
    }
    
    func stopListening() {
        isListening = false
        stopLevelMonitoring()
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        
        DispatchQueue.main.async {
            self.audioLevel = 0
            self.recognizedText = ""
        }
    }
    
    private func startLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            // Audio level is updated in the tap callback
        }
    }
    
    private func stopLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
    }
    
    func getAvailableMicrophones() -> [String] {
        let devices = AVCaptureDevice.devices(for: .audio)
        return devices.map { $0.localizedName }
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension SpeechManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            if !available {
                self.errorMessage = "Speech recognition is temporarily unavailable"
            }
        }
    }
}
