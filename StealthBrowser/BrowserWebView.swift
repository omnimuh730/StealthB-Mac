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
            webView.allowsDragAndDrop = settings.allowDragAndDrop
            webView.allowsLinkPreview = settings.allowTooltips
            applyTooltipPolicy(to: webView)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            state.updateNavigationState()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            applyTooltipPolicy(to: webView)
            if let stealthWebView = webView as? StealthWKWebView {
                stealthWebView.applyDragAndDropPolicy()
            }
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
            guard settings.allowPopups else { return nil }

            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        private func applyTooltipPolicy(to webView: WKWebView) {
            let script: String
            if settings.allowTooltips {
                script = """
                (function() {
                    if (window.__stealthTooltipObserver) {
                        window.__stealthTooltipObserver.disconnect();
                        window.__stealthTooltipObserver = null;
                    }
                })();
                """
            } else {
                script = """
                (function() {
                    document.querySelectorAll('[title]').forEach(function(element) {
                        element.removeAttribute('title');
                    });
                    if (window.__stealthTooltipObserver) {
                        window.__stealthTooltipObserver.disconnect();
                    }
                    window.__stealthTooltipObserver = new MutationObserver(function() {
                        document.querySelectorAll('[title]').forEach(function(element) {
                            element.removeAttribute('title');
                        });
                    });
                    window.__stealthTooltipObserver.observe(document.documentElement, {
                        subtree: true,
                        childList: true,
                        attributes: true,
                        attributeFilter: ['title']
                    });
                })();
                """
            }

            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}
