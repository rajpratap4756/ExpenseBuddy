import SwiftUI

struct PrivacySettingsView: View {
    @State private var locationEnabled = false
    @State private var analyticsEnabled = true
    @State private var personalizationEnabled = true
    
    var body: some View {
        List {
            Section(header: Text("DATA COLLECTION")) {
                Toggle("Location Services", isOn: $locationEnabled)
                Toggle("Analytics", isOn: $analyticsEnabled)
                Toggle("Personalization", isOn: $personalizationEnabled)
            }
            
            Section(header: Text("DATA USAGE"), footer: Text("We value your privacy and ensure your data is protected according to our privacy policy.")) {
                NavigationLink("Data Access") {
                    Text("View and manage your data")
                }
                NavigationLink("Data Deletion") {
                    Text("Request data deletion")
                }
            }
        }
        .navigationTitle("Privacy Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}