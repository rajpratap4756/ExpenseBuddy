import SwiftUI

struct PrivacySettingsView: View {
    @State private var locationEnabled = false
    @State private var analyticsEnabled = true
    @State private var personalizationEnabled = true

    var body: some View {
        ZStack {
            // 🔵 Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#d6e4ff"), Color(hex: "#fbe0f8")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            List {
                Section(header: Text("DATA COLLECTION")) {
                    Toggle("Location Services", isOn: $locationEnabled)
                    Toggle("Analytics", isOn: $analyticsEnabled)
                    Toggle("Personalization", isOn: $personalizationEnabled)
                }

                Section(
                    header: Text("DATA USAGE"),
                    footer: Text("We value your privacy and ensure your data is protected according to our privacy policy.")
                ) {
                    NavigationLink("Data Access") {
                        Text("View and manage your data")
                    }
                    NavigationLink("Data Deletion") {
                        Text("Request data deletion")
                    }
                }
            }
            .scrollContentBackground(.hidden) // 🚫 Hide default background
            .background(Color.clear) // ✅ Let ZStack background show
        }
        .navigationTitle("Privacy Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

