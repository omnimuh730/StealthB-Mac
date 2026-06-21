import SwiftUI

struct ContentView: View {
    @State private var state = BrowserState()
    @Bindable private var settings = WebViewSettings.shared
    @Bindable private var bookmarkStore = BookmarkStore.shared
    @FocusState private var addressBarFocused: Bool
    @State private var showBookmarks = false
    @State private var showSettings = false

    private var isCurrentPageBookmarked: Bool {
        bookmarkStore.contains(url: state.urlString)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                toolbar
                Divider()
                BrowserWebView(state: state, settings: settings)
            }

            if showBookmarks {
                bookmarksPanel
                    .padding(.top, 44)
                    .padding(.trailing, 56)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .stealthWindow()
        .sheet(isPresented: $showSettings) {
            WebViewSettingsView(userAgent: state.reportedUserAgent)
                .stealthWindow()
                .onAppear {
                    StealthWindowManager.applyToAllWindows()
                }
        }
        .onAppear {
            StealthWindowManager.applyToAllWindows()
        }
        .onChange(of: showBookmarks) { _, isShowing in
            if isShowing {
                StealthWindowManager.applyToAllWindows()
            }
        }
    }

    private var bookmarksPanel: some View {
        BookmarksView { bookmark in
            state.load(urlString: bookmark.url)
            showBookmarks = false
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            Button(action: state.goBack) {
                Image(systemName: "chevron.left")
            }
            .disabled(!state.canGoBack)
            .help("Back")

            Button(action: state.goForward) {
                Image(systemName: "chevron.right")
            }
            .disabled(!state.canGoForward)
            .help("Forward")

            Button(action: state.loadHome) {
                Image(systemName: "house")
            }
            .help("Home")

            Button {
                if state.isLoading {
                    state.stopLoading()
                } else {
                    state.reload()
                }
            } label: {
                Image(systemName: state.isLoading ? "xmark" : "arrow.clockwise")
            }
            .help(state.isLoading ? "Stop" : "Reload")

            TextField("Search or enter URL", text: $state.urlString)
                .textFieldStyle(.roundedBorder)
                .focused($addressBarFocused)
                .onSubmit {
                    state.loadURL()
                    addressBarFocused = false
                }

            Button("Go") {
                state.loadURL()
                addressBarFocused = false
            }

            Button(action: state.toggleBookmark) {
                Image(systemName: isCurrentPageBookmarked ? "star.fill" : "star")
            }
            .help(isCurrentPageBookmarked ? "Remove bookmark" : "Add bookmark")

            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    showBookmarks.toggle()
                }
            } label: {
                Image(systemName: showBookmarks ? "bookmark.fill" : "bookmark")
            }
            .help("Bookmarks")

            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "gearshape")
            }
            .help("WebView settings")
        }
        .padding(8)
    }
}

#Preview {
    ContentView()
}
