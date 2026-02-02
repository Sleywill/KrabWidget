import Foundation
import Carbon
import AppKit
import Combine

class HotkeyManager: ObservableObject {
    static let shared = HotkeyManager()
    
    @Published var isListeningHotkeyPressed = false
    @Published var currentHotkey: HotkeyCombo = .default
    
    private var eventHandler: EventHandlerRef?
    private var hotkeyRef: EventHotKeyRef?
    
    struct HotkeyCombo: Codable, Equatable {
        var keyCode: UInt32
        var modifiers: UInt32
        
        static let `default` = HotkeyCombo(keyCode: UInt32(kVK_Space), modifiers: UInt32(cmdKey | optionKey))
        
        var displayString: String {
            var parts: [String] = []
            
            if modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
            if modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
            if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
            if modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
            
            // Key name
            switch Int(keyCode) {
            case kVK_Space: parts.append("Space")
            case kVK_Return: parts.append("Return")
            case kVK_ANSI_K: parts.append("K")
            case kVK_ANSI_L: parts.append("L")
            case kVK_ANSI_M: parts.append("M")
            default: parts.append("Key \(keyCode)")
            }
            
            return parts.joined(separator: " + ")
        }
    }
    
    private init() {
        loadHotkey()
    }
    
    func registerGlobalHotkeys() {
        unregisterHotkeys()
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        let handlerBlock: EventHandlerUPP = { (nextHandler, event, userData) -> OSStatus in
            var hotkeyID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotkeyID)
            
            if hotkeyID.id == 1 {
                DispatchQueue.main.async {
                    HotkeyManager.shared.hotkeyTriggered()
                }
            }
            
            return noErr
        }
        
        InstallEventHandler(GetApplicationEventTarget(), handlerBlock, 1, &eventType, nil, &eventHandler)
        
        var hotkeyID = EventHotKeyID(signature: OSType(0x4B524142), id: 1) // "KRAB"
        
        RegisterEventHotKey(currentHotkey.keyCode, currentHotkey.modifiers, hotkeyID, GetApplicationEventTarget(), 0, &hotkeyRef)
    }
    
    func unregisterHotkeys() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
    }
    
    private func hotkeyTriggered() {
        isListeningHotkeyPressed = true
        
        // Toggle listening on the speech manager
        NotificationCenter.default.post(name: .hotkeyPressed, object: nil)
        
        // Reset after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isListeningHotkeyPressed = false
        }
    }
    
    func setHotkey(_ combo: HotkeyCombo) {
        currentHotkey = combo
        saveHotkey()
        registerGlobalHotkeys()
    }
    
    private func saveHotkey() {
        if let data = try? JSONEncoder().encode(currentHotkey) {
            UserDefaults.standard.set(data, forKey: "krabHotkey")
        }
    }
    
    private func loadHotkey() {
        if let data = UserDefaults.standard.data(forKey: "krabHotkey"),
           let combo = try? JSONDecoder().decode(HotkeyCombo.self, from: data) {
            currentHotkey = combo
        }
    }
    
    // MARK: - Preset Hotkeys
    
    static let presets: [HotkeyCombo] = [
        HotkeyCombo(keyCode: UInt32(kVK_Space), modifiers: UInt32(cmdKey | optionKey)),  // ⌘⌥Space
        HotkeyCombo(keyCode: UInt32(kVK_ANSI_K), modifiers: UInt32(cmdKey | shiftKey)),  // ⌘⇧K
        HotkeyCombo(keyCode: UInt32(kVK_ANSI_L), modifiers: UInt32(cmdKey | optionKey)), // ⌘⌥L
        HotkeyCombo(keyCode: UInt32(kVK_Return), modifiers: UInt32(cmdKey | controlKey)) // ⌘⌃Return
    ]
}

extension Notification.Name {
    static let hotkeyPressed = Notification.Name("krabHotkeyPressed")
}
