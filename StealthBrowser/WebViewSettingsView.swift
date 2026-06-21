import SwiftUI

struct WebViewSettingsView: View {
    @Bindable private var settings = WebViewSettings.shared
    var userAgent: String = ""

    var body: some View {
        Form {
            Section {
                LabeledContent("Engine", value: WebEngineInfo.engineName)
                LabeledContent("Platform", value: WebEngineInfo.platformDescription)
                if !userAgent.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("User Agent")
                            .foregroundStyle(.secondary)
                        Text(userAgent)
                            .font(.caption)
                            .textSelection(.enabled)
                    }
                } else {
                    Text("User agent appears after the first page loads.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Web Engine")
            } footer: {
                Text("On macOS, WKWebView is the native WebView component — the same engine Safari uses. macOS does not ship a Chromium-based WebView like Windows WebView2.")
            }

            Section {
                Toggle("Allow popups", isOn: $settings.allowPopups)
                Toggle("Allow drag and drop", isOn: $settings.allowDragAndDrop)
                Toggle("Allow tooltips", isOn: $settings.allowTooltips)
            } header: {
                Text("Behavior")
            } footer: {
                Text("Uses a modern Safari desktop user agent so sites serve their current layout. Popup blocking only stops automatic JS popups — link clicks still open in this window.")
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .padding()
    }
}

#Preview {
    WebViewSettingsView()
}
