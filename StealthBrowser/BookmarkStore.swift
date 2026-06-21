import Foundation

@Observable
@MainActor
final class BookmarkStore {
    static let shared = BookmarkStore()

    private(set) var bookmarks: [Bookmark] = []

    private let storageKey = "browser.bookmarks"

    private init() {
        load()
    }

    func add(title: String, url: String) {
        let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty else { return }

        if let index = bookmarks.firstIndex(where: { $0.url == trimmedURL }) {
            bookmarks[index].title = title.isEmpty ? trimmedURL : title
            save()
            return
        }

        let bookmark = Bookmark(
            title: title.isEmpty ? trimmedURL : title,
            url: trimmedURL
        )
        bookmarks.insert(bookmark, at: 0)
        save()
    }

    func remove(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            bookmarks.remove(at: index)
        }
        save()
    }

    func remove(id: UUID) {
        bookmarks.removeAll { $0.id == id }
        save()
    }

    func contains(url: String) -> Bool {
        bookmarks.contains { $0.url == url }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Bookmark].self, from: data)
        else {
            bookmarks = []
            return
        }
        bookmarks = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(bookmarks) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
