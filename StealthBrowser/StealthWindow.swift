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
        applyStealth(to: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        applyStealth(to: nsView)
    }

    private func applyStealth(to view: NSView) {
        DispatchQueue.main.async {
            view.window?.sharingType = .none
        }
    }
}
