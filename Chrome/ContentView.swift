import SwiftUI

struct ContentView: View {
    @State private var tabManager = TabManager()
    @Bindable private var settings = WebViewSettings.shared
    @Bindable private var bookmarkStore = BookmarkStore.shared
    @Bindable private var focusGuard = WindowFocusGuard.shared
    @FocusState private var addressBarFocused: Bool
    @State private var showBookmarks = false
    @State private var showSettings = false

    private var selectedState: BrowserState {
        tabManager.selectedTab.state
    }

    private var isCurrentPageBookmarked: Bool {
        bookmarkStore.contains(url: selectedState.urlString)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                tabBar
                toolbar
                Divider()
                tabContent
            }

            if showBookmarks {
                bookmarksPanel
                    .padding(.top, 78)
                    .padding(.trailing, 56)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if focusGuard.isContentHidden {
                focusBlankOverlay
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .stealthWindow()
        .sheet(isPresented: $showSettings) {
            WebViewSettingsView(userAgent: selectedState.reportedUserAgent)
                .stealthWindow()
                .onAppear {
                    StealthWindowManager.applyToAllWindows()
                }
        }
        .onAppear {
            StealthWindowManager.applyToAllWindows()
            WindowController.shared.applyOpacity()
        }
        .onReceive(NotificationCenter.default.publisher(for: .stealthNewTab)) { _ in
            tabManager.addTab()
        }
        .onChange(of: showBookmarks) { _, isShowing in
            if isShowing {
                StealthWindowManager.applyToAllWindows()
            }
        }
    }

    private var tabContent: some View {
        ZStack {
            ForEach(tabManager.tabs) { tab in
                BrowserWebView(
                    state: tab.state,
                    settings: settings,
                    onOpenNewTab: { url in
                        tabManager.openURLInNewTab(url)
                    }
                )
                .opacity(tab.id == tabManager.selectedTabID ? 1 : 0)
                .allowsHitTesting(tab.id == tabManager.selectedTabID && !focusGuard.isContentHidden)
                .accessibilityHidden(tab.id != tabManager.selectedTabID)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var focusBlankOverlay: some View {
        Color(nsColor: .windowBackgroundColor)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }

    private var tabBar: some View {
        HStack(spacing: 6) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(tabManager.tabs) { tab in
                        tabButton(for: tab)
                    }
                }
                .padding(.horizontal, 8)
            }

            Button {
                tabManager.addTab()
            } label: {
                Image(systemName: "plus")
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .help("New Tab")
            .padding(.trailing, 8)
        }
        .frame(height: 34)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private func tabButton(for tab: BrowserTab) -> some View {
        let isSelected = tab.id == tabManager.selectedTabID

        return HStack(spacing: 6) {
            Button {
                tabManager.selectTab(tab.id)
            } label: {
                Text(tab.displayTitle)
                    .lineLimit(1)
                    .frame(maxWidth: 180, alignment: .leading)
            }
            .buttonStyle(.plain)

            if tabManager.tabs.count > 1 {
                Button {
                    tabManager.closeTab(tab.id)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Close Tab")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isSelected ? Color(nsColor: .windowBackgroundColor) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var bookmarksPanel: some View {
        BookmarksView { bookmark in
            selectedState.load(urlString: bookmark.url)
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
            Button(action: selectedState.goBack) {
                Image(systemName: "chevron.left")
            }
            .disabled(!selectedState.canGoBack)
            .help("Back")

            Button(action: selectedState.goForward) {
                Image(systemName: "chevron.right")
            }
            .disabled(!selectedState.canGoForward)
            .help("Forward")

            Button(action: selectedState.loadHome) {
                Image(systemName: "house")
            }
            .help("Home")

            Button {
                if selectedState.isLoading {
                    selectedState.stopLoading()
                } else {
                    selectedState.reload()
                }
            } label: {
                Image(systemName: selectedState.isLoading ? "xmark" : "arrow.clockwise")
            }
            .help(selectedState.isLoading ? "Stop" : "Reload")

            TextField("Search or enter URL", text: urlBinding)
                .textFieldStyle(.roundedBorder)
                .focused($addressBarFocused)
                .onSubmit {
                    selectedState.loadURL()
                    addressBarFocused = false
                }

            Button("Go") {
                selectedState.loadURL()
                addressBarFocused = false
            }

            Button(action: selectedState.toggleBookmark) {
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

    private var urlBinding: Binding<String> {
        Binding(
            get: { tabManager.selectedTab.state.urlString },
            set: { tabManager.selectedTab.state.urlString = $0 }
        )
    }
}

#Preview {
    ContentView()
}
