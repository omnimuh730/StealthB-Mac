import AppKit

@Observable
@MainActor
final class WindowFocusGuard {
    static let shared = WindowFocusGuard()

    private(set) var isContentHidden = false

    private var observedWindows = NSHashTable<NSWindow>.weakObjects()
    private var isActive = false

    private init() {}

    func register(window: NSWindow) {
        guard !observedWindows.contains(window) else { return }
        observedWindows.add(window)

        guard !isActive else { return }
        isActive = true

        NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self, let window = notification.object as? NSWindow else { return }
            Task { @MainActor in
                self.handleResignKey(window)
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self, let window = notification.object as? NSWindow else { return }
            Task { @MainActor in
                self.handleBecomeKey(window)
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isContentHidden = true
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                if NSApp.keyWindow != nil {
                    self?.isContentHidden = false
                }
            }
        }
    }

    private func handleResignKey(_ window: NSWindow) {
        guard isBrowserWindow(window) else { return }
        isContentHidden = true
    }

    private func handleBecomeKey(_ window: NSWindow) {
        guard isBrowserWindow(window) else { return }
        isContentHidden = false
    }

    private func isBrowserWindow(_ window: NSWindow) -> Bool {
        observedWindows.contains(window)
    }
}
