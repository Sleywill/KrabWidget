import Foundation
import SwiftUI
import Combine

class ModularWindowManager: ObservableObject {
    @Published var windowConfigs: [WidgetWindowConfig] = []
    @Published var layouts: [String: [WidgetWindowConfig]] = [:]
    @Published var currentLayoutName: String = "Default"
    
    private let userDefaultsKey = "krabWidgetConfigs"
    private let layoutsKey = "krabWidgetLayouts"
    
    init() {
        loadConfigs()
        loadLayouts()
        
        // Create default chat window if none exist
        if windowConfigs.isEmpty {
            addWindow(type: .chat, title: "🦀 Krab Chat")
        }
    }
    
    func addWindow(type: WidgetType, title: String) {
        let config = WidgetWindowConfig(
            type: type,
            title: title,
            position: CGPoint(x: CGFloat.random(in: 100...400), y: CGFloat.random(in: 100...400)),
            size: defaultSize(for: type)
        )
        windowConfigs.append(config)
        saveConfigs()
    }
    
    func removeWindow(id: UUID) {
        windowConfigs.removeAll { $0.id == id }
        saveConfigs()
    }
    
    func updateWindow(_ config: WidgetWindowConfig) {
        if let index = windowConfigs.firstIndex(where: { $0.id == config.id }) {
            windowConfigs[index] = config
            saveConfigs()
        }
    }
    
    func toggleWindowVisibility(id: UUID) {
        if let index = windowConfigs.firstIndex(where: { $0.id == id }) {
            windowConfigs[index].isVisible.toggle()
            saveConfigs()
        }
    }
    
    private func defaultSize(for type: WidgetType) -> CGSize {
        switch type {
        case .chat:
            return CGSize(width: 380, height: 500)
        case .quickActions:
            return CGSize(width: 300, height: 250)
        case .commandOutput:
            return CGSize(width: 400, height: 300)
        case .customInfo:
            return CGSize(width: 300, height: 200)
        }
    }
    
    // MARK: - Layout Management
    
    func saveCurrentLayout(name: String) {
        layouts[name] = windowConfigs
        currentLayoutName = name
        saveLayouts()
    }
    
    func loadLayout(name: String) {
        if let layoutConfigs = layouts[name] {
            windowConfigs = layoutConfigs
            currentLayoutName = name
            saveConfigs()
        }
    }
    
    func deleteLayout(name: String) {
        layouts.removeValue(forKey: name)
        saveLayouts()
    }
    
    // MARK: - Persistence
    
    private func saveConfigs() {
        if let data = try? JSONEncoder().encode(windowConfigs) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func loadConfigs() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let configs = try? JSONDecoder().decode([WidgetWindowConfig].self, from: data) {
            windowConfigs = configs
        }
    }
    
    private func saveLayouts() {
        if let data = try? JSONEncoder().encode(layouts) {
            UserDefaults.standard.set(data, forKey: layoutsKey)
        }
    }
    
    private func loadLayouts() {
        if let data = UserDefaults.standard.data(forKey: layoutsKey),
           let savedLayouts = try? JSONDecoder().decode([String: [WidgetWindowConfig]].self, from: data) {
            layouts = savedLayouts
        }
    }
    
    // MARK: - Preset Layouts
    
    func applyPreset(_ preset: LayoutPreset) {
        windowConfigs.removeAll()
        
        switch preset {
        case .minimal:
            addWindow(type: .chat, title: "🦀 Krab Chat")
            
        case .productive:
            addWindow(type: .chat, title: "🦀 Krab Chat")
            addWindow(type: .quickActions, title: "⚡ Quick Actions")
            addWindow(type: .commandOutput, title: "📟 Terminal")
            
        case .fullSetup:
            addWindow(type: .chat, title: "🦀 Krab Chat")
            addWindow(type: .quickActions, title: "⚡ Quick Actions")
            addWindow(type: .commandOutput, title: "📟 Terminal")
            addWindow(type: .customInfo, title: "📋 Notes")
        }
        
        saveConfigs()
    }
}

enum LayoutPreset: String, CaseIterable {
    case minimal = "Minimal"
    case productive = "Productive"
    case fullSetup = "Full Setup"
    
    var description: String {
        switch self {
        case .minimal: return "Just the chat window"
        case .productive: return "Chat + Quick Actions + Terminal"
        case .fullSetup: return "Everything enabled"
        }
    }
    
    var icon: String {
        switch self {
        case .minimal: return "rectangle"
        case .productive: return "rectangle.split.2x1"
        case .fullSetup: return "rectangle.split.2x2"
        }
    }
}
