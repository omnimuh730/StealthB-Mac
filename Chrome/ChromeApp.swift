import SwiftUI

@main
struct ChromeApp: App {
    init() {
        StealthWindowManager.activate()
        GlobalHotkeyManager.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Tab") {
                    NotificationCenter.default.post(name: .stealthNewTab, object: nil)
                }
                .keyboardShortcut("t", modifiers: .command)
            }

            CommandMenu("Stealth") {
                Button("More Transparent") {
                    WindowController.shared.moreTransparent()
                }
                .keyboardShortcut("i", modifiers: .control)

                Button("Less Transparent") {
                    WindowController.shared.lessTransparent()
                }
                .keyboardShortcut("k", modifiers: .control)

                Divider()

                Button("Hide Window") {
                    WindowController.shared.hideWindow()
                }
                .keyboardShortcut(";", modifiers: .control)

                Button("Show Window") {
                    WindowController.shared.showWindow()
                }
                .keyboardShortcut("'", modifiers: .control)

                Divider()

                Button("Quit Chrome") {
                    WindowController.shared.quit()
                }
                .keyboardShortcut("u", modifiers: .control)
            }
        }

        Settings {
            WebViewSettingsView()
                .stealthWindow()
                .onAppear {
                    StealthWindowManager.applyToAllWindows()
                }
        }
    }
}

extension Notification.Name {
    static let stealthNewTab = Notification.Name("stealthNewTab")
}
