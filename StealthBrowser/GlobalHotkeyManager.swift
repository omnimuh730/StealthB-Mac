import AppKit
import Carbon
import Carbon.HIToolbox

@MainActor
final class GlobalHotkeyManager {
    static let shared = GlobalHotkeyManager()

    private enum HotkeyID: UInt32 {
        case moreTransparent = 1
        case lessTransparent = 2
        case hideWindow = 3
        case showWindow = 4
        case quit = 5
    }

    private var hotKeyRefs: [EventHotKeyRef] = []
    private var eventHandlerRef: EventHandlerRef?
    private var isActive = false

    private let signature: OSType = 0x5354_4C42 // "STLB"

    private init() {}

    func activate() {
        guard !isActive else { return }
        isActive = true
        installHandler()
        registerHotkeys()
    }

    private func installHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            Self.eventHandler,
            1,
            &eventType,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            &eventHandlerRef
        )

        if status != noErr {
            NSLog("GlobalHotkeyManager: InstallEventHandler failed (\(status))")
        }
    }

    private func registerHotkeys() {
        register(keyCode: UInt32(kVK_ANSI_I), modifiers: UInt32(controlKey), id: .moreTransparent)
        register(keyCode: UInt32(kVK_ANSI_K), modifiers: UInt32(controlKey), id: .lessTransparent)
        register(keyCode: UInt32(kVK_ANSI_Semicolon), modifiers: UInt32(controlKey), id: .hideWindow)
        register(keyCode: UInt32(kVK_ANSI_Quote), modifiers: UInt32(controlKey), id: .showWindow)
        register(keyCode: UInt32(kVK_ANSI_U), modifiers: UInt32(controlKey), id: .quit)
    }

    private func register(keyCode: UInt32, modifiers: UInt32, id: HotkeyID) {
        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: signature, id: id.rawValue)

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status == noErr, let hotKeyRef {
            hotKeyRefs.append(hotKeyRef)
        } else {
            NSLog("GlobalHotkeyManager: RegisterEventHotKey failed for \(id) (\(status))")
        }
    }

    fileprivate func handleHotkey(id: UInt32) {
        switch HotkeyID(rawValue: id) {
        case .moreTransparent:
            WindowController.shared.moreTransparent()
        case .lessTransparent:
            WindowController.shared.lessTransparent()
        case .hideWindow:
            WindowController.shared.hideWindow()
        case .showWindow:
            WindowController.shared.showWindow()
        case .quit:
            WindowController.shared.quit()
        case nil:
            break
        }
    }

    private static let eventHandler: EventHandlerUPP = { _, event, userData -> OSStatus in
        guard let event else { return OSStatus(eventNotHandledErr) }

        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        guard status == noErr else { return status }

        let manager = Unmanaged<GlobalHotkeyManager>.fromOpaque(userData!).takeUnretainedValue()
        Task { @MainActor in
            manager.handleHotkey(id: hotKeyID.id)
        }

        return noErr
    }
}
