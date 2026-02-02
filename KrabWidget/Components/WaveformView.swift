import SwiftUI

struct WaveformView: View {
    let level: Float
    
    @State private var animationPhase: CGFloat = 0
    
    private let barCount = 20
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                WaveformBar(
                    level: level,
                    index: index,
                    phase: animationPhase
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                animationPhase = 2 * .pi
            }
        }
    }
}

struct WaveformBar: View {
    @EnvironmentObject var appState: AppState
    let level: Float
    let index: Int
    let phase: CGFloat
    
    private var normalizedHeight: CGFloat {
        let basePhase = CGFloat(index) / 20.0 * 2 * .pi
        let wave = sin(basePhase + phase) * 0.3 + 0.5
        let levelMultiplier = CGFloat(max(level, 0.1))
        return wave * levelMultiplier
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [
                        appState.currentTheme.accentColor,
                        appState.currentTheme.primaryColor
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 4)
            .frame(height: max(4, 40 * normalizedHeight))
            .animation(.easeInOut(duration: 0.1), value: level)
    }
}

// Alternative circular waveform
struct CircularWaveformView: View {
    @EnvironmentObject var appState: AppState
    let level: Float
    let isListening: Bool
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Outer ring
            ForEach(0..<3, id: \.self) { ring in
                Circle()
                    .stroke(
                        appState.currentTheme.accentColor.opacity(Double(3 - ring) * 0.2),
                        lineWidth: 2
                    )
                    .frame(width: CGFloat(60 + ring * 20), height: CGFloat(60 + ring * 20))
                    .scaleEffect(isListening ? scale + CGFloat(level) * 0.3 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.5 + Double(ring) * 0.1)
                        .repeatForever(autoreverses: true),
                        value: isListening
                    )
            }
            
            // Center icon
            Image(systemName: isListening ? "waveform" : "mic.fill")
                .font(.system(size: 30))
                .foregroundColor(appState.currentTheme.accentColor)
                .rotationEffect(.degrees(rotation))
                .symbolEffect(.variableColor.iterative, isActive: isListening)
        }
        .onAppear {
            if isListening {
                scale = 1.1
            }
        }
    }
}

// Mini waveform for inline use
struct MiniWaveformView: View {
    @EnvironmentObject var appState: AppState
    let level: Float
    
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                let basePhase = CGFloat(index) / 5.0 * 2 * .pi
                let wave = sin(basePhase + animationPhase) * 0.3 + 0.5
                let height = max(4, 16 * wave * CGFloat(max(level, 0.2)))
                
                RoundedRectangle(cornerRadius: 1)
                    .fill(appState.currentTheme.accentColor)
                    .frame(width: 2, height: height)
            }
        }
        .frame(height: 16)
        .onAppear {
            withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: false)) {
                animationPhase = 2 * .pi
            }
        }
    }
}

// Audio level indicator
struct AudioLevelIndicator: View {
    @EnvironmentObject var appState: AppState
    let level: Float
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                
                // Level fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: levelColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(level))
                    .animation(.easeOut(duration: 0.1), value: level)
            }
        }
        .frame(height: 6)
    }
    
    private var levelColors: [Color] {
        if level > 0.8 {
            return [.orange, .red]
        } else if level > 0.5 {
            return [.green, .orange]
        } else {
            return [appState.currentTheme.accentColor, .green]
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        WaveformView(level: 0.5)
            .frame(height: 50)
        
        CircularWaveformView(level: 0.5, isListening: true)
            .frame(width: 150, height: 150)
        
        MiniWaveformView(level: 0.5)
        
        AudioLevelIndicator(level: 0.6)
            .frame(width: 200)
    }
    .padding()
    .background(Color.black)
    .environmentObject(AppState.shared)
}
