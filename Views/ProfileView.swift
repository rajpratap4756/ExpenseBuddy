import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var selectedLanguage = "English"
    @State private var selectedTimeZone = "UTC+1"

    @State private var showImagePicker = false
    @State private var profileImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        List {
            // MARK: - Profile Header
            Section(header: Text("PROFILE")) {
                VStack(spacing: 8) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top)

                    Text("John Doe")
                        .font(.headline)

                    Text("john.doe@example.com")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.clear)
            }

            // MARK: - Preferences Section
            Section(header: Text("PREFERENCES")) {
                HStack {
                    Text("Currency Symbol")
                    Spacer()
                    Picker("", selection: $authVM.selectedCurrency) {
                        ForEach(authVM.availableCurrencies, id: \.self) {
                            Text($0)
                        }
                    }
                    .labelsHidden()
                }
            }

            // MARK: - Account Section
            Section(header: Text("ACCOUNT")) {
                NavigationLink(destination: PrivacySettingsView()) {
                    Label("Privacy Settings", systemImage: "shield")
                }

                NavigationLink(destination: SecuritySettingsView()) {
                    Label("Security Settings", systemImage: "lock")
                }

                NavigationLink(destination: HelpSupportView()) {
                    Label("Help & Support", systemImage: "questionmark.circle")
                }

                NavigationLink(destination: AboutView()) {
                    Label("About", systemImage: "info.circle")
                }
            }

            // MARK: - Logout Section
            Section {
                Button(role: .destructive) {
                    authVM.logout()
                    authVM.isLoggedIn = false
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.square.fill")
                            .foregroundColor(.red)
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    self.profileImage = uiImage
                    authVM.saveProfileImage(image: uiImage)
                }
            }
        }
    }
}
