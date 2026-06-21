import WebKit

enum WebViewConfigurationFactory {
    /// Builds a WKWebViewConfiguration using the system WebKit engine (same core as Safari on this Mac).
    static func makeConfiguration(settings: WebViewSettings) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.processPool = WKProcessPool()
        configuration.applicationNameForUserAgent = "StealthBrowser"

        let preferences = configuration.preferences
        preferences.isElementFullscreenEnabled = true
        preferences.tabFocusesLinks = true
        preferences.isFraudulentWebsiteWarningEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = settings.allowPopups

        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        if #available(macOS 13.3, *) {
            pagePreferences.preferredContentMode = .recommended
        }
        configuration.defaultWebpagePreferences = pagePreferences

        if #available(macOS 14.0, *) {
            configuration.preferences.shouldPrintBackgrounds = true
        }

        let dragDropScript = WKUserScript(
            source: WebViewDragDropScript.bootstrap,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(dragDropScript)

        return configuration
    }

    static func configure(_ webView: StealthWKWebView, settings: WebViewSettings) {
        webView.customUserAgent = nil
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = settings.allowPopups

        #if DEBUG
        webView.isInspectable = true
        #endif
    }
}

enum WebEngineInfo {
    static let engineName = "WebKit (system)"

    static var platformDescription: String {
        let version = ProcessInfo.processInfo.operatingSystemVersionString
        return "macOS \(version)"
    }

    static func fetchUserAgent(from webView: WKWebView) async -> String? {
        await withCheckedContinuation { continuation in
            webView.evaluateJavaScript("navigator.userAgent") { result, _ in
                continuation.resume(returning: result as? String)
            }
        }
    }
}
