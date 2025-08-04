import SwiftUI

struct SecuritySettingsView: View {
    @State private var biometricEnabled = true
    @State private var twoFactorEnabled = false
    @State private var autoLockTime = 5

    let autoLockOptions = [1, 5, 15, 30, 60]

    var body: some View {
        ZStack {
            //  Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#d6e4ff"), Color(hex: "#fbe0f8")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            //  List with Transparent Background
            List {
                Section(header: Text("AUTHENTICATION")) {
                    Toggle("Face ID / Touch ID", isOn: $biometricEnabled)
                    Toggle("Two-Factor Authentication", isOn: $twoFactorEnabled)
                }

                Section(header: Text("AUTO-LOCK")) {
                    Picker("Auto-Lock After", selection: $autoLockTime) {
                        ForEach(autoLockOptions, id: \.self) { minutes in
                            Text(minutes == 1 ? "\(minutes) minute" : "\(minutes) minutes")
                        }
                    }
                }

                Section(header: Text("SECURITY OPTIONS")) {
                    NavigationLink("Change Password") {
                        Text("Update your password")
                    }
                    NavigationLink("Login History") {
                        Text("View recent login activity")
                    }
                }
            }
            .scrollContentBackground(.hidden) //  Hides default List background
            .background(Color.clear)
        }
        .navigationTitle("Security Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
