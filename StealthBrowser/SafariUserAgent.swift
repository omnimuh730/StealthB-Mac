import Foundation

enum SafariUserAgent {
    /// Modern Safari user agent string so sites like Google serve their current desktop UI.
    static var desktop: String {
        let safari = safariVersion
        return """
        Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) \
        AppleWebKit/605.1.15 (KHTML, like Gecko) \
        Version/\(safari) Safari/605.1.15
        """.replacingOccurrences(of: "\n", with: " ")
    }

    private static var safariVersion: String {
        let macOS = ProcessInfo.processInfo.operatingSystemVersion
        switch macOS.majorVersion {
        case 16...: return "19.0"
        case 15: return "18.2"
        case 14: return "17.6"
        case 13: return "16.6"
        default: return "18.0"
        }
    }
}
