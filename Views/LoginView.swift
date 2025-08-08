import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var showForgotPassword = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#d6e4ff"), Color(hex: "#fbe0f8")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.purple.opacity(0.7))
                        .padding(.bottom, 20)

                    Text("Welcome Back!")
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
                            }

                        if !isPasswordValid {
                            Text("Password must be at least 6 characters")
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

                    // Login Button
                    Button(action: {
                        if isValidEmail(authVM.email) && authVM.password.count >= 6 {
                            Task {
                                do {
                                    try await SupabaseAuthService.shared.signIn(email: authVM.email, password: authVM.password)
                                    authVM.isLoggedIn = true
                                } catch {
                                    authVM.errorMessage = "Invalid email or password"
                                }
                            }
                        }
                    }) {
                        Text("Login")
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
                    .opacity(isValidForm ? 1 : 0.5)

                    // Forgot Password Link
                    Button(action: {
                        showForgotPassword = true
                    }) {
                        Text("Forgot Password?")
                            .font(.callout)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 5)
                    .fullScreenCover(isPresented: $showForgotPassword) {
                        ForgotPasswordView()
                    }
                    NavigationLink("Don't have an account? Sign Up", destination: SignupView())
                        .font(.callout)
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }

    private var isValidForm: Bool {
        isEmailValid && isPasswordValid && !authVM.email.isEmpty && !authVM.password.isEmpty
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
