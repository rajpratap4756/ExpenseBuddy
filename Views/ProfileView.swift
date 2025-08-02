import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AuthViewModel

    @State private var selectedLanguage = "English"
    @State private var selectedTimeZone = "UTC+1"

    @State private var showImagePicker = false
    @State private var profileImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        NavigationView {
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
                        Picker("", selection: $viewModel.selectedCurrency) {
                            ForEach(viewModel.availableCurrencies, id: \.self) {
                                Text($0)
                            }
                        }
                        .labelsHidden()
                    }

                    HStack {
                        Label("Language", systemImage: "globe")
                        Spacer()
                        Text(selectedLanguage)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Label("Time Zone", systemImage: "clock")
                        Spacer()
                        Text(selectedTimeZone)
                            .foregroundColor(.gray)
                    }
                }

                // MARK: - Account Section
                Section(header: Text("ACCOUNT")) {
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy Settings", systemImage: "shield")
                    }

                    NavigationLink(destination: Text("Security Settings")) {
                        Label("Security Settings", systemImage: "lock")
                    }

                    NavigationLink(destination: Text("Help & Support")) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }

                    NavigationLink(destination: Text("About")) {
                        Label("About", systemImage: "info.circle")
                    }
                }

                // MARK: - Logout Section
                Section {
                    Button(role: .destructive) {
                        viewModel.logout()
                        presentationMode.wrappedValue.dismiss()
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    self.profileImage = uiImage
                    viewModel.saveProfileImage(image: uiImage) // Optional: for shared use in Home screen
                }
            }
        }
    }
}
