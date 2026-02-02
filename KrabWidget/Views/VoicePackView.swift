import SwiftUI

struct VoicePackView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceManager: VoiceManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Current voice
            currentVoiceSection
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // All voice packs
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(VoicePack.available) { pack in
                        VoicePackDetailCard(pack: pack)
                    }
                }
                .padding()
            }
        }
    }
    
    private var currentVoiceSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Current Voice")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
            }
            .padding(.horizontal)
            
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(appState.currentTheme.primaryColor.opacity(0.5))
                        .frame(width: 60, height: 60)
                    
                    Text(voiceManager.currentVoicePack.personality.emoji)
                        .font(.largeTitle)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(voiceManager.currentVoicePack.name)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    Text(voiceManager.currentVoicePack.personality.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Play button
                Button(action: {
                    voiceManager.speak("Hello! This is my current voice. Pretty nice, right?")
                }) {
                    Image(systemName: voiceManager.isSpeaking ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(appState.currentTheme.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .glassCard(cornerRadius: 12, opacity: 0.3)
            .padding(.horizontal)
        }
    }
}

struct VoicePackDetailCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var voiceManager: VoiceManager
    let pack: VoicePack
    
    @State private var isExpanded = false
    @State private var isPlaying = false
    
    var isSelected: Bool {
        voiceManager.currentVoicePack.id == pack.id
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: { withAnimation(.spring) { isExpanded.toggle() } }) {
                HStack(spacing: 16) {
                    Text(pack.personality.emoji)
                        .font(.title)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pack.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(pack.personality.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Text("ACTIVE")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(appState.currentTheme.accentColor)
                            )
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text(pack.description)
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    // Voice characteristics
                    HStack(spacing: 20) {
                        VoiceStatView(label: "Pitch", value: pack.pitch, icon: "waveform")
                        VoiceStatView(label: "Speed", value: pack.rate, icon: "speedometer")
                        VoiceStatView(label: "Volume", value: pack.volume, icon: "speaker.wave.2.fill")
                    }
                    
                    // Actions
                    HStack {
                        Button(action: {
                            voiceManager.previewVoice(pack)
                        }) {
                            Label("Preview", systemImage: "play.fill")
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        if !isSelected {
                            Button(action: {
                                voiceManager.setVoicePack(pack)
                            }) {
                                Label("Use This Voice", systemImage: "checkmark")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(appState.currentTheme.accentColor)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.2))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? appState.currentTheme.primaryColor.opacity(0.2) : Color.clear)
                .stroke(isSelected ? appState.currentTheme.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct VoiceStatView: View {
    let label: String
    let value: Float
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.gray)
            
            // Visual bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                    
                    Capsule()
                        .fill(Color.orange)
                        .frame(width: geo.size.width * CGFloat(value))
                }
            }
            .frame(height: 4)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(width: 60)
    }
}
