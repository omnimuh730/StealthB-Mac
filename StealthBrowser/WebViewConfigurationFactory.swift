import WebKit

enum WebViewConfigurationFactory {
    /// Builds a WKWebViewConfiguration tuned for desktop site compatibility on macOS Sequoia.
    static func makeConfiguration(settings: WebViewSettings) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.processPool = WKProcessPool()
        configuration.limitsNavigationsToAppBoundDomains = false

        if #available(macOS 14.0, *) {
            configuration.upgradeKnownHostsToHTTPS = true
        }

        let preferences = configuration.preferences
        preferences.isElementFullscreenEnabled = true
        preferences.tabFocusesLinks = true
        preferences.isFraudulentWebsiteWarningEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = settings.allowPopups
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        if #available(macOS 13.0, *) {
            preferences.isSiteSpecificQuirksModeEnabled = true
        }

        if #available(macOS 14.0, *) {
            preferences.isTextInteractionEnabled = true
        }

        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        if #available(macOS 13.3, *) {
            pagePreferences.preferredContentMode = .desktop
        }
        configuration.defaultWebpagePreferences = pagePreferences

        let dragDropScript = WKUserScript(
            source: WebViewDragDropScript.bootstrap,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(dragDropScript)

        return configuration
    }

    static func configure(_ webView: StealthWKWebView, settings: WebViewSettings) {
        webView.customUserAgent = SafariUserAgent.desktop
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = settings.allowPopups
        webView.allowsLinkPreview = settings.allowTooltips

        #if DEBUG
        webView.isInspectable = true
        #endif
    }

    static func applyNavigationPreferences(_ preferences: WKWebpagePreferences) {
        preferences.allowsContentJavaScript = true
        if #available(macOS 13.3, *) {
            preferences.preferredContentMode = .desktop
        }
    }
}

enum WebEngineInfo {
    static let engineName = "WKWebView (Safari WebKit)"

    static var platformDescription: String {
        "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
    }

    static func fetchUserAgent(from webView: WKWebView) async -> String? {
        await withCheckedContinuation { continuation in
            webView.evaluateJavaScript("navigator.userAgent") { result, _ in
                continuation.resume(returning: result as? String)
            }
        }
    }
}

@MainActor
enum WebViewPolicyApplier {
    static func apply(settings: WebViewSettings, to webView: WKWebView) {
        if let stealthWebView = webView as? StealthWKWebView {
            stealthWebView.allowsDragAndDrop = settings.allowDragAndDrop
        }

        webView.customUserAgent = SafariUserAgent.desktop
        webView.allowsLinkPreview = settings.allowTooltips
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = settings.allowPopups

        let tooltipScript = settings.allowTooltips
            ? WebViewPolicyScript.enableTooltips
            : WebViewPolicyScript.disableTooltips
        webView.evaluateJavaScript(tooltipScript, completionHandler: nil)
    }
}
