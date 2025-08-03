import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)
                
                Text("Welcome Back!")
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
                        .background(isValidForm ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isValidForm)
                
                NavigationLink("Don't have an account? Sign Up", destination: SignupView())
                    .font(.callout)
                    .foregroundColor(.blue)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private var isValidForm: Bool {
        isEmailValid && isPasswordValid && !authVM.email.isEmpty && !authVM.password.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
