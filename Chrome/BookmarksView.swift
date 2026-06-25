import SwiftUI

struct BookmarksView: View {
    @Bindable private var store = BookmarkStore.shared
    let onOpen: (Bookmark) -> Void

    var body: some View {
        Group {
            if store.bookmarks.isEmpty {
                ContentUnavailableView(
                    "No Bookmarks",
                    systemImage: "bookmark",
                    description: Text("Bookmark the current page from the toolbar.")
                )
            } else {
                List {
                    ForEach(store.bookmarks) { bookmark in
                        Button {
                            onOpen(bookmark)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(bookmark.title)
                                    .font(.body)
                                Text(bookmark.url)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: store.remove)
                }
            }
        }
        .frame(width: 360, height: 320)
    }
}

#Preview {
    BookmarksView { _ in }
}
