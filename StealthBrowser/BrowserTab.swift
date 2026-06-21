import Foundation

@Observable
@MainActor
final class BrowserTab: Identifiable {
    let id = UUID()
    let state = BrowserState()

    var displayTitle: String {
        let title = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty || title == "Stealth Browser" {
            return shortURL ?? "New Tab"
        }
        return title
    }

    private var shortURL: String? {
        guard let url = URL(string: state.urlString), let host = url.host else { return nil }
        return host.replacingOccurrences(of: "www.", with: "")
    }
}

@Observable
@MainActor
final class TabManager {
    private(set) var tabs: [BrowserTab] = []
    var selectedTabID: UUID

    init() {
        let first = BrowserTab()
        tabs = [first]
        selectedTabID = first.id
    }

    var selectedTab: BrowserTab {
        tabs.first { $0.id == selectedTabID } ?? tabs[0]
    }

    func addTab(url: String? = nil) {
        let tab = BrowserTab()
        if let url {
            tab.state.urlString = url
        }
        tabs.append(tab)
        selectedTabID = tab.id
    }

    func closeTab(_ id: UUID) {
        guard tabs.count > 1 else { return }
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }

        tabs.remove(at: index)

        if selectedTabID == id {
            let nextIndex = min(index, tabs.count - 1)
            selectedTabID = tabs[nextIndex].id
        }
    }

    func selectTab(_ id: UUID) {
        guard tabs.contains(where: { $0.id == id }) else { return }
        selectedTabID = id
    }

    func openURLInNewTab(_ url: URL) {
        addTab(url: url.absoluteString)
    }
}
