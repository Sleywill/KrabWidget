import SwiftUI
import AppKit
import Combine

@main
struct KrabWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appState.speechManager)
                .environmentObject(appState.voiceManager)
                .environmentObject(appState.telegramManager)
                .environmentObject(appState.windowManager)
                .environmentObject(appState.hotkeyManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        Settings {
            SettingsView()
                .environmentObject(appState)
                .environmentObject(appState.voiceManager)
                .environmentObject(appState.telegramManager)
                .environmentObject(appState.hotkeyManager)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        HotkeyManager.shared.registerGlobalHotkeys()
        
        // Make windows float above others
        NSApp.windows.forEach { window in
            window.level = .floating
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = true
        }
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "waveform.circle.fill", accessibilityDescription: "KrabWidget")
            button.image?.isTemplate = true
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "🦀 KrabWidget", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Toggle Listening", action: #selector(toggleListening), keyEquivalent: "l"))
        menu.addItem(NSMenuItem(title: "New Chat Window", action: #selector(openChatWindow), keyEquivalent: "n"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func toggleListening() {
        if AppState.shared.speechManager.isListening {
            AppState.shared.speechManager.stopListening()
        } else {
            AppState.shared.speechManager.startListening()
        }
    }
    
    @objc func openChatWindow() {
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}

// MARK: - App State
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isOnboardingComplete: Bool {
        didSet { UserDefaults.standard.set(isOnboardingComplete, forKey: "onboardingComplete") }
    }
    @Published var currentTheme: KrabTheme = .deepOcean
    
    let speechManager = SpeechManager()
    let voiceManager = VoiceManager()
    let telegramManager = TelegramManager()
    let windowManager = ModularWindowManager()
    let hotkeyManager = HotkeyManager.shared
    
    var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboardingComplete")
    }
}

// MARK: - Themes
enum KrabTheme: String, CaseIterable {
    case deepOcean = "Deep Ocean"
    case coralReef = "Coral Reef"
    case midnight = "Midnight"
    case sunset = "Sunset"
    
    var primaryColor: Color {
        switch self {
        case .deepOcean: return Color(red: 0.1, green: 0.4, blue: 0.6)
        case .coralReef: return Color(red: 0.9, green: 0.4, blue: 0.3)
        case .midnight: return Color(red: 0.2, green: 0.2, blue: 0.4)
        case .sunset: return Color(red: 0.9, green: 0.5, blue: 0.2)
        }
    }
    
    var accentColor: Color {
        switch self {
        case .deepOcean: return Color(red: 0.3, green: 0.7, blue: 0.9)
        case .coralReef: return Color(red: 1.0, green: 0.6, blue: 0.5)
        case .midnight: return Color(red: 0.5, green: 0.5, blue: 0.8)
        case .sunset: return Color(red: 1.0, green: 0.7, blue: 0.3)
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .deepOcean: return Color(red: 0.05, green: 0.1, blue: 0.15)
        case .coralReef: return Color(red: 0.15, green: 0.1, blue: 0.1)
        case .midnight: return Color(red: 0.08, green: 0.08, blue: 0.12)
        case .sunset: return Color(red: 0.12, green: 0.08, blue: 0.05)
        }
    }
}
