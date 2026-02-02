import Foundation
import SwiftUI
import Combine

// MARK: - Notification Manager
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var activeNotifications: [KrabNotification] = []
    @Published var notificationQueue: [KrabNotification] = []
    @Published var isShowingNotification = false
    
    private var displayTimer: Timer?
    private let maxVisibleNotifications = 3
    private let defaultDisplayDuration: TimeInterval = 5.0
    
    private init() {}
    
    // MARK: - Public Methods
    
    func push(_ notification: KrabNotification) {
        DispatchQueue.main.async {
            if self.activeNotifications.count < self.maxVisibleNotifications {
                self.showNotification(notification)
            } else {
                self.notificationQueue.append(notification)
            }
        }
    }
    
    func pushMultiple(_ notifications: [KrabNotification]) {
        notifications.forEach { push($0) }
    }
    
    func dismiss(_ id: UUID) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            activeNotifications.removeAll { $0.id == id }
        }
        
        // Show next in queue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.processQueue()
        }
    }
    
    func dismissAll() {
        withAnimation(.spring(response: 0.3)) {
            activeNotifications.removeAll()
            notificationQueue.removeAll()
        }
    }
    
    // MARK: - Convenience Methods
    
    func showNews(_ title: String, _ body: String, icon: String = "newspaper.fill") {
        push(KrabNotification(
            type: .news,
            title: title,
            body: body,
            icon: icon,
            color: .blue
        ))
    }
    
    func showRecommendation(_ title: String, _ body: String) {
        push(KrabNotification(
            type: .recommendation,
            title: title,
            body: body,
            icon: "sparkles",
            color: .purple
        ))
    }
    
    func showAlert(_ title: String, _ body: String) {
        push(KrabNotification(
            type: .alert,
            title: title,
            body: body,
            icon: "exclamationmark.triangle.fill",
            color: .orange,
            priority: .high,
            autoDismiss: false
        ))
    }
    
    func showSuccess(_ title: String, _ body: String) {
        push(KrabNotification(
            type: .success,
            title: title,
            body: body,
            icon: "checkmark.circle.fill",
            color: .green
        ))
    }
    
    func showCrabMessage(_ message: String) {
        push(KrabNotification(
            type: .crabMessage,
            title: "🦀 Krab says:",
            body: message,
            icon: "bubble.left.fill",
            color: .orange
        ))
    }
    
    func showDailyTip() {
        let tips = [
            ("💡 Pro Tip", "Say 'Hey Krab, surprise me!' for a random fun fact!"),
            ("🎯 Did you know?", "You can customize my voice in Settings → Voice Packs!"),
            ("⌨️ Shortcut", "Press ⌘⌥Space to toggle voice listening anytime!"),
            ("🦀 Crab Fact", "Crabs can walk in all directions, but prefer sideways!"),
            ("🎨 Style Tip", "Try different themes in Settings → Appearance!"),
            ("📱 Telegram", "Connect Telegram to receive messages with voice notifications!"),
            ("🎤 Voice Tip", "Speak clearly and pause briefly when done for best recognition!"),
            ("🪟 Windows", "Drag windows anywhere! They remember their position!"),
        ]
        
        let tip = tips.randomElement()!
        push(KrabNotification(
            type: .tip,
            title: tip.0,
            body: tip.1,
            icon: "lightbulb.fill",
            color: .yellow
        ))
    }
    
    // MARK: - Private Methods
    
    private func showNotification(_ notification: KrabNotification) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            activeNotifications.append(notification)
            isShowingNotification = true
        }
        
        // Auto-dismiss if enabled
        if notification.autoDismiss {
            let duration = notification.displayDuration ?? defaultDisplayDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                self?.dismiss(notification.id)
            }
        }
        
        // Play sound if enabled
        if notification.playSound {
            NSSound.beep()
        }
    }
    
    private func processQueue() {
        guard !notificationQueue.isEmpty,
              activeNotifications.count < maxVisibleNotifications else { return }
        
        let next = notificationQueue.removeFirst()
        showNotification(next)
    }
}

// MARK: - Notification Model
struct KrabNotification: Identifiable, Equatable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let body: String
    let icon: String
    let color: Color
    let priority: NotificationPriority
    let autoDismiss: Bool
    let displayDuration: TimeInterval?
    let playSound: Bool
    let action: NotificationAction?
    let timestamp: Date
    
    init(
        type: NotificationType,
        title: String,
        body: String,
        icon: String = "bell.fill",
        color: Color = .blue,
        priority: NotificationPriority = .normal,
        autoDismiss: Bool = true,
        displayDuration: TimeInterval? = nil,
        playSound: Bool = true,
        action: NotificationAction? = nil
    ) {
        self.type = type
        self.title = title
        self.body = body
        self.icon = icon
        self.color = color
        self.priority = priority
        self.autoDismiss = autoDismiss
        self.displayDuration = displayDuration
        self.playSound = playSound
        self.action = action
        self.timestamp = Date()
    }
    
    static func == (lhs: KrabNotification, rhs: KrabNotification) -> Bool {
        lhs.id == rhs.id
    }
}

enum NotificationType: String, Codable {
    case news
    case recommendation
    case alert
    case success
    case tip
    case crabMessage
    case telegram
    case system
}

enum NotificationPriority: Int, Codable {
    case low = 0
    case normal = 1
    case high = 2
    case urgent = 3
}

struct NotificationAction: Equatable {
    let label: String
    let action: () -> Void
    
    static func == (lhs: NotificationAction, rhs: NotificationAction) -> Bool {
        lhs.label == rhs.label
    }
}

// MARK: - Notification View
struct NotificationPopupView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var notificationManager = NotificationManager.shared
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            ForEach(notificationManager.activeNotifications) { notification in
                NotificationCard(notification: notification)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .padding()
        .frame(maxWidth: 350, alignment: .trailing)
    }
}

struct NotificationCard: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var notificationManager = NotificationManager.shared
    let notification: KrabNotification
    
    @State private var isHovered = false
    @State private var appearAnimation = false
    @State private var iconBounce = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon with animation
            ZStack {
                Circle()
                    .fill(notification.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: notification.icon)
                    .font(.system(size: 20))
                    .foregroundColor(notification.color)
                    .scaleEffect(iconBounce ? 1.2 : 1.0)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(notification.body)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Dismiss button
            Button(action: { notificationManager.dismiss(notification.id) }) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(6)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1 : 0.5)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(notification.color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: notification.color.opacity(0.3), radius: isHovered ? 15 : 8)
        )
        .scaleEffect(appearAnimation ? 1.0 : 0.9)
        .opacity(appearAnimation ? 1.0 : 0)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appearAnimation = true
            }
            
            // Icon bounce animation
            withAnimation(.spring(response: 0.3).delay(0.2)) {
                iconBounce = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.3)) {
                    iconBounce = false
                }
            }
        }
        .onTapGesture {
            if let action = notification.action {
                action.action()
            }
            notificationManager.dismiss(notification.id)
        }
    }
}
