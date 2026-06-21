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
                Text("StealthBrowser uses the system WebKit framework — the same engine Safari uses on this Mac. It is not a separate or outdated embed.")
            }

            Section {
                Toggle("Allow popups", isOn: $settings.allowPopups)
                Toggle("Allow drag and drop", isOn: $settings.allowDragAndDrop)
                Toggle("Allow tooltips", isOn: $settings.allowTooltips)
            } header: {
                Text("Behavior")
            } footer: {
                Text("Popups, drag and drop, and tooltips are disabled by default. Changes apply immediately to the web view.")
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
