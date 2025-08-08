import SwiftUI
import Supabase

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var otpCode = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var step: Step = .enterEmail
    @State private var message: String?
    @State private var isLoading = false
    @State private var isEmailValid = true
    
    enum Step {
        case enterEmail
        case enterOTP
        case enterNewPassword
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#fbe0f8"), Color(hex: "#d6e4ff")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    Text(stepTitle)
                        .font(.title2.bold())
                        .padding(.top)
                    
                    if let msg = message {
                        Text(msg)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    switch step {
                        
                    case .enterEmail:
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .onChange(of: email) { _ in
                                isEmailValid = isValidEmail(email)
                            }
                        
                        if !isEmailValid {
                            Text("Please enter a valid email")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        actionButton("Send OTP") {
                            sendOTP()
                        }
                        
                    case .enterOTP:
                        TextField("Enter OTP code", text: $otpCode)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                        
                        actionButton("Verify OTP") {
                            verifyOTP()
                        }
                        
                    case .enterNewPassword:
                        SecureField("New Password", text: $newPassword)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                        
                        if newPassword != confirmPassword && !newPassword.isEmpty {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        actionButton("Update Password") {
                            updatePassword()
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Forgot Password")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func sendOTP() {
        guard isValidEmail(email) else {
            isEmailValid = false
            return
        }
        isLoading = true
        Task {
            do {
                try await SupabaseAuthService.shared.client.auth.signInWithOTP(
                    email: email,
                    shouldCreateUser: false
                )
                message = "OTP sent to your email."
                step = .enterOTP
            } catch {
                message = "Failed to send OTP: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func verifyOTP() {
        isLoading = true
        Task {
            do {
                _ = try await SupabaseAuthService.shared.client.auth.verifyOTP(
                    email: email,
                    token: otpCode,
                    type: .email
                )
                message = "OTP verified. Please set your new password."
                step = .enterNewPassword
            } catch {
                message = "Invalid OTP: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func updatePassword() {
        guard newPassword == confirmPassword else {
            message = "Passwords do not match."
            return
        }
        isLoading = true
        Task {
            do {
                try await SupabaseAuthService.shared.client.auth.update(
                    user: UserAttributes(password: newPassword)
                )
                message = "Password updated successfully."
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } catch {
                message = "Failed to update password: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    // MARK: - Helpers
    
    private var stepTitle: String {
        switch step {
        case .enterEmail: return "Reset Your Password"
        case .enterOTP: return "Verify OTP"
        case .enterNewPassword: return "Set New Password"
        }
    }
    
    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#3b82f6"), Color(hex: "#a855f7")]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(10)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
