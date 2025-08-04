import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var confirmPassword = ""
    @State private var passwordsMatch = true
    @State private var otpCode = ""

    var body: some View {
        ZStack {
            //  Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#d6e4ff"), Color(hex: "#fbe0f8")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "person.badge.plus")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.purple.opacity(0.7))
                    .padding(.bottom, 20)

                Text("Create Account")
                    .font(.title.bold())
                    .foregroundColor(.black)
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

                        //  Verify OTP Button
                        Button(action: {
                            Task {
                                do {
                                    try await authVM.verifyOTP(token: otpCode)
                                    authVM.isLoggedIn = true
                                } catch {
                                    // error already handled
                                }
                            }
                        }) {
                            Text("Verify OTP")
                                .frame(maxWidth: .infinity)
                                .padding()
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
                        .disabled(otpCode.isEmpty)
                        .opacity(otpCode.isEmpty ? 0.5 : 1)
                    }
                } else {
                    //  Sign Up Button
                    Button(action: {
                        Task {
                            do {
                                _ = try await authVM.signUp()
                            } catch {
                                // error already handled
                            }
                        }
                    }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
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
                    .disabled(!isValidForm)
                    .opacity(!isValidForm ? 0.5 : 1)
                }

                NavigationLink("Already have an account? Login", destination: LoginView())
                    .font(.callout)
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .navigationBarTitle("Sign Up", displayMode: .large)
        .navigationBarHidden(true)
    }

    private var isValidForm: Bool {
        !authVM.email.isEmpty && !authVM.password.isEmpty && !confirmPassword.isEmpty &&
        isEmailValid && isPasswordValid && passwordsMatch
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}


