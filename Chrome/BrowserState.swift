import Foundation
import WebKit

enum BrowserRouting {
    static let homeURL = "https://www.google.com"

    static func resolve(_ input: String) -> URL? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return URL(string: homeURL) }

        if let url = URL(string: trimmed), url.scheme != nil, url.host != nil {
            return url
        }

        if looksLikeDomain(trimmed), let url = URL(string: "https://\(trimmed)") {
            return url
        }

        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [URLQueryItem(name: "q", value: trimmed)]
        return components?.url
    }

    private static func looksLikeDomain(_ text: String) -> Bool {
        let pattern = #"^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+(/.*)?$"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }
}

@Observable
@MainActor
final class BrowserState {
    var urlString = BrowserRouting.homeURL
    var canGoBack = false
    var canGoForward = false
    var isLoading = false
    var title = "Chrome"
    var reportedUserAgent = ""

    private(set) weak var webView: WKWebView?

    func attach(webView: WKWebView) {
        self.webView = webView
    }

    func loadURL() {
        guard let webView else { return }
        guard let url = BrowserRouting.resolve(urlString) else { return }
        urlString = url.absoluteString
        webView.load(URLRequest(url: url))
    }

    func load(urlString: String) {
        self.urlString = urlString
        loadURL()
    }

    func loadHome() {
        load(urlString: BrowserRouting.homeURL)
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

    func toggleBookmark() {
        guard let url = webView?.url?.absoluteString else { return }
        if BookmarkStore.shared.contains(url: url) {
            if let bookmark = BookmarkStore.shared.bookmarks.first(where: { $0.url == url }) {
                BookmarkStore.shared.remove(id: bookmark.id)
            }
        } else {
            BookmarkStore.shared.add(title: title, url: url)
        }
    }

    func updateNavigationState() {
        canGoBack = webView?.canGoBack ?? false
        canGoForward = webView?.canGoForward ?? false
        isLoading = webView?.isLoading ?? false
        title = webView?.title ?? "Chrome"
        if let currentURL = webView?.url?.absoluteString {
            urlString = currentURL
        }

        guard let webView else { return }
        Task {
            reportedUserAgent = await WebEngineInfo.fetchUserAgent(from: webView) ?? reportedUserAgent
        }
    }
}
