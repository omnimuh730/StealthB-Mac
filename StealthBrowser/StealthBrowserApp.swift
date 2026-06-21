import SwiftUI

@main
struct StealthBrowserApp: App {
    init() {
        StealthWindowManager.activate()
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
                .keyboardShortcut("i", modifiers: .command)

                Button("Less Transparent") {
                    WindowController.shared.lessTransparent()
                }
                .keyboardShortcut("k", modifiers: .command)

                Divider()

                Button("Hide Window") {
                    WindowController.shared.hideWindow()
                }
                .keyboardShortcut(";", modifiers: .command)

                Button("Show Window") {
                    WindowController.shared.showWindow()
                }
                .keyboardShortcut("'", modifiers: .command)

                Divider()

                Button("Quit StealthBrowser") {
                    WindowController.shared.quit()
                }
                .keyboardShortcut("u", modifiers: .command)
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
