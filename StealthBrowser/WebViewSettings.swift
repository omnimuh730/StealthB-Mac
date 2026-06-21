import Foundation

@Observable
@MainActor
final class WebViewSettings {
    static let shared = WebViewSettings()

    var allowPopups: Bool {
        didSet { save() }
    }

    var allowDragAndDrop: Bool {
        didSet { save() }
    }

    var allowTooltips: Bool {
        didSet { save() }
    }

    private enum Keys {
        static let allowPopups = "webview.allowPopups"
        static let allowDragAndDrop = "webview.allowDragAndDrop"
        static let allowTooltips = "webview.allowTooltips"
    }

    private init() {
        let defaults = UserDefaults.standard
        allowPopups = defaults.object(forKey: Keys.allowPopups) as? Bool ?? false
        allowDragAndDrop = defaults.object(forKey: Keys.allowDragAndDrop) as? Bool ?? false
        allowTooltips = defaults.object(forKey: Keys.allowTooltips) as? Bool ?? false
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(allowPopups, forKey: Keys.allowPopups)
        defaults.set(allowDragAndDrop, forKey: Keys.allowDragAndDrop)
        defaults.set(allowTooltips, forKey: Keys.allowTooltips)
    }
}
