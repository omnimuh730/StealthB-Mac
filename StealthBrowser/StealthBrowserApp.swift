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
            CommandGroup(replacing: .newItem) {}
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
