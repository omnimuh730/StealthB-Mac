import SwiftUI
import WebKit

struct BrowserWebView: NSViewRepresentable {
    let state: BrowserState
    let settings: WebViewSettings
    var onOpenNewTab: ((URL) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state, settings: settings, onOpenNewTab: onOpenNewTab)
    }

    func makeNSView(context: Context) -> StealthWKWebView {
        let configuration = WebViewConfigurationFactory.makeConfiguration(settings: settings)

        let webView = StealthWKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        WebViewConfigurationFactory.configure(webView, settings: settings)
        context.coordinator.configure(webView: webView)
        state.attach(webView: webView)
        state.loadURL()

        return webView
    }

    func updateNSView(_ webView: StealthWKWebView, context: Context) {
        context.coordinator.settings = settings
        WebViewConfigurationFactory.configure(webView, settings: settings)
        context.coordinator.applySettings(to: webView)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var state: BrowserState
        var settings: WebViewSettings
        var onOpenNewTab: ((URL) -> Void)?

        init(state: BrowserState, settings: WebViewSettings, onOpenNewTab: ((URL) -> Void)?) {
            self.state = state
            self.settings = settings
            self.onOpenNewTab = onOpenNewTab
        }

        func configure(webView: StealthWKWebView) {
            applySettings(to: webView)
        }

        func applySettings(to webView: StealthWKWebView) {
            WebViewPolicyApplier.apply(settings: settings, to: webView)
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            preferences: WKWebpagePreferences,
            decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
        ) {
            WebViewConfigurationFactory.applyNavigationPreferences(preferences)
            decisionHandler(.allow, preferences)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            state.updateNavigationState()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            WebViewPolicyApplier.apply(settings: settings, to: webView)
            state.updateNavigationState()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            state.updateNavigationState()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            state.updateNavigationState()
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            guard navigationAction.targetFrame == nil else { return nil }

            if let url = navigationAction.request.url, let onOpenNewTab {
                onOpenNewTab(url)
            } else if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
    }
}
