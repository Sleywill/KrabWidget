import SwiftUI
import AppKit

// MARK: - Glass Card Modifier
struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Blur effect
                    VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                    
                    // Color overlay
                    Color.black.opacity(0.3)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, opacity: Double = 0.8) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}

// MARK: - Visual Effect Blur (macOS)
struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @EnvironmentObject var appState: AppState
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                appState.currentTheme.backgroundColor,
                appState.currentTheme.primaryColor.opacity(0.5),
                appState.currentTheme.accentColor.opacity(0.3)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Glowing Button Style
struct GlowingButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                ZStack {
                    // Glow
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .blur(radius: configuration.isPressed ? 5 : 10)
                        .opacity(configuration.isPressed ? 0.8 : 0.5)
                    
                    // Button
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.8))
                }
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + phase * geo.size.width * 2)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Pulsing Circle
struct PulsingCircle: View {
    @EnvironmentObject var appState: AppState
    let isActive: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.5
    
    var body: some View {
        Circle()
            .fill(appState.currentTheme.accentColor)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    scale = 1.3
                    opacity = 0.2
                }
            }
    }
}

// MARK: - Floating Card Effect
struct FloatingCardModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    offset = -5
                }
            }
    }
}

extension View {
    func floating() -> some View {
        modifier(FloatingCardModifier())
    }
}

// MARK: - Neon Text
struct NeonTextModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .shadow(color: color.opacity(0.8), radius: 2)
            .shadow(color: color.opacity(0.6), radius: 5)
            .shadow(color: color.opacity(0.4), radius: 10)
    }
}

extension View {
    func neonGlow(_ color: Color) -> some View {
        modifier(NeonTextModifier(color: color))
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Glass Card")
            .padding()
            .glassCard()
        
        Text("Shimmer Effect")
            .font(.title)
            .shimmer()
        
        Text("NEON")
            .font(.largeTitle.bold())
            .neonGlow(.cyan)
        
        Button("Glowing Button") {}
            .buttonStyle(GlowingButtonStyle(color: .orange))
    }
    .padding()
    .frame(width: 400, height: 400)
    .background(Color.black)
    .environmentObject(AppState.shared)
}
