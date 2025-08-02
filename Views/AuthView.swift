//
//  AuthView.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 31/07/25.
//

//import SwiftUI
//
//struct AuthView: View {
//    @State private var email = ""
//    @State private var password = ""
//    @State private var isLogin = true
//    @EnvironmentObject var session: SessionManager
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text(isLogin ? "Login" : "Sign Up")
//                .font(.largeTitle)
//
//            TextField("Email", text: $email)
//                .autocapitalization(.none)
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(8)
//
//            SecureField("Password", text: $password)
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(8)
//
//            Button(action: {
//                Task {
//                    do {
//                        if isLogin {
//                            try await SupabaseAuthService.shared.signIn(email: email, password: password)
//                        } else {
//                            try await SupabaseAuthService.shared.signUp(email: email, password: password)
//                        }
//                        $session.loadUser
//                    } catch {
//                        print("Auth error: \(error)")
//                    }
//                }
//            }) {
//                Text(isLogin ? "Login" : "Sign Up")
//                    .bold()
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//
//            Button(action: {
//                isLogin.toggle()
//            }) {
//                Text(isLogin ? "Don’t have an account? Sign Up" : "Already have an account? Login")
//                    .font(.footnote)
//            }
//        }
//        .padding()
//    }
//}
