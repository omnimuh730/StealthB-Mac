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
        NSApp.keyWindow?.orderOut(nil)
    }

    func showWindow() {
        let browserWindow = NSApp.windows.first { window in
            window.canBecomeKey && window.title != "Settings"
        } ?? NSApp.windows.first { $0.canBecomeKey }

        browserWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        applyOpacity()
    }

    func quit() {
        NSApp.terminate(nil)
    }
}
