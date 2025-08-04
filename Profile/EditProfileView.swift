import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // 🌈 Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#d6e4ff"), Color(hex: "#fbe0f8")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image Section
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.purple.opacity(0.6))
                        
                        Text("Edit Profile")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    .padding(.top, 20)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            TextField("Enter first name", text: $firstName)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            TextField("Enter last name", text: $lastName)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: saveProfile) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Saving..." : "Save Changes")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#3b82f6"), Color(hex: "#a855f7")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(isLoading || firstName.isEmpty || lastName.isEmpty)
                    .opacity(isLoading || firstName.isEmpty || lastName.isEmpty ? 0.6 : 1.0)
                    .padding(.horizontal)
                    
                    // Cancel Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCurrentProfile()
        }
        .alert("Profile Update", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadCurrentProfile() {
        if let profile = authVM.userProfile {
            firstName = profile.firstName
            lastName = profile.lastName
        }
    }
    
    private func saveProfile() {
        guard !firstName.isEmpty && !lastName.isEmpty else {
            alertMessage = "Please fill in both first name and last name"
            showAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                guard let currentProfile = authVM.userProfile else {
                    await MainActor.run {
                        alertMessage = "No profile found"
                        showAlert = true
                        isLoading = false
                    }
                    return
                }
                
                // Create updated profile
                var updatedProfile = currentProfile
                updatedProfile.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                updatedProfile.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                updatedProfile.updatedAt = Date()
                
                // Update in Supabase
                let savedProfile = try await ProfileService.shared.updateProfile(updatedProfile)
                
                await MainActor.run {
                    // Update local profile
                    authVM.userProfile = savedProfile
                    alertMessage = "Profile updated successfully!"
                    showAlert = true
                    isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to update profile: \(error.localizedDescription)"
                    showAlert = true
                    isLoading = false
                }
            }
        }
    }
} 