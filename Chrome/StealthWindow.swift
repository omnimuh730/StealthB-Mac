import AppKit
import SwiftUI

extension View {
    /// Prevents this window from appearing in screen recordings, screenshots, and capture tools like OBS.
    func stealthWindow() -> some View {
        background(StealthWindowAccessor())
    }
}

private struct StealthWindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        applyWindowConfiguration(to: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        applyWindowConfiguration(to: nsView)
    }

    private func applyWindowConfiguration(to view: NSView) {
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            StealthWindowManager.applyStealth(to: window)
            WindowFocusGuard.shared.register(window: window)
            window.alphaValue = WindowController.shared.windowOpacity
        }
    }
}
