import SwiftUI

struct ContentView: View {
    @State private var state = BrowserState()
    @FocusState private var addressBarFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            BrowserWebView(state: state)
        }
        .frame(minWidth: 900, minHeight: 600)
        .stealthWindow()
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

            TextField("Enter URL", text: $state.urlString)
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
        }
        .padding(8)
    }
}

#Preview {
    ContentView()
}
