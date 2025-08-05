import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showImagePicker = false
    @State private var profileImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem?
    @State private var showEditProfile = false

    var body: some View {
        ZStack {
            //  Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#d6e4ff"), Color(hex: "#fbe0f8")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            List {
                // MARK: - Profile Header
                Section(header: Text("PROFILE").foregroundColor(.black)) {
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
                                    .foregroundColor(.purple.opacity(0.6))
                            }
                        }
                        .padding(.top)

                        HStack(spacing: 8) {
                            Text(authVM.userProfile?.fullName ?? "User")
                                .font(.headline)
                                .foregroundColor(.black)

                           // Spacer()

                            //  Edit Profile Button
                            Button(action: {
                                showEditProfile = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                            .buttonStyle(PlainButtonStyle())
                            // Hidden navigation link
                            .background(
                                NavigationLink(
                                    destination: EditProfileView(),
                                    isActive: $showEditProfile
                                ) {
                                    EmptyView()
                                }
                                .hidden()
                            )
                        }

                        Text(authVM.userProfile?.email ?? "No email")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                }

                // MARK: - Preferences Section
                Section(header: Text("PREFERENCES").foregroundColor(.black)) {
                    HStack {
                        Text("Currency Symbol")
                            .foregroundColor(.black)
                        Spacer()
                        Picker("", selection: Binding(
                            get: { authVM.selectedCurrency },
                            set: { newCurrency in
                                Task {
                                    await authVM.updateCurrency(newCurrency)
                                }
                            }
                        )) {
                            ForEach(authVM.availableCurrencies, id: \.self) {
                                Text($0)
                                    .foregroundColor(.white)
                            }
                        }
                        .labelsHidden()
                    }
                    .listRowBackground(Color.clear)
                }

                // MARK: - Account Section
                Section(header: Text("ACCOUNT").foregroundColor(.black)) {
                    NavigationLink(destination: PrivacySettingsView()) {
                        Label("Privacy Settings", systemImage: "shield")
                            .foregroundColor(.black)
                    }

                    NavigationLink(destination: SecuritySettingsView()) {
                        Label("Security Settings", systemImage: "lock")
                            .foregroundColor(.black)
                    }

                    NavigationLink(destination: HelpSupportView()) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                            .foregroundColor(.black)
                    }

                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "info.circle")
                            .foregroundColor(.black)
                    }
                }
                .listRowBackground(Color.clear)

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
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
