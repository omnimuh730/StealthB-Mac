import AppKit

@MainActor
enum StealthWindowManager {
    private static var isActive = false

    static func activate() {
        guard !isActive else { return }
        isActive = true

        let center = NotificationCenter.default

        center.addObserver(
            forName: NSApplication.didFinishLaunchingNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                applyToAllWindows()
            }
        }
        center.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let window = notification.object as? NSWindow else { return }
            Task { @MainActor in
                applyStealth(to: window)
            }
        }
        center.addObserver(
            forName: NSWindow.didBecomeMainNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let window = notification.object as? NSWindow else { return }
            Task { @MainActor in
                applyStealth(to: window)
            }
        }
        center.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                applyToAllWindows()
            }
        }
    }

    static func applyToAllWindows() {
        guard NSApp.isRunning else { return }

        for window in NSApp.windows {
            applyStealth(to: window)
        }
    }

    static func applyStealth(to window: NSWindow) {
        window.sharingType = .none
    }
}
