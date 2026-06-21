import AppKit

@Observable
@MainActor
final class WindowController {
    static let shared = WindowController()

    private(set) var windowOpacity: Double = 1.0

    private let minOpacity = 0.0
    private let maxOpacity = 1.0
    private let step = 0.1

    private init() {}

    func adjustOpacity(delta: Double) {
        windowOpacity = min(maxOpacity, max(minOpacity, windowOpacity + delta))
        applyOpacity()
    }

    func moreTransparent() {
        adjustOpacity(delta: -step)
    }

    func lessTransparent() {
        adjustOpacity(delta: step)
    }

    func applyOpacity() {
        guard NSApp.isRunning else { return }
        for window in NSApp.windows where window.isVisible {
            window.alphaValue = windowOpacity
        }
    }

    func hideWindow() {
        for window in NSApp.windows where isBrowserWindow(window) {
            window.orderOut(nil)
        }
    }

    func showWindow() {
        let browserWindow = NSApp.windows.first(where: isBrowserWindow)
            ?? NSApp.windows.first { $0.canBecomeKey }

        browserWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        applyOpacity()
    }

    private func isBrowserWindow(_ window: NSWindow) -> Bool {
        window.canBecomeKey && window.title != "Settings"
    }

    func quit() {
        NSApp.terminate(nil)
    }
}
