import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var confirmPassword = ""
    @State private var passwordsMatch = true
    @State private var showOTPView = false
    @State private var otpCode = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.badge.plus")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("Create Account")
                .font(.title.bold())
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Email", text: $authVM.email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .onChange(of: authVM.email) { _ in
                        isEmailValid = isValidEmail(authVM.email)
                    }
                
                if !isEmailValid {
                    Text("Please enter a valid email")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                SecureField("Password", text: $authVM.password)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: authVM.password) { _ in
                        isPasswordValid = authVM.password.count >= 6
                        passwordsMatch = authVM.password == confirmPassword
                    }
                
                if !isPasswordValid {
                    Text("Password must be at least 6 characters")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: confirmPassword) { _ in
                        passwordsMatch = authVM.password == confirmPassword
                    }
                
                if !passwordsMatch {
                    Text("Passwords do not match")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            if let error = authVM.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            if authVM.isOTPSent {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Enter OTP Code", text: $otpCode)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    
                    Button(action: {
                        Task {
                            do {
                                try await authVM.verifyOTP(token: otpCode)
                                authVM.isLoggedIn = true
                            } catch {
                                // Error is already handled in AuthViewModel
                            }
                        }
                    }) {
                        Text("Verify OTP")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(!otpCode.isEmpty ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(otpCode.isEmpty)
                }
            } else {
                Button(action: {
                    Task {
                        do {
                            _ = try await authVM.signUp()
                        } catch {
                            // Error is already handled in AuthViewModel
                        }
                    }
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValidForm ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isValidForm)
            }
            
            NavigationLink("Already have an account? Login", destination: LoginView())
                .font(.callout)
                .foregroundColor(.blue)
        }
        .padding()
        .navigationBarTitle("Sign Up", displayMode: .large)
    }
    
    private var isValidForm: Bool {
        !authVM.email.isEmpty && !authVM.password.isEmpty && !confirmPassword.isEmpty &&
        isEmailValid && isPasswordValid && passwordsMatch
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
