import SwiftUI
import WebKit

struct BrowserWebView: NSViewRepresentable {
    let state: BrowserState
    let settings: WebViewSettings

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state, settings: settings)
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

        init(state: BrowserState, settings: WebViewSettings) {
            self.state = state
            self.settings = settings
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
            // Single-window browser: load target=_blank / new-window links in this view.
            // Popup setting only controls automatic JS window.open(), not user link clicks.
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
