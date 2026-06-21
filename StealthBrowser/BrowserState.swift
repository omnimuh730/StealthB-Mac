import WebKit

@Observable
@MainActor
final class BrowserState {
    var urlString = "https://duckduckgo.com"
    var canGoBack = false
    var canGoForward = false
    var isLoading = false
    var title = "Stealth Browser"

    private(set) weak var webView: WKWebView?

    func attach(webView: WKWebView) {
        self.webView = webView
    }

    func loadURL() {
        guard let webView else { return }
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let url = URL(string: trimmed), url.scheme != nil {
            webView.load(URLRequest(url: url))
            return
        }

        let withScheme = "https://\(trimmed)"
        guard let url = URL(string: withScheme) else { return }
        urlString = withScheme
        webView.load(URLRequest(url: url))
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        webView?.reload()
    }

    func stopLoading() {
        webView?.stopLoading()
    }

    func updateNavigationState() {
        canGoBack = webView?.canGoBack ?? false
        canGoForward = webView?.canGoForward ?? false
        isLoading = webView?.isLoading ?? false
        title = webView?.title ?? "Stealth Browser"
        if let currentURL = webView?.url?.absoluteString {
            urlString = currentURL
        }
    }
}
